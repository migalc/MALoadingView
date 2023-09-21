//
//  LoadingView.swift
//
//
//  Created by Miguel Alcântara on 15/06/2023.
//

import SwiftUI

public struct MALoadingView: View {

    // MARK: - Style

    struct Style {
        let foregroundColor: Color
        let backgroundColor: Color

        init(
            foregroundColor: Color,
            backgroundColor: Color
        ) {
            self.foregroundColor = foregroundColor
            self.backgroundColor = backgroundColor
        }

        static let `default`: Self = .init(
            foregroundColor: .blue,
            backgroundColor: .clear
        )
    }

    // MARK: - UI

    private let strokeWidth: CGFloat = 12
    var style: Style = .default

    // MARK: - Animations
    
    @State private var rotationAngle: Angle = .degrees(0)
    @State private var shouldGrow: Bool = true
    @State private var trimBegin: CGFloat = 0.65
    @State private var trimEnd: CGFloat = 0.66
    @Binding var continueAnimation: Bool
    private let duration: CGFloat = 1

    // MARK: - Full sized
    private let beginMinThreshold: CGFloat = 0.3
    private let endMaxThreshold: CGFloat = 1

    // MARK: - Shrinked
    private var beginMaxThreshold: CGFloat { beginMinThreshold + (endMaxThreshold - beginMinThreshold) / 2 }
    private var endMinThreshold: CGFloat { beginMaxThreshold + 0.01 }

    var rotationAnimation: Animation? {
        continueAnimation ? .linear(duration: duration) : nil
    }

    var trimAnimation: Animation? {
        continueAnimation ? .easeInOut(duration: duration) : nil
    }

    public var body: some View {
        Circle()
            .trim(
                from: trimBegin,
                to: trimEnd
            )
            .stroke(
                style: StrokeStyle(
                    lineWidth: strokeWidth,
                    lineCap: .round
                )
            )
            .background(style.backgroundColor)
            .clipShape(Circle())
            .foregroundColor(style.foregroundColor)
            .rotationEffect(rotationAngle)
            .opacity(continueAnimation ? 1 : 0)
            .animation(
                .easeInOut,
                value: continueAnimation
            )
            .onAnimationCompleted(for: trimBegin) {
                self.shouldGrow.toggle()
            }
            .onChange(of: shouldGrow) { newValue in
                guard continueAnimation else { return }
                animate()
            }
            .onChange(of: continueAnimation) { newValue in
                guard continueAnimation else { return }
                animate()
            }
            
    }

    func animate() {
        withAnimation(rotationAnimation) {
            rotationAngle += .degrees(360)
        }
        shouldGrow ? animateGrow() : animateShrink()
    }

    func animateGrow() {
        withAnimation(trimAnimation) {
            trimBegin = beginMinThreshold
            trimEnd = endMaxThreshold
        }
    }

    func animateShrink() {
        withAnimation(trimAnimation) {
            trimBegin = beginMaxThreshold
            trimEnd = endMinThreshold
        }
    }

    
}

struct MALoadingContentView: View {
    @State var startAnimation: Bool = false
    var body: some View {
        VStack {
            Button("Tap to animate") {
                startAnimation = !startAnimation
            }
            
            MALoadingView(
                style: .default,
                continueAnimation: $startAnimation
            )
//                .frame(width: 50, height: 50)
        }
    }
}

struct MALoadingContentView_Previews: PreviewProvider {
    static var previews: some View {
        MALoadingContentView()
    }
}
