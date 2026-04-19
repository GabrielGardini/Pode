//
//  ContentView.swift
//  Pode?
//
//  Created by Gabriel Gardini on 13/04/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            CameraTest()
                .tabItem {
                    Label("Scan", systemImage: "camera.viewfinder")
                }

            ChildrenView()
                .tabItem {
                    Label("Crianças", systemImage: "figure.child")
                }
        }
    }
}
