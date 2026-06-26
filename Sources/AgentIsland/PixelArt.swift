import SwiftUI
import AppKit

// Official mascot art, bundled from the user's installed Claude.app / Codex.app
// into AgentIsland.app/Contents/Resources/pets at build time. Animated GIFs
// (e.g. Clawd) animate via NSImageView. If an asset is missing (e.g. running the
// bare dev binary, or before Codex's pet sprite is downloaded), we fall back to
// the hand-drawn pixel sprites below.

enum PetAsset {
    static func url(for agent: AgentKind) -> URL? {
        let name = (agent == .codex) ? "codex" : "clawd"
        for ext in ["gif", "png", "webp"] {
            if let u = Bundle.main.url(forResource: name, withExtension: ext, subdirectory: "pets") {
                return u
            }
        }
        return nil
    }

    // width / height of the source art, so we can size by height and let the
    // pet keep its natural proportions (Clawd is landscape; Codex is square).
    private static var aspectCache: [String: CGFloat] = [:]
    static func aspect(for agent: AgentKind) -> CGFloat {
        let key = agent.rawValue
        if let a = aspectCache[key] { return a }
        var a: CGFloat = 1
        if let u = url(for: agent), let img = NSImage(contentsOf: u), img.size.height > 0 {
            a = img.size.width / img.size.height
        }
        aspectCache[key] = a
        return a
    }
}

// An NSImageView that does NOT impose the image's huge natural size on layout —
// otherwise the representable ignores the SwiftUI .frame and overflows.
final class PetNSImageView: NSImageView {
    override var intrinsicContentSize: NSSize {
        NSSize(width: NSView.noIntrinsicMetric, height: NSView.noIntrinsicMetric)
    }
}

// Renders a still or animated image; GIFs animate automatically.
struct PetImageView: NSViewRepresentable {
    let url: URL

    final class Coordinator { var url: URL? }
    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeNSView(context: Context) -> PetNSImageView {
        let iv = PetNSImageView()
        iv.animates = true
        iv.imageScaling = .scaleProportionallyUpOrDown   // fit whole pet inside the frame
        iv.imageAlignment = .alignCenter
        iv.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        iv.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        return iv
    }
    func updateNSView(_ v: PetNSImageView, context: Context) {
        // Reload only when the url changes — SwiftUI reuses the NSView across
        // ForEach items, so guarding on url (not image == nil) is required or a
        // reused view keeps the previous pet (both pets showed Clawd).
        if context.coordinator.url != url {
            context.coordinator.url = url
            v.image = NSImage(contentsOf: url)
        }
    }
}

// 8-bit pixel sprites drawn from a character grid — fallback only, used when the
// official asset can't be found.

struct PixelSprite {
    let rows: [String]
    let palette: [Character: Color]
    var cols: Int { rows.map(\.count).max() ?? 0 }
}

struct PixelArtView: View {
    let sprite: PixelSprite

    var body: some View {
        Canvas { ctx, size in
            let cols = sprite.cols
            let rowsN = sprite.rows.count
            guard cols > 0, rowsN > 0 else { return }
            let cw = size.width / CGFloat(cols)
            let ch = size.height / CGFloat(rowsN)
            for (r, row) in sprite.rows.enumerated() {
                for (c, ch0) in row.enumerated() {
                    guard let color = sprite.palette[ch0] else { continue }
                    let rect = CGRect(x: CGFloat(c) * cw, y: CGFloat(r) * ch,
                                      width: cw + 0.6, height: ch + 0.6)
                    ctx.fill(Path(rect), with: .color(color))
                }
            }
        }
        .aspectRatio(CGFloat(sprite.cols) / CGFloat(sprite.rows.count), contentMode: .fit)
    }
}

enum Pets {
    static func sprite(for agent: AgentKind) -> PixelSprite {
        switch agent {
        case .codex: return codex
        default:     return clawd
        }
    }

    // Clawd — orange pixel crab: claws up top, two black eyes, five stubby legs.
    static let clawd = PixelSprite(
        rows: [
            "o.......o",
            ".ooooooo.",
            "ooooooooo",
            "okoooooko",
            "ooooooooo",
            ".ooooooo.",
            "o.o.o.o.o",
        ],
        palette: [
            "o": Color(red: 0.851, green: 0.467, blue: 0.341), // #D97757 clay
            "k": Color(red: 0.13, green: 0.10, blue: 0.09),
        ]
    )

    // Codex — blue robot-cat: white eye patches with black pupils, dark visor mouth.
    static let codex = PixelSprite(
        rows: [
            ".bbbbbbb.",
            "bbbbbbbbb",
            "bwkwbwkwb",
            "bbbbbbbbb",
            "bbmmmmmbb",
            ".bbbbbbb.",
            "b.b...b.b",
        ],
        palette: [
            "b": Color(red: 0.29, green: 0.64, blue: 0.87), // robot blue
            "w": Color(red: 0.95, green: 0.97, blue: 1.0),
            "k": Color(red: 0.10, green: 0.12, blue: 0.16),
            "m": Color(red: 0.16, green: 0.20, blue: 0.28),
        ]
    )
}
