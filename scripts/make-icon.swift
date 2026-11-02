// Dibuja el icono de la app (1024x1024 PNG) con CoreGraphics.
// Uso: swift scripts/make-icon.swift <salida.png>
import AppKit

let size = 1024
guard CommandLine.arguments.count > 1 else {
    FileHandle.standardError.write(Data("Uso: make-icon.swift <salida.png>\n".utf8))
    exit(1)
}

let rep = NSBitmapImageRep(
    bitmapDataPlanes: nil, pixelsWide: size, pixelsHigh: size,
    bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
    colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0
)!
let gc = NSGraphicsContext(bitmapImageRep: rep)!
NSGraphicsContext.current = gc
let ctx = gc.cgContext
let space = CGColorSpaceCreateDeviceRGB()

func color(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat = 1) -> CGColor {
    CGColor(colorSpace: space, components: [r, g, b, a])!
}

func gradient(_ stops: [(CGColor, CGFloat)]) -> CGGradient {
    CGGradient(colorsSpace: space, colors: stops.map { $0.0 } as CFArray, locations: stops.map { $0.1 })!
}

/// Superelipse (n = 5) ≈ esquina continua de los iconos de Apple.
func squircle(_ r: CGRect, n: CGFloat = 5) -> CGPath {
    let p = CGMutablePath()
    let steps = 720
    for i in 0...steps {
        let t = CGFloat(i) / CGFloat(steps) * 2 * .pi
        let c = cos(t), s = sin(t)
        let x = r.midX + r.width / 2 * (c < 0 ? -1 : 1) * pow(abs(c), 2 / n)
        let y = r.midY + r.height / 2 * (s < 0 ? -1 : 1) * pow(abs(s), 2 / n)
        i == 0 ? p.move(to: CGPoint(x: x, y: y)) : p.addLine(to: CGPoint(x: x, y: y))
    }
    p.closeSubpath()
    return p
}

func rrect(_ r: CGRect, _ radius: CGFloat) -> CGPath {
    CGPath(roundedRect: r, cornerWidth: radius, cornerHeight: radius, transform: nil)
}

// Plantilla de macOS: cuerpo de 824 px centrado en un lienzo de 1024.
let body = CGRect(x: 100, y: 100, width: 824, height: 824)
let bodyPath = squircle(body)

// Sombra del icono.
ctx.saveGState()
ctx.setShadow(offset: CGSize(width: 0, height: -14), blur: 30, color: color(0, 0, 0, 0.45))
ctx.addPath(bodyPath)
ctx.setFillColor(color(0.04, 0.08, 0.26))
ctx.fillPath()
ctx.restoreGState()

// Fondo: capas planas con degradado suave, hechas con círculos (azul oscuro → blanco).
// Sin sombras ni bordes. Cada círculo tiene su radio y un desplazamiento lateral propio
// (alternando hacia las esquinas superior izquierda e inferior derecha) para que las curvas
// recorran todo el icono. El central (R = lado del icono, centro en la esquina inferior
// izquierda) tiene la curva de esquina a esquina.
ctx.saveGState()
ctx.addPath(bodyPath)
ctx.clip()

let corner = CGPoint(x: body.minX, y: body.minY)
let k2 = CGFloat(2).squareRoot() / 2
let diag = CGPoint(x: k2, y: k2)                    // hacia arriba a la derecha
let perp = CGPoint(x: -k2, y: k2)                   // hacia arriba a la izquierda
let diagLength: CGFloat = 1165
let gradientOptions: CGGradientDrawingOptions = [.drawsBeforeStartLocation, .drawsAfterEndLocation]

func pos(_ e: CGFloat) -> CGPoint {
    CGPoint(x: corner.x + diag.x * e, y: corner.y + diag.y * e)
}

// Base: blanco con un velo azul en la esquina.
ctx.drawLinearGradient(
    gradient([(color(1, 1, 1), 0), (color(0.88, 0.94, 1.0), 1)]),
    start: pos(1000), end: pos(diagLength), options: gradientOptions
)

struct Layer {
    let edge: CGFloat       // distancia a lo largo de la diagonal hasta la curva
    let radius: CGFloat
    let side: CGFloat       // desplazamiento lateral del centro (+ = hacia arriba a la izquierda)
    let from: CGColor       // color en la parte baja de la capa
    let to: CGColor         // color en el borde
}

// De la capa más externa/clara a la más interna/oscura (la oscura queda encima).
let layers: [Layer] = [
    Layer(edge: 1130, radius: 815, side: -15, from: color(0.88, 0.94, 1.0),  to: color(1, 1, 1)),
    Layer(edge: 1030, radius: 820, side: 20,  from: color(0.72, 0.84, 1.0),  to: color(0.93, 0.96, 1.0)),
    Layer(edge: 930,  radius: 815, side: -20, from: color(0.55, 0.72, 0.98), to: color(0.80, 0.89, 1.0)),
    Layer(edge: 824,  radius: 824, side: 0,   from: color(0.36, 0.54, 0.92), to: color(0.62, 0.76, 0.98)), // central
    Layer(edge: 700,  radius: 820, side: 20,  from: color(0.24, 0.41, 0.87), to: color(0.42, 0.60, 0.96)),
    Layer(edge: 570,  radius: 815, side: -15, from: color(0.17, 0.31, 0.72), to: color(0.28, 0.45, 0.88)),
    Layer(edge: 430,  radius: 810, side: 0,   from: color(0.10, 0.19, 0.50), to: color(0.20, 0.34, 0.74)),
]

for layer in layers {
    let base = pos(layer.edge - layer.radius)
    let c = CGPoint(x: base.x + perp.x * layer.side, y: base.y + perp.y * layer.side)
    ctx.saveGState()
    ctx.addEllipse(in: CGRect(x: c.x - layer.radius, y: c.y - layer.radius,
                              width: layer.radius * 2, height: layer.radius * 2))
    ctx.clip()
    ctx.drawLinearGradient(
        gradient([(layer.from, 0), (layer.to, 1)]),
        start: pos(layer.edge - 260), end: pos(layer.edge), options: gradientOptions
    )
    ctx.restoreGState()
}

// Brillo sutil de cristal arriba.
ctx.drawLinearGradient(
    gradient([(color(1, 1, 1, 0.08), 0), (color(1, 1, 1, 0), 1)]),
    start: CGPoint(x: 512, y: body.maxY), end: CGPoint(x: 512, y: body.midY + 120), options: []
)
ctx.restoreGState()

// Keycap.
let cap = CGRect(x: 277, y: 271, width: 470, height: 482)
ctx.saveGState()
ctx.setShadow(offset: CGSize(width: 0, height: -26), blur: 46, color: color(0, 0, 0, 0.6))
ctx.addPath(rrect(cap, 102))
ctx.setFillColor(color(0.6, 0.6, 0.66))
ctx.fillPath()
ctx.restoreGState()

// Cuerpo / costado de la tecla.
ctx.saveGState()
ctx.addPath(rrect(cap, 102))
ctx.clip()
ctx.drawLinearGradient(
    gradient([(color(0.93, 0.94, 0.97), 0), (color(0.52, 0.53, 0.60), 1)]),
    start: CGPoint(x: 500, y: cap.maxY), end: CGPoint(x: 500, y: cap.minY), options: []
)
ctx.restoreGState()

// Cara superior (más alta y con borde inferior grueso para dar profundidad).
let face = CGRect(x: cap.minX + 24, y: cap.minY + 50, width: cap.width - 48, height: cap.height - 50 - 24)
ctx.saveGState()
ctx.addPath(rrect(face, 80))
ctx.clip()
ctx.drawLinearGradient(
    gradient([(color(1, 1, 1), 0), (color(0.89, 0.90, 0.95), 1)]),
    start: CGPoint(x: 500, y: face.maxY), end: CGPoint(x: 500, y: face.minY), options: []
)
ctx.restoreGState()

// Escobeta grafito vertical sobre la cara.
func roundedPoly(_ pts: [CGPoint], _ radius: CGFloat) -> CGPath {
    let p = CGMutablePath()
    let n = pts.count
    p.move(to: CGPoint(x: (pts[0].x + pts[n - 1].x) / 2, y: (pts[0].y + pts[n - 1].y) / 2))
    for i in 0..<n {
        p.addArc(tangent1End: pts[i], tangent2End: pts[(i + 1) % n], radius: radius)
    }
    p.closeSubpath()
    return p
}

func fillGraphite(_ path: CGPath) {
    ctx.saveGState()
    ctx.addPath(path)
    ctx.clip()
    ctx.drawLinearGradient(
        gradient([(color(0.32, 0.33, 0.38), 0), (color(0.13, 0.14, 0.17), 1)]),
        start: CGPoint(x: 0, y: 140), end: CGPoint(x: 0, y: -132), options: []
    )
    ctx.restoreGState()
}

ctx.saveGState()
ctx.translateBy(x: face.midX, y: face.midY + 4)
ctx.scaleBy(x: 1.05, y: 1.05)
ctx.translateBy(x: 0, y: -4)

fillGraphite(rrect(CGRect(x: -17, y: 40, width: 34, height: 100), 17))            // mango
fillGraphite(rrect(CGRect(x: -56, y: -2, width: 112, height: 58), 24))            // cabeza
fillGraphite(roundedPoly([                                                          // cerdas
    CGPoint(x: -58, y: -16), CGPoint(x: 58, y: -16),
    CGPoint(x: 84, y: -132), CGPoint(x: -84, y: -132),
], 16))

// Ranuras de las cerdas.
ctx.setStrokeColor(color(0.93, 0.94, 0.97))
ctx.setLineWidth(10)
ctx.setLineCap(.round)
for sx: CGFloat in [-1, 1] {
    ctx.move(to: CGPoint(x: sx * 30, y: -54))
    ctx.addLine(to: CGPoint(x: sx * 38, y: -114))
    ctx.strokePath()
}
ctx.restoreGState()

// Borde interior sutil del icono.
ctx.saveGState()
ctx.addPath(squircle(body.insetBy(dx: 1.5, dy: 1.5)))
ctx.setLineWidth(3)
ctx.replacePathWithStrokedPath()
ctx.clip()
ctx.drawLinearGradient(
    gradient([(color(1, 1, 1, 0.35), 0), (color(1, 1, 1, 0.04), 1)]),
    start: CGPoint(x: 512, y: body.maxY), end: CGPoint(x: 512, y: body.minY), options: []
)
ctx.restoreGState()

let png = rep.representation(using: .png, properties: [:])!
try png.write(to: URL(fileURLWithPath: CommandLine.arguments[1]))
