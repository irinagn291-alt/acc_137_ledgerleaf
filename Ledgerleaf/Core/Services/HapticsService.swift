import UIKit

/// Stateless haptics helper. Kept as the project's one intentional "singleton-like"
/// utility, since `UIFeedbackGenerator` instances are cheap and have no shared state to inject.
enum HapticsService {
    /// Fires at the "moment of outcome": the running total visibly increments.
    static func totalIncremented() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }

    static func selectionChanged() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }

    static func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    static func warning() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }
}
