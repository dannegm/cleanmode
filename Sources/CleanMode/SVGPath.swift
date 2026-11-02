import SwiftUI

/// Intérprete mínimo de datos de path SVG (M m L l H h V v A a C c Z z) para dibujar
/// iconos vectoriales (p. ej. lucide) como `Path` de SwiftUI.
enum SVGPath {
    private enum Token { case command(Character), number(CGFloat) }

    static func path(_ d: String) -> Path {
        let tokens = tokenize(d)
        var path = Path()
        var current = CGPoint.zero
        var subpathStart = CGPoint.zero
        var command: Character = " "
        var i = 0

        func take(_ count: Int) -> [CGFloat]? {
            var values: [CGFloat] = []
            while values.count < count, i < tokens.count, case .number(let n) = tokens[i] {
                values.append(n)
                i += 1
            }
            return values.count == count ? values : nil
        }

        while i < tokens.count {
            if case .command(let c) = tokens[i] {
                command = c
                i += 1
                if c == "Z" || c == "z" {
                    path.closeSubpath()
                    current = subpathStart
                    continue
                }
            }
            let relative = command.isLowercase
            switch command.uppercased() {
            case "M":
                guard let v = take(2) else { return path }
                current = relative ? CGPoint(x: current.x + v[0], y: current.y + v[1]) : CGPoint(x: v[0], y: v[1])
                subpathStart = current
                path.move(to: current)
                command = relative ? "l" : "L"   // los pares siguientes son líneas
            case "L":
                guard let v = take(2) else { return path }
                current = relative ? CGPoint(x: current.x + v[0], y: current.y + v[1]) : CGPoint(x: v[0], y: v[1])
                path.addLine(to: current)
            case "H":
                guard let v = take(1) else { return path }
                current = CGPoint(x: relative ? current.x + v[0] : v[0], y: current.y)
                path.addLine(to: current)
            case "V":
                guard let v = take(1) else { return path }
                current = CGPoint(x: current.x, y: relative ? current.y + v[0] : v[0])
                path.addLine(to: current)
            case "C":
                guard let v = take(6) else { return path }
                let o = relative ? current : .zero
                let c1 = CGPoint(x: o.x + v[0], y: o.y + v[1])
                let c2 = CGPoint(x: o.x + v[2], y: o.y + v[3])
                let end = CGPoint(x: o.x + v[4], y: o.y + v[5])
                path.addCurve(to: end, control1: c1, control2: c2)
                current = end
            case "A":
                guard let v = take(7) else { return path }
                let end = relative ? CGPoint(x: current.x + v[5], y: current.y + v[6]) : CGPoint(x: v[5], y: v[6])
                addArc(&path, from: current, rx: v[0], ry: v[1], rotation: v[2],
                       large: v[3] != 0, sweep: v[4] != 0, to: end)
                current = end
            default:
                return path
            }
        }
        return path
    }

    // MARK: - Arcos (SVG endpoint → curvas de Bézier)

    private static func addArc(_ path: inout Path, from p0: CGPoint, rx rxIn: CGFloat, ry ryIn: CGFloat,
                               rotation: CGFloat, large: Bool, sweep: Bool, to p1: CGPoint) {
        guard p0 != p1 else { return }
        var rx = abs(rxIn), ry = abs(ryIn)
        guard rx > 0, ry > 0 else { path.addLine(to: p1); return }

        let phi = rotation * .pi / 180
        let cosPhi = cos(phi), sinPhi = sin(phi)
        let dx2 = (p0.x - p1.x) / 2, dy2 = (p0.y - p1.y) / 2
        let x1p = cosPhi * dx2 + sinPhi * dy2
        let y1p = -sinPhi * dx2 + cosPhi * dy2

        let lambda = (x1p * x1p) / (rx * rx) + (y1p * y1p) / (ry * ry)
        if lambda > 1 { let s = lambda.squareRoot(); rx *= s; ry *= s }

        let sign: CGFloat = (large == sweep) ? -1 : 1
        let numerator = rx * rx * ry * ry - rx * rx * y1p * y1p - ry * ry * x1p * x1p
        let denominator = rx * rx * y1p * y1p + ry * ry * x1p * x1p
        let coef = sign * max(0, numerator / denominator).squareRoot()
        let cxp = coef * (rx * y1p / ry)
        let cyp = coef * (-ry * x1p / rx)
        let cx = cosPhi * cxp - sinPhi * cyp + (p0.x + p1.x) / 2
        let cy = sinPhi * cxp + cosPhi * cyp + (p0.y + p1.y) / 2

        let theta1 = atan2((y1p - cyp) / ry, (x1p - cxp) / rx)
        var delta = atan2((-y1p - cyp) / ry, (-x1p - cxp) / rx) - theta1
        if !sweep && delta > 0 { delta -= 2 * .pi }
        if sweep && delta < 0 { delta += 2 * .pi }

        let segments = max(1, Int(ceil(abs(delta) / (.pi / 2))))
        let step = delta / CGFloat(segments)
        let t = 4.0 / 3.0 * tan(step / 4)

        func map(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: cx + rx * cosPhi * x - ry * sinPhi * y,
                    y: cy + rx * sinPhi * x + ry * cosPhi * y)
        }

        for s in 0..<segments {
            let a = theta1 + CGFloat(s) * step
            let b = a + step
            path.addCurve(
                to: map(cos(b), sin(b)),
                control1: map(cos(a) - t * sin(a), sin(a) + t * cos(a)),
                control2: map(cos(b) + t * sin(b), sin(b) - t * cos(b))
            )
        }
    }

    // MARK: - Tokenizador

    private static func tokenize(_ d: String) -> [Token] {
        var tokens: [Token] = []
        let chars = Array(d)
        var i = 0
        while i < chars.count {
            let c = chars[i]
            if c.isLetter {
                tokens.append(.command(c))
                i += 1
            } else if c == "-" || c == "." || c.isNumber {
                var j = i
                if chars[j] == "-" { j += 1 }
                var seenDot = false
                while j < chars.count, chars[j].isNumber || (chars[j] == "." && !seenDot) {
                    if chars[j] == "." { seenDot = true }
                    j += 1
                }
                if let n = Double(String(chars[i..<j])) { tokens.append(.number(CGFloat(n))) }
                i = max(j, i + 1)
            } else {
                i += 1   // espacios y comas
            }
        }
        return tokens
    }
}

/// Icono "BrushCleaning" de lucide (el mismo de aura), en una cuadrícula de 24x24.
/// Su caja (x 4–20, y 2–22) está centrada en (12, 12), así que rota bien sobre su centro.
struct BrushCleaningShape: Shape {
    private static let paths = [
        "m16 22-1-4",
        "M19 14a1 1 0 0 0 1-1v-1a2 2 0 0 0-2-2h-3a1 1 0 0 1-1-1V4a2 2 0 0 0-4 0v5a1 1 0 0 1-1 1H6a2 2 0 0 0-2 2v1a1 1 0 0 0 1 1",
        "M19 14H5l-1.973 6.767A1 1 0 0 0 4 22h16a1 1 0 0 0 .973-1.233z",
        "m8 22 1-4",
    ].map(SVGPath.path)

    func path(in rect: CGRect) -> Path {
        var combined = Path()
        for p in Self.paths { combined.addPath(p) }
        let scale = min(rect.width, rect.height) / 24
        return combined.applying(CGAffineTransform(scaleX: scale, y: scale))
            .offsetBy(dx: rect.minX, dy: rect.minY)
    }
}
