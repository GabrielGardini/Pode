import SwiftUI
import SwiftData

@main
struct Pode_App: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: [Crianca.self])
    }
}
