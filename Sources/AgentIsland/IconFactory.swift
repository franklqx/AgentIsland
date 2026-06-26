import AppKit

// Original, monochrome menu-bar glyphs (template images → the system tints them
// white/dark). Light outline style so they sit naturally in the menu bar.
//   0 = A: island outline + camera dot
//   1 = B: island outline + pet eyes
//   2 = C: filled island + camera dot
//   3 = Satellite: all-white satellite glyph
func menuBarIcon(style: Int) -> NSImage {
    let size = NSSize(width: 22, height: 16)
    let img = NSImage(size: size)
    img.lockFocus()
    let ctx = NSGraphicsContext.current!.cgContext
    NSColor.black.setFill()
    NSColor.black.setStroke()

    let body = NSRect(x: 3.5, y: 4, width: 15, height: 8)
    let cx = size.width / 2

    switch style {
    case 3: // Satellite — bold simple blocks, tilted: body + two solar wings
        let rot = NSAffineTransform()
        rot.translateX(by: cx, yBy: 8)
        rot.rotate(byDegrees: 28)
        rot.translateX(by: -cx, yBy: -8)
        let p = NSBezierPath()
        // central body
        p.append(NSBezierPath(roundedRect: NSRect(x: cx - 2.3, y: 4.6, width: 4.6, height: 6.8),
                              xRadius: 1.2, yRadius: 1.2))
        // two solar wings
        p.append(NSBezierPath(rect: NSRect(x: cx - 9.2, y: 5.8, width: 5.6, height: 4.4)))
        p.append(NSBezierPath(rect: NSRect(x: cx + 3.6, y: 5.8, width: 5.6, height: 4.4)))
        // slim connector arms
        p.append(NSBezierPath(rect: NSRect(x: cx - 3.7, y: 7.6, width: 1.4, height: 0.8)))
        p.append(NSBezierPath(rect: NSRect(x: cx + 2.3, y: 7.6, width: 1.4, height: 0.8)))
        rot.transform(p).fill()
    case 1: // B — outline island with two eyes
        let p = NSBezierPath(roundedRect: body, xRadius: 4, yRadius: 4)
        p.lineWidth = 1.4
        p.stroke()
        NSBezierPath(ovalIn: NSRect(x: cx - 2.8, y: 7, width: 2.0, height: 2.0)).fill()
        NSBezierPath(ovalIn: NSRect(x: cx + 0.8, y: 7, width: 2.0, height: 2.0)).fill()

    case 2: // C — filled island with a knocked-out camera dot
        NSBezierPath(roundedRect: body, xRadius: 4, yRadius: 4).fill()
        ctx.setBlendMode(.clear)
        NSBezierPath(ovalIn: NSRect(x: cx - 1.2, y: 6.8, width: 2.4, height: 2.4)).fill()

    default: // A — outline island with a camera dot
        let p = NSBezierPath(roundedRect: body, xRadius: 4, yRadius: 4)
        p.lineWidth = 1.4
        p.stroke()
        NSBezierPath(ovalIn: NSRect(x: cx - 1.1, y: 7, width: 2.2, height: 2.2)).fill()
    }

    img.unlockFocus()
    img.isTemplate = true
    return img
}
