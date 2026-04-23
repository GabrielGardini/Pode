import SwiftUI
import SwiftData

@main
struct PodeApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    
    var body: some Scene {
        WindowGroup {
            Group {
                ContentView()
            }
        }
        .modelContainer(for: [Child.self])
    }
}
