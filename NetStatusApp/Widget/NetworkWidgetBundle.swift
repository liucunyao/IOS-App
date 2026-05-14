import SwiftUI
import WidgetKit

@main
struct NetworkWidgetBundle: WidgetBundle {
    var body: some Widget {
        NetworkWidget()
        NetworkLiveActivityWidget()
    }
}
