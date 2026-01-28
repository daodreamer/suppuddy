//
//  ReduceMotionHelper.swift
//  vitamin_calculator
//
//  Created by Claude Code on 28.01.26.
//  Sprint 7 Phase 2: Reduce motion accessibility support
//

import SwiftUI

/// Provides helpers for respecting the Reduce Motion system setting
struct ReduceMotionHelper {

    /// Returns appropriate animation based on reduce motion setting
    static func animation<V: Equatable>(
        _ animation: Animation,
        value: V,
        reduceMotion: Bool
    ) -> Animation? {
        reduceMotion ? nil : animation
    }

    /// Returns appropriate transition based on reduce motion setting
    static func transition(
        _ transition: AnyTransition,
        reduceMotion: Bool
    ) -> AnyTransition {
        reduceMotion ? .opacity : transition
    }

    /// Duration for animations (0 if reduce motion is enabled)
    static func duration(
        _ duration: Double,
        reduceMotion: Bool
    ) -> Double {
        reduceMotion ? 0 : duration
    }
}

/// View extension for reduce motion-aware animations
extension View {
    /// Applies animation that respects reduce motion setting
    func animationAccessible<V: Equatable>(
        _ animation: Animation,
        value: V
    ) -> some View {
        modifier(AnimationAccessibleModifier(animation: animation, value: value))
    }

    /// Applies transition that respects reduce motion setting
    func transitionAccessible(_ transition: AnyTransition) -> some View {
        modifier(TransitionAccessibleModifier(transition: transition))
    }
}

/// View modifier that applies animation respecting reduce motion
struct AnimationAccessibleModifier<V: Equatable>: ViewModifier {
    let animation: Animation
    let value: V

    @Environment(\.accessibilityReduceMotion) var reduceMotion

    func body(content: Content) -> some View {
        if reduceMotion {
            content
        } else {
            content.animation(animation, value: value)
        }
    }
}

/// View modifier that applies transition respecting reduce motion
struct TransitionAccessibleModifier: ViewModifier {
    let transition: AnyTransition

    @Environment(\.accessibilityReduceMotion) var reduceMotion

    func body(content: Content) -> some View {
        content.transition(reduceMotion ? .opacity : transition)
    }
}

/// View modifier for scale effects that respect reduce motion
struct ScaleEffectAccessible: ViewModifier {
    let scale: CGFloat
    let anchor: UnitPoint

    @Environment(\.accessibilityReduceMotion) var reduceMotion

    func body(content: Content) -> some View {
        if reduceMotion {
            content
        } else {
            content.scaleEffect(scale, anchor: anchor)
        }
    }
}

extension View {
    /// Applies scale effect that respects reduce motion setting
    func scaleEffectAccessible(
        _ scale: CGFloat,
        anchor: UnitPoint = .center
    ) -> some View {
        modifier(ScaleEffectAccessible(scale: scale, anchor: anchor))
    }
}

/// View modifier for rotation effects that respect reduce motion
struct RotationEffectAccessible: ViewModifier {
    let angle: Angle
    let anchor: UnitPoint

    @Environment(\.accessibilityReduceMotion) var reduceMotion

    func body(content: Content) -> some View {
        if reduceMotion {
            content
        } else {
            content.rotationEffect(angle, anchor: anchor)
        }
    }
}

extension View {
    /// Applies rotation effect that respects reduce motion setting
    func rotationEffectAccessible(
        _ angle: Angle,
        anchor: UnitPoint = .center
    ) -> some View {
        modifier(RotationEffectAccessible(angle: angle, anchor: anchor))
    }
}

/// Animation presets that work well with reduce motion
enum AccessibleAnimation {
    /// Standard easeInOut animation (or none if reduce motion is enabled)
    static func standard(reduceMotion: Bool) -> Animation? {
        reduceMotion ? nil : .easeInOut
    }

    /// Spring animation (or none if reduce motion is enabled)
    static func spring(reduceMotion: Bool) -> Animation? {
        reduceMotion ? nil : .spring()
    }

    /// Linear animation (or none if reduce motion is enabled)
    static func linear(reduceMotion: Bool) -> Animation? {
        reduceMotion ? nil : .linear
    }

    /// Smooth animation with duration (or none if reduce motion is enabled)
    static func smooth(_ duration: Double, reduceMotion: Bool) -> Animation? {
        reduceMotion ? nil : .easeInOut(duration: duration)
    }
}

/// Transition presets that work well with reduce motion
enum AccessibleTransition {
    /// Slide transition (or opacity if reduce motion is enabled)
    static func slide(edge: Edge, reduceMotion: Bool) -> AnyTransition {
        reduceMotion ? .opacity : .move(edge: edge).combined(with: .opacity)
    }

    /// Scale transition (or opacity if reduce motion is enabled)
    static func scale(reduceMotion: Bool) -> AnyTransition {
        reduceMotion ? .opacity : .scale.combined(with: .opacity)
    }

    /// Asymmetric transition (or opacity if reduce motion is enabled)
    static func asymmetric(
        insertion: AnyTransition,
        removal: AnyTransition,
        reduceMotion: Bool
    ) -> AnyTransition {
        reduceMotion ? .opacity : .asymmetric(insertion: insertion, removal: removal)
    }
}
