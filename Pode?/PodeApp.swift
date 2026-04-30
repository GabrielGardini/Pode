import SwiftUI
import SwiftData

@main
struct PodeApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    
    var body: some Scene {
        WindowGroup {
            Group {
                TabBar()
            }
        }
        .modelContainer(for: [Child.self])
    }
}
