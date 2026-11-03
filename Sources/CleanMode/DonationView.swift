import SwiftUI
import AppKit

struct DonationView: View {
    enum Choice { case donate, later, never }

    /// Tamaño de la ventana (lo usan el controlador y el renderizador de capturas).
    static let size = CGSize(width: 460, height: 340)

    let onChoice: (Choice) -> Void

    var body: some View {
        VStack(spacing: 0) {
            Image(systemName: "heart.fill")
                .font(.system(size: 38))
                .foregroundStyle(Color(red: 1.0, green: 0.27, blue: 0.40))
                .padding(.top, 38)

            Text(L10n.t("don.title"))
                .font(.system(size: 21, weight: .semibold))
                .padding(.top, 12)

            Text(L10n.t("don.body"))
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: 340)
                .padding(.top, 8)

            Spacer(minLength: 14)

            VStack(spacing: 10) {
                // Acción principal (cápsula con relleno de color). Intro = donar.
                Button { onChoice(.donate) } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "heart.fill")
                        Text(L10n.t("don.donate")).lineLimit(1)
                    }
                    .font(.system(size: 15, weight: .semibold))
                }
                .buttonStyle(PillButtonStyle(kind: .primary))
                .keyboardShortcut(.defaultAction)

                // Jerarquía de tres niveles: donar (principal) > ahorita no (secundario, con relleno suave) > no recordar
                // (terciario: sin relleno y más discreto, pero legible y con la misma zona de clic). Esc = más tarde.
                VStack(spacing: 6) {
                    pillButton(L10n.t("don.later"), systemImage: "clock", kind: .secondary) { onChoice(.later) }
                        .keyboardShortcut(.cancelAction)
                    pillButton(L10n.t("don.never"), systemImage: "bell.slash", kind: .tertiary) { onChoice(.never) }
                }
            }
            .padding(.bottom, 22)
        }
        .frame(width: Self.size.width, height: Self.size.height)
        .environment(\.layoutDirection, L10n.isRTL ? .rightToLeft : .leftToRight)
    }

    /// Botón de salida: la misma cápsula, en versión secundaria (relleno suave) o terciaria (sin relleno, más discreta).
    private func pillButton(_ title: String, systemImage: String, kind: PillButtonStyle.Kind,
                            action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: systemImage)
                Text(title).lineLimit(1)
            }
            .font(.system(size: kind == .tertiary ? 11.5 : 12, weight: kind == .tertiary ? .regular : .medium))
        }
        .buttonStyle(PillButtonStyle(kind: kind))
    }
}

/// Cápsula totalmente redondeada que se ajusta a su contenido. Un único estilo para todos los botones de la ventana,
/// dibujado a mano para que se vea igual en cualquier versión de macOS (y en las capturas).
struct PillButtonStyle: ButtonStyle {
    enum Kind { case primary, secondary, tertiary }

    let kind: Kind
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(foreground)
            .padding(.horizontal, kind == .primary ? 26 : 16)
            .padding(.vertical, kind == .primary ? 11 : 6)
            .background(Capsule().fill(fill(pressed: configuration.isPressed)))
            .contentShape(Capsule())
            .opacity(isEnabled ? 1 : 0.5)
    }

    private var foreground: Color {
        switch kind {
        case .primary: return Color.white
        case .secondary: return Color.primary
        case .tertiary: return Color.primary.opacity(0.68)   // discreto, pero con buen contraste
        }
    }

    private func fill(pressed: Bool) -> Color {
        switch kind {
        case .primary: return Color.accentColor.opacity(pressed ? 0.78 : 1)
        case .secondary: return Color.primary.opacity(pressed ? 0.20 : 0.10)
        case .tertiary: return Color.primary.opacity(pressed ? 0.10 : 0)   // sin relleno; al presionar se marca
        }
    }
}

/// Ventana del recordatorio de donación. Cerrarla con el botón rojo equivale a «Quizás después».
final class DonationController: NSObject, NSWindowDelegate {
    var onDismiss: (() -> Void)?

    private var window: NSWindow?
    private var finished = false

    func show() {
        let host = NSHostingView(rootView: DonationView { [weak self] choice in self?.handle(choice) })
        let window = NSWindow(
            contentRect: NSRect(origin: .zero, size: DonationView.size),
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
    }

    private func handle(_ choice: DonationView.Choice) {
        switch choice {
        case .donate:
            DonationReminder.donated()
            if let url = URL(string: Config.donationURL) { NSWorkspace.shared.open(url) }
        case .later:
            DonationReminder.snooze()
        case .never:
            DonationReminder.optOut()
        }
        guard !finished else { return }
        finished = true
        window?.close()
        window = nil
        onDismiss?()
    }

    func windowWillClose(_ notification: Notification) {
        guard !finished else { return }
        finished = true
        DonationReminder.snooze()
        onDismiss?()
    }
}
