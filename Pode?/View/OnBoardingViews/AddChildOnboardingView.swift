//
//  AddChildOnboardingView.swift
//  Pode?
//
//  Created by Marlon Ribas on 04/05/26.
//

import SwiftUI
import SwiftData

struct AddChildOnboardingView: View {
    let step: OnboardingStep
    let isActive: Bool
    
    @Binding var name: String
    @Binding var birthDate: Date
    
    // Estado de animação por elemento (mesmo padrão do ResultStepView)
    @State private var titleVisible = false
    @State private var avatarVisible = false
    @State private var nameFieldVisible = false
    @State private var dateFieldVisible = false
    
    private var age: String {
        let components = Calendar.current.dateComponents([.year, .month], from: birthDate, to: .now)
        let years = components.year ?? 0
        let months = components.month ?? 0
        
        if birthDate > .now {
            return "Data inválida"
        } else if years == 0 && months == 0 {
            return "Recém-nascido"
        } else if years == 0 {
            return "\(months) \(months == 1 ? "mês" : "meses")"
        } else if months == 0 {
            return "\(years) \(years == 1 ? "ano" : "anos")"
        } else {
            return "\(years) \(years == 1 ? "ano" : "anos") e \(months) \(months == 1 ? "mês" : "meses")"
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            
            // MARK: - Título
            if let title = step.title {
                Text(title)
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 24)
                    .opacity(titleVisible ? 1 : 0)
                    .offset(y: titleVisible ? 0 : 16)
                    .animation(.spring(duration: 0.5).delay(0.1), value: titleVisible)
            }
            
            // MARK: - Avatar
            VStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Color.accentColor.opacity(0.12))
                        .frame(width: 72, height: 72)
                    Image(systemName: name.isEmpty ? "person.fill" : "person.fill.checkmark")
                        .font(.system(size: 30, weight: .light))
                        .foregroundStyle(Color.accentColor)
                        .contentTransition(.symbolEffect(.replace))
                }
                
                if !name.isEmpty {
                    Text(name)
                        .font(.title3.weight(.semibold))
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                } else {
                    Text("Nova criança")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .animation(.spring(duration: 0.3), value: name.isEmpty)
            .opacity(avatarVisible ? 1 : 0)
            .offset(y: avatarVisible ? 0 : 20)
            .animation(.spring(duration: 0.5, bounce: 0.3).delay(0.25), value: avatarVisible)
            
            // MARK: - Campo Nome
            VStack(alignment: .leading, spacing: 8) {
                Text("Nome")
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 16)
                
                TextField("Nome da criança", text: $name)
                    .textInputAutocapitalization(.words)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 32, style: .continuous))
            }
            .padding(.bottom, 16)
            .opacity(nameFieldVisible ? 1 : 0)
            .offset(x: nameFieldVisible ? 0 : 32)
            .animation(.spring(duration: 0.5, bounce: 0.3).delay(0.4), value: nameFieldVisible)
            
            // MARK: - Campo Data
            VStack(alignment: .leading, spacing: 8) {
                Text("Data de nascimento")
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 16)
                
                VStack(spacing: 0) {
                    DatePicker(
                        "",
                        selection: $birthDate,
                        in: ...Date(),
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .frame(maxWidth: .infinity)
                    
                    Divider()
                        .padding(.horizontal, 14)
                    
                    HStack(spacing: 8) {
                        Image(systemName: "birthday.cake")
                            .foregroundStyle(Color.accentColor)
                            .frame(width: 24)
                        Text(age)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .animation(.spring(duration: 0.3), value: age)
                }
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 32, style: .continuous))
            }
            .opacity(dateFieldVisible ? 1 : 0)
            .offset(x: dateFieldVisible ? 0 : 32)
            .animation(.spring(duration: 0.5, bounce: 0.3).delay(0.55), value: dateFieldVisible)
        }
        // Mesmo padrão do ResultStepView: reage ao isActive
        .onChange(of: isActive) { _, active in
            if active {
                startAnimations()
            } else {
                resetAnimations()
            }
        }
        .onAppear {
            if isActive { startAnimations() }
        }
    }
    
    private func startAnimations() {
        resetAnimations()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            titleVisible = true
            avatarVisible = true
            nameFieldVisible = true
            dateFieldVisible = true
        }
    }
    
    private func resetAnimations() {
        titleVisible = false
        avatarVisible = false
        nameFieldVisible = false
        dateFieldVisible = false
    }
}
