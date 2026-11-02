import Foundation

enum Config {
    /// Segundos que hay que mantener presionado el botón para salir.
    static let holdDuration: TimeInterval = 3
    /// Cantidad de ⌘Q consecutivos necesarios para salir.
    static let quitPressesRequired = 3
    /// Si pasan más de estos segundos entre dos ⌘Q, el conteo vuelve a cero.
    static let quitDebounce: TimeInterval = 1.5
    static let defaultTimeoutMinutes: Double = 15
    /// Factor de escala global de la UI del overlay.
    static let uiScale: CGFloat = 1.15

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
