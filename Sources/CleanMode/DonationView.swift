import SwiftUI
import AppKit

struct DonationView: View {
    enum Choice { case donate, later, never }
    let onChoice: (Choice) -> Void

    var body: some View {
        VStack(spacing: 0) {
            Image(systemName: "heart.fill")
                .font(.system(size: 40))
                .foregroundStyle(Color(red: 1.0, green: 0.27, blue: 0.40))
                .padding(.top, 48)

            Text(L10n.t("don.title"))
                .font(.system(size: 20, weight: .semibold))
                .padding(.top, 16)

            Text(L10n.t("don.body"))
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: 320)
                .padding(.top, 8)

            Spacer(minLength: 20)

            Button { onChoice(.donate) } label: {
                Text(L10n.t("don.donate"))
                    .font(.system(size: 14, weight: .medium))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .frame(width: 240)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)

            HStack(spacing: 20) {
                Button(L10n.t("don.later")) { onChoice(.later) }
                Button(L10n.t("don.never")) { onChoice(.never) }
            }
            .buttonStyle(.plain)
            .font(.system(size: 12))
            .foregroundStyle(.secondary)
            .padding(.top, 14)
            .padding(.bottom, 28)
        }
        .frame(width: 440, height: 340)
        .environment(\.layoutDirection, L10n.isRTL ? .rightToLeft : .leftToRight)
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
            contentRect: NSRect(x: 0, y: 0, width: 440, height: 340),
            styleMask: [.titled, .closable, .fullSizeContentView],
            backing: .buffered, defer: false
        )
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
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
