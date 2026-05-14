import ActivityKit
import SwiftUI
import WidgetKit

struct NetworkLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: NetworkActivityAttributes.self) { context in
            LockScreenNetworkView(snapshot: context.state.snapshot)
                .activityBackgroundTint(.black.opacity(0.86))
                .activitySystemActionForegroundColor(.white)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    IslandMetric(title: "Down", value: context.state.snapshot.downloadBytesPerSecond.speedText, systemImage: "arrow.down")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    IslandMetric(title: "Up", value: context.state.snapshot.uploadBytesPerSecond.speedText, systemImage: "arrow.up")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text(context.state.snapshot.networkKind.displayName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } compactLeading: {
                Image(systemName: "arrow.down")
                    .foregroundStyle(.blue)
            } compactTrailing: {
                Text(context.state.snapshot.downloadBytesPerSecond.speedText)
                    .font(.caption2.monospacedDigit())
                    .minimumScaleFactor(0.65)
            } minimal: {
                Image(systemName: "network")
            }
        }
    }
}

private struct LockScreenNetworkView: View {
    let snapshot: NetworkSnapshot

    var body: some View {
        HStack(spacing: 16) {
            IslandMetric(title: "Download", value: snapshot.downloadBytesPerSecond.speedText, systemImage: "arrow.down")
            Divider().overlay(.white.opacity(0.25))
            IslandMetric(title: "Upload", value: snapshot.uploadBytesPerSecond.speedText, systemImage: "arrow.up")
            Spacer(minLength: 0)
            Text(snapshot.networkKind.displayName)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
    }
}

private struct IslandMetric: View {
    let title: String
    let value: String
    let systemImage: String

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Label(title, systemImage: systemImage)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.headline.monospacedDigit())
                .minimumScaleFactor(0.7)
        }
    }
}
