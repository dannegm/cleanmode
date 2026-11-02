import SwiftUI

final class LockModel: ObservableObject {
    /// Segundos restantes antes del cierre automático (nil si no hay límite).
    @Published var remainingSeconds: Int?
    /// ⌘Q consecutivos registrados hasta ahora.
    @Published var quitPresses = 0
    /// Se incrementa en cada ⌘Q registrado; la UI lo usa para reiniciar el subtítulo.
    @Published var quitPulse = 0
}
