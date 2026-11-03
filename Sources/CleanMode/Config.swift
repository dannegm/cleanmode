import AppKit
import Foundation

enum Config {
    /// Segundos que hay que mantener presionado el botón para salir.
    static let holdDuration: TimeInterval = 3
    /// Cantidad de ⌘Q consecutivos necesarios para salir.
    static let quitPressesRequired = 3
    /// Si pasan más de estos segundos entre dos ⌘Q, el conteo vuelve a cero.
    static let quitDebounce: TimeInterval = 1.5
    static let defaultTimeoutMinutes: Double = 15
    /// Enlace de donación (PayPal).
    static let donationURL = "https://www.paypal.me/dannegm"

    /// Cada cuántas limpiezas (terminadas por el usuario) se muestra el recordatorio de donación.
    /// 0 lo desactiva. Se cambia con `defaults write im.dnn.cleanmode donationReminderEvery -int N`
    /// o, para probar, con el argumento `--donation-every=N`.
    static var donationReminderEvery: Int {
        var n = 10
        if let v = UserDefaults.standard.object(forKey: "donationReminderEvery") as? NSNumber { n = v.intValue }
        for arg in CommandLine.arguments where arg.hasPrefix("--donation-every=") {
            if let v = Int(arg.dropFirst("--donation-every=".count)) { n = v }
        }
        return n
    }

    /// Factor de escala de la UI del overlay: 1.5 por defecto. En pantallas bajas se reduce solo para que
    /// el contenido, el subtítulo de ⌘Q y el pie quepan sin encimarse (en 1280×720 queda en 1.44).
    /// Usa la pantalla más baja conectada, porque el contenido puede aparecer en cualquiera.
    static var uiScale: CGFloat {
        if let uiScaleOverride { return uiScaleOverride }
        let lowest = NSScreen.screens.map { $0.frame.height }.min() ?? 900
        return min(1.5, lowest / 500)
    }

    /// Solo para generar capturas de la documentación (`--render-docs`).
    static var uiScaleOverride: CGFloat?

    /// Tiempo máximo de bloqueo en segundos; nil = sin límite (minutos <= 0).
    /// Prioridad (de menor a mayor):
    ///   - default 15 min
    ///   - defaults write im.dnn.cleanmode timeoutMinutes -int 20
    ///   - variable de entorno CLEANMODE_TIMEOUT_MINUTES
    ///   - argumento --timeout=<minutos>  (open build/CleanMode.app --args --timeout=1)
    static var timeoutSeconds: TimeInterval? {
        var minutes = defaultTimeoutMinutes
        if let v = UserDefaults.standard.object(forKey: "timeoutMinutes") as? NSNumber {
            minutes = v.doubleValue
        }
        if let env = ProcessInfo.processInfo.environment["CLEANMODE_TIMEOUT_MINUTES"],
           let v = Double(env) {
            minutes = v
        }
        for arg in CommandLine.arguments where arg.hasPrefix("--timeout=") {
            if let v = Double(arg.dropFirst("--timeout=".count)) { minutes = v }
        }
        return minutes > 0 ? minutes * 60 : nil
    }
}
