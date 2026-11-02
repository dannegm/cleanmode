import AppKit
import SwiftUI
import IOKit.pwr_mgt

final class OverlayWindow: NSWindow {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}

/// Orquesta el bloqueo: ventanas, teclado, cursor, opciones de presentación,
/// anti-suspensión y salidas (botón, ⌘Q x3, timeout).
final class LockController {
    /// Cómo terminó la sesión (el recordatorio de donación solo aparece si el usuario salió por sí mismo).
    enum ExitReason { case button, keyboard, timeout }

    var onFinish: ((ExitReason) -> Void)?

    private let model = LockModel()
    private let keyboard = KeyboardBlocker()
    private var windows: [OverlayWindow] = []
    private var sleepAssertion = IOPMAssertionID(0)
    private var countdown: Timer?
    private var deadline: Date?
    private var screenObserver: NSObjectProtocol?
    private var locked = false

    /// Devuelve false si no se pudo bloquear el teclado (falta permiso de Accesibilidad).
    func start() -> Bool {
        keyboard.onQuitProgress = { [weak self] count in
            guard count > 0 else { return } // el reinicio del conteo lo refleja el fade del subtítulo
            self?.model.quitPresses = count
            self?.model.quitPulse += 1
        }
        keyboard.onQuitTriggered = { [weak self] in self?.unlock(reason: .keyboard) }
        guard keyboard.start() else { return false }
        locked = true

        NSApp.activate(ignoringOtherApps: true)
        NSApp.presentationOptions = [
            .hideDock, .hideMenuBar, .disableProcessSwitching, .disableForceQuit,
            .disableSessionTermination, .disableHideApplication, .disableAppleMenu,
        ]
        rebuildWindows()
        CGDisplayHideCursor(CGMainDisplayID())
        NSCursor.hide()
        beginSleepAssertion()
        startCountdown()

        screenObserver = NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification,
            object: nil, queue: .main
        ) { [weak self] _ in self?.rebuildWindows() }
        return true
    }

    func unlock(reason: ExitReason) {
        guard locked else { return }
        locked = false

        countdown?.invalidate()
        countdown = nil
        keyboard.stop()
        if let screenObserver { NotificationCenter.default.removeObserver(screenObserver) }
        screenObserver = nil
        if sleepAssertion != 0 { IOPMAssertionRelease(sleepAssertion) }
        NSApp.presentationOptions = []
        CGDisplayShowCursor(CGMainDisplayID())
        NSCursor.unhide()
        closeWindows()
        onFinish?(reason)
    }

    // MARK: - Ventanas

    private func rebuildWindows() {
        closeWindows()
        let mouse = NSEvent.mouseLocation
        let contentScreen = NSScreen.screens.first { NSMouseInRect(mouse, $0.frame, false) }
            ?? NSScreen.screens.first

        var keyWindow: OverlayWindow?
        for screen in NSScreen.screens {
            let isContent = screen == contentScreen
            let window = makeWindow(for: screen, showsContent: isContent)
            windows.append(window)
            if isContent { keyWindow = window } else { window.orderFrontRegardless() }
        }
        keyWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    private func closeWindows() {
        for window in windows {
            window.orderOut(nil)
            window.close()
        }
        windows.removeAll()
    }

    private func makeWindow(for screen: NSScreen, showsContent: Bool) -> OverlayWindow {
        let window = OverlayWindow(
            contentRect: NSRect(origin: .zero, size: screen.frame.size),
            styleMask: [.borderless], backing: .buffered, defer: false
        )
        window.setFrame(screen.frame, display: true)
        window.level = NSWindow.Level(rawValue: Int(CGShieldingWindowLevel()))
        window.backgroundColor = .black
        window.isOpaque = true
        window.hasShadow = false
        window.isReleasedWhenClosed = false
        window.collectionBehavior = [.canJoinAllSpaces, .stationary, .fullScreenAuxiliary, .ignoresCycle]

        let container = NSView(frame: NSRect(origin: .zero, size: screen.frame.size))
        container.wantsLayer = true

        let host = NSHostingView(rootView: OverlayView(
            model: model, showsContent: showsContent, onExit: { [weak self] in self?.unlock(reason: .button) }
        ))
        host.frame = container.bounds
        host.autoresizingMask = [.width, .height]

        let trail = CursorTrailView(frame: container.bounds)
        trail.autoresizingMask = [.width, .height]

        container.addSubview(host)
        container.addSubview(trail)
        window.contentView = container
        return window
    }

    // MARK: - Anti-suspensión y timeout

    private func beginSleepAssertion() {
        IOPMAssertionCreateWithName(
            kIOPMAssertionTypeNoDisplaySleep as CFString,
            IOPMAssertionLevel(kIOPMAssertionLevelOn),
            "Clean Mode" as CFString,
            &sleepAssertion
        )
    }

    private func startCountdown() {
        guard let seconds = Config.timeoutSeconds else { return }
        deadline = Date().addingTimeInterval(seconds)
        model.remainingSeconds = Int(seconds)
        let timer = Timer(timeInterval: 1, repeats: true) { [weak self] _ in self?.tickCountdown() }
        RunLoop.main.add(timer, forMode: .common)
        countdown = timer
    }

    private func tickCountdown() {
        guard let deadline else { return }
        let remaining = Int(ceil(deadline.timeIntervalSinceNow))
        if remaining <= 0 {
            unlock(reason: .timeout)
        } else {
            model.remainingSeconds = remaining
        }
    }
}
