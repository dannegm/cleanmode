import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    private let lock = LockController()
    private let onboarding = OnboardingController()
    private let donation = DonationController()
    private var allowTerminate = false

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Herramienta de desarrollo: genera las capturas del README y sale. No bloquea nada.
        if let arg = CommandLine.arguments.first(where: { $0.hasPrefix("--render-docs=") }) {
            DocsRenderer.run(outputDirectory: String(arg.dropFirst("--render-docs=".count)))
            return
        }

        lock.onFinish = { [weak self] reason in self?.sessionFinished(reason) }
        onboarding.onReady = { [weak self] in self?.startLock() }
        onboarding.onCancel = { [weak self] in self?.quit() }

        // Si el permiso ya está activo y verificado, abre directo; si no, onboarding.
        if Permissions.isReady {
            startLock()
        } else {
            onboarding.show()
        }
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        allowTerminate ? .terminateNow : .terminateCancel
    }

    private func startLock() {
        // start() solo devuelve false si el bloqueo de teclado no se pudo crear (antes de tocar nada).
        if !lock.start() {
            onboarding.show()
        }
    }

    /// Al terminar la limpieza: si toca, muestra el recordatorio de donación (una ventana pequeña y
    /// descartable) antes de salir. Nunca aparece durante el bloqueo ni tras un cierre automático.
    private func sessionFinished(_ reason: LockController.ExitReason) {
        let remind = DonationReminder.registerSession(userInitiated: reason != .timeout)
        guard remind else { quit(); return }
        donation.onDismiss = { [weak self] in self?.quit() }
        donation.show()
    }

    private func quit() {
        allowTerminate = true
        NSApp.terminate(nil)
    }
}
