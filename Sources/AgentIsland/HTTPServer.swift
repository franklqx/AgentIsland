import Foundation
import Network

// A tiny, dependency-free HTTP/1.1 server bound to loopback only.
// It is deliberately minimal: it handles one request per connection
// (Connection: close) which is all the curl-based hooks need, and it
// supports long-lived connections so /approval can block until the
// user makes a decision on the island.

struct HTTPRequest {
    let method: String
    let path: String
    let query: [String: String]
    let headers: [String: String]
    let body: Data

    static func parse(_ data: Data) -> HTTPRequest? {
        guard let sep = data.range(of: Data("\r\n\r\n".utf8)) else { return nil }
        let headerData = data.subdata(in: 0..<sep.lowerBound)
        guard let headerStr = String(data: headerData, encoding: .utf8) else { return nil }
        var lines = headerStr.components(separatedBy: "\r\n")
        guard let requestLine = lines.first else { return nil }
        let parts = requestLine.split(separator: " ")
        guard parts.count >= 2 else { return nil }
        let method = String(parts[0])
        let rawPath = String(parts[1])

        var path = rawPath
        var query: [String: String] = [:]
        if let q = rawPath.firstIndex(of: "?") {
            path = String(rawPath[..<q])
            let qs = String(rawPath[rawPath.index(after: q)...])
            for pair in qs.split(separator: "&") {
                let kv = pair.split(separator: "=", maxSplits: 1)
                let k = String(kv[0]).removingPercentEncoding ?? String(kv[0])
                let v = kv.count > 1 ? (String(kv[1]).replacingOccurrences(of: "+", with: " ").removingPercentEncoding ?? "") : ""
                query[k] = v
            }
        }

        lines.removeFirst()
        var headers: [String: String] = [:]
        for line in lines where !line.isEmpty {
            if let c = line.firstIndex(of: ":") {
                let k = String(line[..<c]).trimmingCharacters(in: .whitespaces).lowercased()
                let v = String(line[line.index(after: c)...]).trimmingCharacters(in: .whitespaces)
                headers[k] = v
            }
        }

        let bodyStart = sep.upperBound
        let available = data.subdata(in: bodyStart..<data.count)
        let contentLength = Int(headers["content-length"] ?? "0") ?? 0
        if available.count < contentLength { return nil } // need more bytes
        let body = available.subdata(in: 0..<contentLength)
        return HTTPRequest(method: method, path: path, query: query, headers: headers, body: body)
    }
}

struct HTTPResponse {
    var status: Int = 200
    var contentType: String = "text/plain; charset=utf-8"
    var body: Data = Data()

    static func text(_ s: String, status: Int = 200) -> HTTPResponse {
        HTTPResponse(status: status, body: Data(s.utf8))
    }

    func serialize() -> Data {
        let reason = status == 200 ? "OK" : (status == 403 ? "Forbidden" : (status == 404 ? "Not Found" : "Error"))
        var head = "HTTP/1.1 \(status) \(reason)\r\n"
        head += "Content-Type: \(contentType)\r\n"
        head += "Content-Length: \(body.count)\r\n"
        head += "Connection: close\r\n\r\n"   // no CORS: browsers must not reach this server
        var d = Data(head.utf8)
        d.append(body)
        return d
    }
}

final class HTTPServer: @unchecked Sendable {
    private let port: UInt16
    private var listener: NWListener?
    private let queue = DispatchQueue(label: "agentisland.http", qos: .userInitiated)

    /// Called for every fully-received request. Call `respond` whenever ready
    /// (immediately for events, later for approvals).
    var onRequest: ((HTTPRequest, @escaping (HTTPResponse) -> Void) -> Void)?

    init(port: UInt16) { self.port = port }

    func start() throws {
        let params = NWParameters.tcp
        params.allowLocalEndpointReuse = true
        // Bind to loopback only: no LAN exposure, no firewall prompt.
        params.requiredLocalEndpoint = .hostPort(
            host: "127.0.0.1",
            port: NWEndpoint.Port(rawValue: port)!
        )
        let l = try NWListener(using: params)
        l.newConnectionHandler = { [weak self] conn in self?.accept(conn) }
        l.start(queue: queue)
        listener = l
    }

    private func accept(_ conn: NWConnection) {
        conn.start(queue: queue)
        receive(conn, buffer: Data())
    }

    private func receive(_ conn: NWConnection, buffer: Data) {
        conn.receive(minimumIncompleteLength: 1, maximumLength: 1 << 16) { [weak self] data, _, isComplete, error in
            guard let self else { conn.cancel(); return }
            var buf = buffer
            if let data { buf.append(data) }

            if buf.count > 1 << 20 { conn.cancel(); return }   // cap: don't buffer forever
            if let req = HTTPRequest.parse(buf) {
                // respond may be invoked now or much later (approval long-poll), and
                // potentially more than once (user tap + safety timer). Fire once.
                let sent = NSLock(); var done = false
                self.onRequest?(req) { response in
                    sent.lock(); let go = !done; done = true; sent.unlock()
                    guard go else { return }
                    conn.send(content: response.serialize(),
                              completion: .contentProcessed { _ in conn.cancel() })
                }
            } else if isComplete || error != nil {
                conn.cancel()
            } else {
                self.receive(conn, buffer: buf) // keep reading until headers+body complete
            }
        }
    }
}
