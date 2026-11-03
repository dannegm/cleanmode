import AppKit
import SwiftUI

/// Ventana de bienvenida que explica el permiso de Accesibilidad, vigila que quede activo
/// y verifica que el bloqueo funcione de verdad. Al estar todo listo, avisa con onReady.
final class OnboardingController: NSObject, NSWindowDelegate {
    var onReady: (() -> Void)?
    var onCancel: (() -> Void)?

    private let model = PermissionModel()
    private var window: NSWindow?
    private var timer: Timer?
    private var finishing = false
    private let startedAt = Date()

    func show() {
        let host = NSHostingView(rootView: OnboardingView(model: model) {
            Permissions.requestAndOpenSettings()
        })
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 500, height: 620),
            styleMask: [.titled, .closable, .fullSizeContentView],
            backing: .buffered, defer: false
        )
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        // Ventana de aviso: el semáforo se ve completo, pero zoom y minimizar no hacen nada (desactivados); solo cierra.
        window.standardWindowButton(.zoomButton)?.isEnabled = false
        window.standardWindowButton(.miniaturizeButton)?.isEnabled = false
        window.collectionBehavior = [.fullScreenNone]
        window.isMovableByWindowBackground = true
        window.isReleasedWhenClosed = false
        window.delegate = self
        window.contentView = host
        window.center()
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        self.window = window

        poll()
        let timer = Timer(timeInterval: 1, repeats: true) { [weak self] _ in self?.poll() }
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }

    private func poll() {
        guard !finishing else { return }
        let granted = Permissions.accessibilityGranted
        let ready = granted && Permissions.eventTapReady
        model.accessibilityGranted = granted
        model.tapReady = ready
        model.showHint = !granted && Date().timeIntervalSince(startedAt) > 12

        if ready {
            finishing = true
            timer?.invalidate()
            timer = nil
            // Trae la ventana al frente para que se vea el "Todo listo" antes de abrir.
            NSApp.activate(ignoringOtherApps: true)
            window?.orderFrontRegardless()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) { [weak self] in
                self?.window?.close()
                self?.window = nil
                self?.onReady?()
            }
        }
    }

    func windowWillClose(_ notification: Notification) {
        guard !finishing else { return }
        timer?.invalidate()
        timer = nil
        onCancel?()
    }
}
