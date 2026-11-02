import AppKit

/// Estela de puntos que sigue la trayectoria real del cursor.
/// Se graba el recorrido y cada punto muestra dónde estaba el cursor hace `lag` segundos
/// (cada uno un poco más atrás). Así la cola recorre exactamente el mismo camino que la cabeza,
/// sin el efecto de "látigo" de las cadenas con lerp.
/// No intercepta eventos: los clics pasan a la vista de abajo.
final class CursorTrailView: NSView {
    private let count = 22                // puntos de la estela
    private let lag: CFTimeInterval = 0.014   // retraso entre puntos consecutivos (≈ 0.3 s en total)
    private let head: CGFloat = 24        // diámetro de la cabeza
    private let taper: CGFloat = 0.72     // 0 = todos iguales, 1 = la cola desaparece
    private let smoothing: CGFloat = 0.55 // suavizado final por punto (quita esquinas)

    private struct Sample { let time: CFTimeInterval; let point: CGPoint }

    private var nodes: [CALayer] = []
    private var shown: [CGPoint] = []
    private var samples: [Sample] = []
    private var primed = false
    private var timer: Timer?

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        buildNodes()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) no implementado") }

    override func hitTest(_ point: NSPoint) -> NSView? { nil }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        window == nil ? stop() : start()
    }

    private func buildNodes() {
        shown = Array(repeating: .zero, count: count)
        for i in 0..<count {
            let t = CGFloat(i) / CGFloat(count - 1)
            let size = head * (1 - t * taper)
            let layer = CALayer()
            layer.bounds = CGRect(x: 0, y: 0, width: size, height: size)
            layer.cornerRadius = size / 2
            layer.backgroundColor = NSColor.white.withAlphaComponent(1 - t * 0.8).cgColor
            nodes.append(layer)
        }
        // De la cola a la cabeza, para que la cabeza quede por encima.
        for layer in nodes.reversed() { self.layer?.addSublayer(layer) }
    }

    private func start() {
        guard timer == nil else { return }
        let t = Timer(timeInterval: 1.0 / 60.0, repeats: true) { [weak self] _ in self?.tick() }
        RunLoop.main.add(t, forMode: .common)
        timer = t
    }

    private func stop() {
        timer?.invalidate()
        timer = nil
    }

    /// Posición del cursor hace `age` segundos, interpolada entre muestras.
    private func position(secondsAgo age: CFTimeInterval, now: CFTimeInterval) -> CGPoint {
        let target = now - age
        guard let first = samples.first else { return .zero }
        if target <= first.time { return first.point }
        var i = samples.count - 1
        while i > 0, samples[i - 1].time > target { i -= 1 }
        // samples[i-1].time <= target < samples[i].time  (o target >= último)
        guard i > 0 else { return first.point }
        let a = samples[i - 1], b = samples[i]
        let span = b.time - a.time
        guard span > 0 else { return b.point }
        let f = CGFloat(min(max((target - a.time) / span, 0), 1))
        return CGPoint(x: a.point.x + (b.point.x - a.point.x) * f,
                       y: a.point.y + (b.point.y - a.point.y) * f)
    }

    private func tick() {
        guard let window else { return }
        let pointer = convert(window.convertPoint(fromScreen: NSEvent.mouseLocation), from: nil)
        let now = CACurrentMediaTime()

        samples.append(Sample(time: now, point: pointer))
        let keepFrom = now - (CFTimeInterval(count) * lag + 0.2)
        if let firstKept = samples.firstIndex(where: { $0.time >= keepFrom }), firstKept > 1 {
            samples.removeFirst(firstKept - 1)
        }

        if !primed {
            shown = Array(repeating: pointer, count: count)
            primed = true
        }

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        for i in 0..<count {
            let target = position(secondsAgo: CFTimeInterval(i) * lag, now: now)
            shown[i].x += (target.x - shown[i].x) * smoothing
            shown[i].y += (target.y - shown[i].y) * smoothing
            nodes[i].position = shown[i]
        }
        CATransaction.commit()
    }
}
