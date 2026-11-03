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

    /// Factor de las medidas de la UI del overlay. Es **fijo** y igual en todas las pantallas: son las medidas
    /// calibradas para 1280×720 (título 30.2 pt, pie 15.8 pt, subtítulo 28.8 pt). La descripción (18 pt) y el contador (16 pt)
    /// tienen tamaño fijo propio, sin multiplicar por este factor.
    static let uiScale: CGFloat = 1.44

    /// Escala del botón de mantener presionado. Se quedó en el tamaño que tenía antes de subir el resto de la UI a 1.5
    /// (280×48 pt a escala 1.15 = unos 322×55 pt).
    static let holdButtonScale: CGFloat = 1.15

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
