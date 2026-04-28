//
//  ScanAnimationStepView.swift
//  Pode?
//
//  Created by Marlon Ribas on 28/04/26.
//

import SwiftUI

struct ScanAnimationStepView: View {
    let step: OnboardingStep
    let isActive: Bool
    
    @State private var appeared = false
    @State private var scanOffset: CGFloat = -80
    @State private var scanOpacity: Double = 0
    @State private var cornerPulse = false
    @State private var dotsVisible = false
    
    private let frameSize: CGFloat = 200
    
    var body: some View {
        VStack(spacing: 28) {
            Spacer(minLength: 20)
            
            // Scan frame
            ZStack {
                // Simulated label content
                VStack(spacing: 6) {
                    ForEach(0..<5, id: \.self) { i in
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color(.systemFill))
                            .frame(width: CGFloat.random(in: 80...140), height: 8)
                            .opacity(appeared ? 1 : 0)
                            .animation(.easeIn(duration: 0.2).delay(0.3 + Double(i) * 0.07), value: appeared)
                    }
                }
                
                // Scan line
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color.accentColor.opacity(0), Color.accentColor, Color.accentColor.opacity(0)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 2)
                    .offset(y: scanOffset)
                    .opacity(scanOpacity)
                
                // Corner marks
                ScanCorners(pulse: cornerPulse)
                    .foregroundStyle(Color.accentColor)
                    .frame(width: frameSize, height: frameSize)
            }
            .frame(width: frameSize, height: frameSize)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(spacing: 10) {
                Text(step.title)
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 16)
                    .animation(.spring(duration: 0.5).delay(0.15), value: appeared)
                
                Text(step.subtitle)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 12)
                    .animation(.spring(duration: 0.5).delay(0.25), value: appeared)
            }
            
            Spacer(minLength: 20)
        }
        .onAppear {
            appeared = true
            dotsVisible = true
            startScanAnimation()
            withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                cornerPulse = true
            }
        }
        .onDisappear {
            appeared = false
            dotsVisible = false
        }
    }
    
    private func startScanAnimation() {
        scanOffset = -80
        withAnimation(.easeIn(duration: 0.3)) {
            scanOpacity = 1
        }
        withAnimation(.easeInOut(duration: 1.4).delay(0.1).repeatForever(autoreverses: false)) {
            scanOffset = 80
        }
    }
}

struct ScanCorners: View {
    var pulse: Bool
    private let length: CGFloat = 24
    private let thickness: CGFloat = 3
    private let radius: CGFloat = 8
    
    var body: some View {
        ZStack {
            // Top-left
            cornerMark(rotation: 0)
                .position(x: length / 2, y: length / 2)
            // Top-right
            cornerMark(rotation: 90)
                .position(x: 200 - length / 2, y: length / 2)
            // Bottom-left
            cornerMark(rotation: 270)
                .position(x: length / 2, y: 200 - length / 2)
            // Bottom-right
            cornerMark(rotation: 180)
                .position(x: 200 - length / 2, y: 200 - length / 2)
        }
        .scaleEffect(pulse ? 1.04 : 1.0)
    }
    
    private func cornerMark(rotation: Double) -> some View {
        CornerShape(length: length, thickness: thickness)
            .rotationEffect(.degrees(rotation))
    }
}

struct CornerShape: Shape {
    let length: CGFloat
    let thickness: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: length))
        path.addLine(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: length, y: 0))
        return path.strokedPath(.init(lineWidth: thickness, lineCap: .round))
    }
}

struct ProcessingDots: View {
    let visible: Bool
    @State private var phase = 0
    
    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .frame(width: 4, height: 4)
                    .foregroundStyle(Color.accentColor)
                    .opacity(phase == i ? 1 : 0.3)
            }
        }
        .onAppear {
            guard visible else { return }
            Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { _ in
                withAnimation(.easeInOut(duration: 0.3)) {
                    phase = (phase + 1) % 3
                }
            }
        }
    }
}
