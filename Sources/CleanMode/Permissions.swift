import AppKit
import ApplicationServices

enum Permissions {
    /// ¿Tiene la app el permiso de Accesibilidad? (no muestra ningún aviso)
    static var accessibilityGranted: Bool { AXIsProcessTrusted() }

    /// Comprueba que macOS realmente deja crear el bloqueo de teclado.
    /// Solo se prueba si Accesibilidad ya figura como concedida, para no provocar avisos.
    static var eventTapReady: Bool {
        guard accessibilityGranted else { return false }
        let mask = CGEventMask(1) << CGEventMask(CGEventType.keyDown.rawValue)
        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: mask,
            callback: { _, _, event, _ in Unmanaged.passUnretained(event) },
            userInfo: nil
        ) else { return false }
        CFMachPortInvalidate(tap)
        return true
    }

    static var isReady: Bool { accessibilityGranted && eventTapReady }

    /// Registra la app en la lista de Accesibilidad (macOS muestra su aviso) y abre los Ajustes.
    static func requestAndOpenSettings() {
        _ = AXIsProcessTrustedWithOptions(["AXTrustedCheckOptionPrompt": true] as CFDictionary)
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
            NSWorkspace.shared.open(url)
        }
    }
}
