//
//  Feedback.swift
//  Personal-Counter
//
//  Haptic and sound feedback, gated by the user's settings.
//

import AudioToolbox
import UIKit

@MainActor
enum Feedback {

    static func tap(settings: AppSettings) {
        if settings.hapticsEnabled {
            impact(settings.hapticStrength)
        }
        if settings.soundEnabled {
            AudioServicesPlaySystemSound(1104)
        }
    }

    static func success(settings: AppSettings) {
        guard settings.hapticsEnabled else { return }
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    static func warning(settings: AppSettings) {
        guard settings.hapticsEnabled else { return }
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }

    private static func impact(_ strength: HapticStrength) {
        let style: UIImpactFeedbackGenerator.FeedbackStyle = switch strength {
        case .light: .light
        case .medium: .medium
        case .heavy: .heavy
        case .soft: .soft
        case .rigid: .rigid
        }
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
}
