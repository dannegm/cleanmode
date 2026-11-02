import SwiftUI

final class PermissionModel: ObservableObject {
    @Published var accessibilityGranted = false
    @Published var tapReady = false
    /// Se activa si pasa un rato esperando el permiso, para mostrar una pista (no antes).
    @Published var showHint = false
}

struct OnboardingView: View {
    @ObservedObject var model: PermissionModel
    let onOpenSettings: () -> Void

    var body: some View {
        Group {
            if model.tapReady { readyState } else { setupState }
        }
        .frame(width: 500, height: 620)
        .environment(\.layoutDirection, L10n.isRTL ? .rightToLeft : .leftToRight)
        .animation(.easeInOut(duration: 0.3), value: model.tapReady)
    }

    // MARK: - Configuración

    private var setupState: some View {
        VStack(spacing: 0) {
            Image(nsImage: NSApp.applicationIconImage)
                .resizable()
                .frame(width: 76, height: 76)
                .padding(.top, 52)

            Text(L10n.t("onb.title"))
                .font(.system(size: 24, weight: .semibold))
                .padding(.top, 20)

            Text(L10n.t("onb.subtitle"))
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: 340)
                .padding(.top, 12)

            VStack(alignment: .leading, spacing: 20) {
                step(1, L10n.t("onb.step1"))
                VStack(alignment: .leading, spacing: 12) {
                    step(2, L10n.t("onb.step2"))
                    appRowPreview
                        .padding(.leading, 30)
                }
            }
            .frame(width: 360, alignment: .leading)
            .padding(.top, 40)

            statusRow
                .frame(width: 360, alignment: .leading)
                .padding(.top, 36)

            Spacer(minLength: 24)

            Button(action: onOpenSettings) {
                Text(L10n.t("onb.button"))
                    .font(.system(size: 14, weight: .medium))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .frame(width: 260)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)

            Text(L10n.t("onb.hint"))
                .font(.system(size: 11))
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
                .opacity(model.showHint ? 1 : 0)
                .padding(.top, 14)
                .padding(.bottom, 36)
        }
    }

    // MARK: - Todo listo

    private var readyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 76))
                .foregroundStyle(Color.green)
            Text(L10n.t("onb.ready"))
                .font(.system(size: 24, weight: .semibold))
            HStack(spacing: 8) {
                Spinner()
                Text(L10n.t("onb.starting"))
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 4)
        }
    }

    // MARK: - Piezas

    /// Cómo se verá la app en la lista de Ajustes del Sistema.
    private var appRowPreview: some View {
        HStack(spacing: 10) {
            Image(nsImage: NSApp.applicationIconImage)
                .resizable()
                .frame(width: 28, height: 28)
            Text("Clean Mode").font(.system(size: 13, weight: .medium))
            Spacer()
            Capsule()
                .fill(Color.accentColor)
                .frame(width: 36, height: 20)
                .overlay(alignment: .trailing) {
                    Circle().fill(Color.white).frame(width: 16, height: 16).padding(.trailing, 2)
                }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(Color.primary.opacity(0.06)))
    }

    private func step(_ n: Int, _ text: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Text("\(n)")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Color.white)
                .frame(width: 20, height: 20)
                .background(Circle().fill(Color.accentColor))
            Text(text).font(.system(size: 13))
        }
    }

    @ViewBuilder
    private var statusRow: some View {
        if model.accessibilityGranted {
            // Activado en la lista, pero macOS todavía no deja bloquear.
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(Color.orange)
                    .frame(width: 18)
                Text(L10n.t("onb.stale"))
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        } else {
            HStack(spacing: 8) {
                Spinner().frame(width: 18, height: 18)
                Text(L10n.t("onb.waiting"))
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }
        }
    }
}

/// Indicador de espera hecho solo con SwiftUI (sin controles de AppKit).
struct Spinner: View {
    var size: CGFloat = 14
    @State private var spinning = false

    var body: some View {
        Circle()
            .trim(from: 0.08, to: 0.8)
            .stroke(Color.secondary, style: StrokeStyle(lineWidth: max(1.5, size * 0.14), lineCap: .round))
            .frame(width: size, height: size)
            .rotationEffect(.degrees(spinning ? 360 : 0))
            .animation(.linear(duration: 0.9).repeatForever(autoreverses: false), value: spinning)
            .onAppear { spinning = true }
    }
}
