import SwiftUI
import SwiftData

@main
struct Pode_App: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Child.self])
    }
}
