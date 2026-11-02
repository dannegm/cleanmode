import AppKit
import CoreGraphics

/// Intercepta y descarta todo el teclado (incluidas teclas especiales y gestos)
/// mediante un CGEventTap activo. Requiere permiso de Accesibilidad.
/// Además cuenta ⌘Q consecutivos con debounce como salida de emergencia.
final class KeyboardBlocker {
    var onQuitProgress: ((Int) -> Void)?
    var onQuitTriggered: (() -> Void)?

    private var tap: CFMachPort?
    private var source: CFRunLoopSource?
    private var quitCount = 0
    private var resetTimer: Timer?

    func start() -> Bool {
        var mask: CGEventMask = 0
        for type in [CGEventType.keyDown, .keyUp, .flagsChanged] {
            mask |= CGEventMask(1) << CGEventMask(type.rawValue)
        }
        // 14 = NX_SYSDEFINED (volumen, brillo, multimedia); 18–20, 29–32 = gestos del trackpad.
        for raw in [14, 18, 19, 20, 29, 30, 31, 32] as [UInt64] {
            mask |= CGEventMask(1) << raw
        }

        let refcon = Unmanaged.passUnretained(self).toOpaque()
        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: mask,
            callback: keyboardTapCallback,
            userInfo: refcon
        ) else { return false }

        let source = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        CFRunLoopAddSource(CFRunLoopGetMain(), source, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)
        self.tap = tap
        self.source = source
        return true
    }

    func stop() {
        resetTimer?.invalidate()
        resetTimer = nil
        if let tap {
            CGEvent.tapEnable(tap: tap, enable: false)
            CFMachPortInvalidate(tap)
        }
        if let source {
            CFRunLoopRemoveSource(CFRunLoopGetMain(), source, .commonModes)
        }
        tap = nil
        source = nil
    }

    fileprivate func handle(type: CGEventType, event: CGEvent) -> Unmanaged<CGEvent>? {
        switch type {
        case .tapDisabledByTimeout, .tapDisabledByUserInput:
            if let tap { CGEvent.tapEnable(tap: tap, enable: true) }
            return Unmanaged.passUnretained(event)
        case .keyDown:
            let isRepeat = event.getIntegerValueField(.keyboardEventAutorepeat) != 0
            let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
            if !isRepeat, keyCode == 12, event.flags.contains(.maskCommand) { // 12 = Q
                registerQuitPress()
            }
            return nil
        default:
            return nil
        }
    }

    private func registerQuitPress() {
        quitCount += 1
        resetTimer?.invalidate()

        if quitCount >= Config.quitPressesRequired {
            quitCount = 0
            onQuitTriggered?()
            return
        }

        onQuitProgress?(quitCount)
        let timer = Timer(timeInterval: Config.quitDebounce, repeats: false) { [weak self] _ in
            self?.quitCount = 0
            self?.onQuitProgress?(0)
        }
        RunLoop.main.add(timer, forMode: .common)
        resetTimer = timer
    }
}

private func keyboardTapCallback(
    proxy: CGEventTapProxy,
    type: CGEventType,
    event: CGEvent,
    refcon: UnsafeMutableRawPointer?
) -> Unmanaged<CGEvent>? {
    guard let refcon else { return Unmanaged.passUnretained(event) }
    let blocker = Unmanaged<KeyboardBlocker>.fromOpaque(refcon).takeUnretainedValue()
    return blocker.handle(type: type, event: event)
}
