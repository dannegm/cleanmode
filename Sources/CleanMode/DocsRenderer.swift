import SwiftUI
import AppKit

/// Genera las capturas del README sin bloquear nada ni pedir permisos:
///   build/CleanMode.app/Contents/MacOS/CleanMode --render-docs=docs/screenshots
/// Dibuja las vistas reales de SwiftUI en PNG. (La estela del cursor es una vista de AppKit,
/// por eso no aparece en las capturas.)
enum DocsRenderer {
    static func run(outputDirectory: String) {
        Task { @MainActor in
            let dir = URL(fileURLWithPath: outputDirectory, isDirectory: true)
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)

            // Tamaño de la pantalla simulada (por defecto 1440×900); `--render-size=1280x720` para probar pantallas bajas.
            var lockSize = CGSize(width: 1440, height: 900)
            if let arg = CommandLine.arguments.first(where: { $0.hasPrefix("--render-size=") }) {
                let parts = arg.dropFirst("--render-size=".count).split(separator: "x").compactMap { Double($0) }
                if parts.count == 2 { lockSize = CGSize(width: parts[0], height: parts[1]) }
            }

            render(lockScreen, size: lockSize, to: dir.appendingPathComponent("lock.png"))
            render(onboarding(dark: false), size: CGSize(width: 560, height: 680), to: dir.appendingPathComponent("onboarding-light.png"))
            render(onboarding(dark: true), size: CGSize(width: 560, height: 680), to: dir.appendingPathComponent("onboarding-dark.png"))

            let donationSize = CGSize(width: DonationView.size.width + 60, height: DonationView.size.height + 60)
            render(donation(dark: false), size: donationSize, to: dir.appendingPathComponent("donation-light.png"))
            render(donation(dark: true), size: donationSize, to: dir.appendingPathComponent("donation-dark.png"))
            exit(0)
        }
    }

    @MainActor
    private static func render<V: View>(_ view: V, size: CGSize, to url: URL) {
        let renderer = ImageRenderer(content: view.frame(width: size.width, height: size.height))
        renderer.scale = 2
        guard let image = renderer.nsImage,
              let tiff = image.tiffRepresentation,
              let rep = NSBitmapImageRep(data: tiff),
              let png = rep.representation(using: .png, properties: [:])
        else {
            print("No se pudo renderizar \(url.lastPathComponent)")
            return
        }
        do {
            try png.write(to: url)
            print("Listo: \(url.path)")
        } catch {
            print("No se pudo escribir \(url.lastPathComponent): \(error)")
        }
    }

    // MARK: - Pantalla de bloqueo

    @MainActor
    private static var lockScreen: some View {
        let model = LockModel()
        model.remainingSeconds = 14 * 60 + 32
        return OverlayView(model: model, showsContent: true, onExit: {}, preview: true)
    }

    // MARK: - Ventanas (onboarding y donación)

    /// Ventana estilo macOS (sombra solo en la forma, borde y semáforo) alrededor de una vista.
    @MainActor
    private static func appWindow<Content: View>(dark: Bool, size: CGSize, @ViewBuilder content: () -> Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: 14, style: .continuous)
        return ZStack {
            // La sombra va solo en la forma de la ventana (no en su contenido).
            shape
                .fill(dark ? Color(white: 0.17) : Color(white: 0.96))
                .shadow(color: Color.black.opacity(0.28), radius: 22, y: 10)
            content()
                .clipShape(shape)
            shape.strokeBorder(Color.primary.opacity(0.14), lineWidth: 1)
        }
        .frame(width: size.width, height: size.height)
        .overlay(alignment: .topLeading) {
            // Semáforo completo, de colores (en la ventana real solo cerrar hace algo).
            HStack(spacing: 8) {
                Circle().fill(Color(red: 1.0, green: 0.37, blue: 0.34))
                Circle().fill(Color(red: 1.0, green: 0.74, blue: 0.18))
                Circle().fill(Color(red: 0.16, green: 0.79, blue: 0.25))
            }
            .frame(height: 12)
            .fixedSize()
            .padding(.top, 18)
            .padding(.leading, 20)
        }
        .padding(30)
        .environment(\.colorScheme, dark ? .dark : .light)
    }

    @MainActor
    private static func onboarding(dark: Bool) -> some View {
        appWindow(dark: dark, size: CGSize(width: 500, height: 620)) {
            OnboardingView(model: PermissionModel(), onOpenSettings: {})
        }
    }

    @MainActor
    private static func donation(dark: Bool) -> some View {
        appWindow(dark: dark, size: DonationView.size) {
            DonationView(onChoice: { _ in })
        }
    }
}
