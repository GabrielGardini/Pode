//
//  DefaultStepView.swift
//  Pode?
//
//  Created by Marlon Ribas on 28/04/26.
//

import SwiftUI

struct DefaultStepView: View {
    let step: OnboardingStep
    let isActive: Bool
 
    @State private var appeared = false
 
    var body: some View {
        VStack(spacing: 20) {
            Spacer(minLength: 20)
 
            Image(systemName: step.systemImage)
                .symbolRenderingMode(.hierarchical)
                .font(.system(size: 72, weight: .regular))
                .foregroundStyle(Color.accentColor)
                .scaleEffect(appeared ? 1 : 0.5)
                .opacity(appeared ? 1 : 0)
                .animation(.spring(duration: 0.6, bounce: 0.4), value: appeared)
 
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
        .onChange(of: isActive) { _, active in
            appeared = active
        }
        .onAppear {
            if isActive { appeared = true }
        }
    }
}
