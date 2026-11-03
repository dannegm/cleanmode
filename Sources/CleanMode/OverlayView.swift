import SwiftUI
import Combine

struct OverlayView: View {
    @ObservedObject var model: LockModel
    let showsContent: Bool
    let onExit: () -> Void
    /// Solo para generar capturas de la documentación (`--render-docs`): muestra el contenido ya visible.
    var preview = false

    @State private var appeared = false
    @State private var subtitleOpacity = 0.0
    @State private var subtitleRemaining = Config.quitPressesRequired - 1

    private let s = Config.uiScale

    var body: some View {
        ZStack {
            Color.black   // negro puro: así se ve bien por dónde se va limpiando
            if showsContent {
                content
                VStack {
                    Spacer()
                    subtitle.padding(.bottom, 96 * s)
                }
                VStack {
                    Spacer()
                    footer.padding(.bottom, 32 * s)
                }
            }
        }
        .environment(\.layoutDirection, L10n.isRTL ? .rightToLeft : .leftToRight)
        .onReceive(model.$quitPulse) { pulse in
            guard pulse > 0, showsContent else { return }
            subtitleRemaining = max(Config.quitPressesRequired - model.quitPresses, 1)
            // Vuelve a blanco de golpe y luego se desvanece mientras corre el debounce.
            var instant = Transaction(animation: nil)
            instant.disablesAnimations = true
            withTransaction(instant) { subtitleOpacity = 1 }
            DispatchQueue.main.async {
                withAnimation(.linear(duration: Config.quitDebounce)) { subtitleOpacity = 0 }
            }
        }
    }

    // MARK: - Contenido

    private var content: some View {
        HStack(alignment: .top, spacing: 36 * s) {
            // Escoba de aura (BrushCleaning) inclinada 45°. El contenedor mide justo lo que ocupa
            // el icono ya rotado, así su borde superior queda alineado con el arriba del texto.
            BrushCleaningShape()
                .stroke(Color.white, style: StrokeStyle(lineWidth: 4 * s, lineCap: .round, lineJoin: .round))
                .frame(width: 96 * s, height: 96 * s)
                .rotationEffect(.degrees(-45))
                .frame(width: 106 * s, height: 106 * s)
                // Alineación vertical: inclinada, la escoba deja ~20.4·s de aire arriba dentro de su contenedor,
                // y las letras del título (altura de mayúscula) empiezan a ~5.2·s del borde del texto.
                // Se sube la diferencia para que el borde superior de la escoba quede a la altura del título,
                // y luego se baja 4 pt (ajuste fino pedido a ojo).
                .offset(y: -15.2 * s + 4)

            VStack(alignment: .leading, spacing: 12 * s) {
                Text(L10n.t("lock.title"))
                    .font(.system(size: 21 * s, weight: .semibold))

                VStack(alignment: .leading, spacing: 8 * s) {
                    Text(L10n.t("lock.blocked"))
                    Text(L10n.t("lock.tips"))
                }
                .font(.system(size: 18))   // descripción: 18 pt fijos
                .fixedSize(horizontal: false, vertical: true)

                HoldButton(
                    title: L10n.t("lock.hold"),
                    duration: Config.holdDuration,
                    action: onExit
                )
                .padding(.top, 6 * s)

                if let remaining = model.remainingSeconds {
                    Text(L10n.t("lock.autoClose", Self.format(remaining)))
                        .font(.system(size: 16))   // contador: 16 pt fijos
                        .opacity(0.7)
                        .monospacedDigit()
                }
            }
            .foregroundStyle(Color.white)
            .frame(width: 320 * s, alignment: .leading)
        }
        .opacity(appeared || preview ? 1 : 0)
        .scaleEffect(appeared || preview ? 1 : 0.97)
        .onAppear { withAnimation(.easeOut(duration: 0.6)) { appeared = true } }
    }

    // MARK: - Pie: salida con teclado (a media transparencia)

    private var footer: some View {
        KeyHintText(template: L10n.t("lock.footer", Config.quitPressesRequired), keySize: 11 * s, spacing: 6 * s)
            .font(.system(size: 11 * s))
            .foregroundStyle(Color.white)
            .opacity(0.5)
    }

    // MARK: - Subtítulo de ⌘Q (aparece al presionar y se desvanece mientras se reinicia el conteo)

    private var subtitle: some View {
        KeyHintText(template: L10n.plural("lock.subtitle", subtitleRemaining), keySize: 16 * s, spacing: 8 * s)
            .font(.system(size: 20 * s, weight: .medium))
            .foregroundStyle(Color.white)
            .shadow(color: Color.black.opacity(0.8), radius: 3, y: 1)
            .opacity(subtitleOpacity)
    }

    private static func format(_ seconds: Int) -> String {
        String(format: "%d:%02d", seconds / 60, seconds % 60)
    }
}

/// Tecla estilo <kbd>: caja redondeada con borde y un pequeño reborde inferior.
struct Kbd: View {
    let key: String
    let size: CGFloat

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: size * 0.32, style: .continuous)
        Text(key)
            .font(.system(size: size, weight: .medium, design: .rounded))
            .foregroundStyle(Color.white)
            .padding(.horizontal, size * 0.5)
            .padding(.vertical, size * 0.14)
            .background(shape.fill(Color.white.opacity(0.14)))
            .overlay(shape.strokeBorder(Color.white.opacity(0.55), lineWidth: 1))
            .shadow(color: Color.white.opacity(0.4), radius: 0, y: max(1, size * 0.1))
    }
}

/// Texto con las teclas ⌘ y Q en estilo kbd. La plantilla marca con `{keys}` dónde van las teclas,
/// así cada idioma las coloca donde su gramática lo pide.
struct KeyHintText: View {
    let template: String
    let keySize: CGFloat
    let spacing: CGFloat

    var body: some View {
        let parts = template.components(separatedBy: "{keys}")
        let before = parts[0].trimmingCharacters(in: .whitespaces)
        let after = parts.count > 1 ? parts[1].trimmingCharacters(in: .whitespaces) : ""
        HStack(spacing: spacing) {
            if !before.isEmpty { Text(before) }
            if parts.count > 1 {
                Kbd(key: "⌘", size: keySize)
                Kbd(key: "Q", size: keySize)
            }
            if !after.isEmpty { Text(after) }
        }
    }
}

/// Botón de mantener presionado: el progreso es un relleno blanco y el texto pasa a negro
/// justo donde el relleno lo va cubriendo.
struct HoldButton: View {
    let title: String
    let duration: TimeInterval
    let action: () -> Void

    @State private var progress: CGFloat = 0
    @State private var holding = false
    @State private var pending: DispatchWorkItem?

    private let s = Config.holdButtonScale
    private var width: CGFloat { 280 * s }
    private var height: CGFloat { 48 * s }
    private var shape: RoundedRectangle { RoundedRectangle(cornerRadius: 10 * s, style: .continuous) }

    private var label: some View {
        Text(title)
            .font(.system(size: 15 * s, weight: .medium))
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .padding(.horizontal, 12 * s)
            .frame(width: width, height: height)
    }

    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.white)
                .frame(width: width * progress, height: height)
                .frame(width: width, height: height, alignment: .leading)

            label.foregroundStyle(Color.white)

            label.foregroundStyle(Color.black)
                .mask(alignment: .leading) {
                    Rectangle().frame(width: width * progress, height: height)
                }
        }
        .frame(width: width, height: height)
        .background(Color.white.opacity(0.10))
        .clipShape(shape)
        .overlay(shape.strokeBorder(Color.white.opacity(0.40), lineWidth: 1))
        .contentShape(shape)
        .scaleEffect(holding ? 0.98 : 1)
        .animation(.easeOut(duration: 0.15), value: holding)
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in begin() }
                .onEnded { _ in cancel() }
        )
    }

    private func begin() {
        guard !holding else { return }
        holding = true
        withAnimation(.linear(duration: duration)) { progress = 1 }
        let item = DispatchWorkItem { action() }
        pending = item
        DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: item)
    }

    private func cancel() {
        holding = false
        pending?.cancel()
        pending = nil
        withAnimation(.easeOut(duration: 0.2)) { progress = 0 }
    }
}
