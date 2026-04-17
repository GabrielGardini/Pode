import SwiftUI
import SwiftData

@main
struct PodeApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()       }
        .modelContainer(for: [Child.self])
    }
}
