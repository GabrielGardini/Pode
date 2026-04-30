//
//  TabBar.swift
//  Pode?
//
//  Created by Gabriel Gardini on 13/04/26.
//

import SwiftUI

struct TabBar: View {
    var body: some View {
        TabView {
            ScanView()
                .tabItem {
                    Label("Scan", systemImage: "camera.viewfinder")
                }

            ChildrenView()
                .tabItem {
                    Label("Crianças", systemImage: "figure.child")
                }
            PermittedFoodView()
                .tabItem {
                    Label("Guia", systemImage: "fork.knife")
                }
        }
    }
}
