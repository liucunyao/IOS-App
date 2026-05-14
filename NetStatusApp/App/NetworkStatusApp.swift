import SwiftUI

@main
struct NetworkStatusApp: App {
    @State private var monitor = NetworkStatusModel()

    var body: some Scene {
        WindowGroup {
            ContentView(monitor: monitor)
                .task {
                    monitor.start()
                }
        }
    }
}
