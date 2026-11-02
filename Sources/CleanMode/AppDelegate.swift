import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    private let lock = LockController()
    private let onboarding = OnboardingController()
    private var allowTerminate = false

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Herramienta de desarrollo: genera las capturas del README y sale. No bloquea nada.
        if let arg = CommandLine.arguments.first(where: { $0.hasPrefix("--render-docs=") }) {
            DocsRenderer.run(outputDirectory: String(arg.dropFirst("--render-docs=".count)))
            return
        }

        lock.onFinish = { [weak self] in self?.quit() }
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

    private func quit() {
        allowTerminate = true
        NSApp.terminate(nil)
    }
}
