import Foundation

/// Recordatorio de donación, discreto y descartable. Todo es local: solo guarda tres números/banderas
/// en UserDefaults (sesiones terminadas, cuándo volver a recordar, si el usuario pidió no recordar más).
/// Nunca hace peticiones de red: el enlace se abre en el navegador solo si el usuario pulsa «Donar».
enum DonationReminder {
    private static let sessionsKey = "donationSessions"
    private static let nextKey = "donationNextAt"
    private static let optOutKey = "donationOptOut"
    private static let defaults = UserDefaults.standard

    static var isAvailable: Bool {
        guard let url = URL(string: Config.donationURL), url.host != nil else { return false }
        return Config.donationReminderEvery > 0
    }

    /// Cuenta una sesión terminada y dice si toca mostrar el recordatorio.
    /// Las sesiones cerradas por el timeout cuentan, pero no muestran el aviso (el usuario no estaba).
    static func registerSession(userInitiated: Bool) -> Bool {
        let sessions = defaults.integer(forKey: sessionsKey) + 1
        defaults.set(sessions, forKey: sessionsKey)
        guard isAvailable, userInitiated, !defaults.bool(forKey: optOutKey) else { return false }
        let nextAt = (defaults.object(forKey: nextKey) as? Int) ?? Config.donationReminderEvery
        return sessions >= nextAt
    }

    /// «Quizás después» (o cerrar la ventana): vuelve a preguntar tras otras N sesiones.
    static func snooze() { schedule(after: Config.donationReminderEvery) }

    /// Tras donar: no vuelve a preguntar en un buen rato.
    static func donated() { schedule(after: Config.donationReminderEvery * 5) }

    /// «No volver a mostrar».
    static func optOut() { defaults.set(true, forKey: optOutKey) }

    private static func schedule(after n: Int) {
        defaults.set(defaults.integer(forKey: sessionsKey) + max(n, 1), forKey: nextKey)
        defaults.synchronize()
    }
}
