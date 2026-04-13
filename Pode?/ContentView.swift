//
//  ContentView.swift
//  Pode?
//
//  Created by Gabriel Gardini on 13/04/26.
//

import SwiftUI

struct ContentView: View {
    @State private var scannedText: String = ""
    @State private var presentScanner: Bool = false

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 12) {
                Text("Texto da Tabela Nutricional")
                    .font(.title3).bold()
                ScrollView {
                    Text(scannedText.isEmpty ? "Toque em 'Ler Tabela' para capturar o texto da tabela nutricional." : scannedText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                }
            }
            .padding()
            .navigationTitle("Pode?")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        presentScanner = true
                    } label: {
                        Label("Ler Tabela", systemImage: "camera.viewfinder")
                    }
                }
            }
        }
        .sheet(isPresented: $presentScanner) {
            CameraTextScannerView(text: $scannedText)
        }
    }
}

#Preview {
    ContentView()
}
