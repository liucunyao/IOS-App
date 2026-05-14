import SwiftUI
import WidgetKit

struct NetworkTimelineEntry: TimelineEntry {
    let date: Date
    let snapshot: NetworkSnapshot
}

struct NetworkProvider: TimelineProvider {
    private let store = NetworkSnapshotStore()

    func placeholder(in context: Context) -> NetworkTimelineEntry {
        NetworkTimelineEntry(date: .now, snapshot: .empty)
    }

    func getSnapshot(in context: Context, completion: @escaping (NetworkTimelineEntry) -> Void) {
        completion(NetworkTimelineEntry(date: .now, snapshot: store.load()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<NetworkTimelineEntry>) -> Void) {
        let snapshot = store.load()
        let entry = NetworkTimelineEntry(date: .now, snapshot: snapshot)
        completion(Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(15 * 60))))
    }
}

struct NetworkWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: NetworkSurfaceConstants.widgetKind, provider: NetworkProvider()) { entry in
            NetworkWidgetView(snapshot: entry.snapshot)
                .containerBackground(.background, for: .widget)
        }
        .configurationDisplayName("Network Status")
        .description("Shows the latest saved upload and download speed.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryRectangular, .accessoryInline])
    }
}

private struct NetworkWidgetView: View {
    let snapshot: NetworkSnapshot
    @Environment(\.widgetFamily) private var family

    var body: some View {
        switch family {
        case .systemMedium:
            HStack(spacing: 14) {
                MetricColumn(title: "Down", value: snapshot.downloadBytesPerSecond.speedText, systemImage: "arrow.down")
                Divider()
                MetricColumn(title: "Up", value: snapshot.uploadBytesPerSecond.speedText, systemImage: "arrow.up")
                Divider()
                VStack(alignment: .leading, spacing: 5) {
                    Text(snapshot.networkKind.displayName)
                        .font(.caption.weight(.semibold))
                    Text(updatedText)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        case .accessoryInline:
            Text("Down \(snapshot.downloadBytesPerSecond.speedText) Up \(snapshot.uploadBytesPerSecond.speedText)")
        case .accessoryRectangular:
            VStack(alignment: .leading, spacing: 3) {
                Text(snapshot.networkKind.displayName)
                    .font(.caption.weight(.semibold))
                Text("Down \(snapshot.downloadBytesPerSecond.speedText)")
                Text("Up \(snapshot.uploadBytesPerSecond.speedText)")
                Text(updatedText)
                    .foregroundStyle(.secondary)
            }
            .font(.caption2.monospacedDigit())
        default:
            VStack(alignment: .leading, spacing: 10) {
                Text(snapshot.networkKind.displayName)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                MetricRow(systemImage: "arrow.down", value: snapshot.downloadBytesPerSecond.speedText)
                MetricRow(systemImage: "arrow.up", value: snapshot.uploadBytesPerSecond.speedText)
                Text(updatedText)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        }
    }

    private var updatedText: String {
        guard snapshot.sampledAt != .distantPast else {
            return "No sample yet"
        }

        return "Updated \(snapshot.sampledAt.formatted(date: .omitted, time: .shortened))"
    }
}

private struct MetricColumn: View {
    let title: String
    let value: String
    let systemImage: String

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Label(title, systemImage: systemImage)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title3.weight(.semibold).monospacedDigit())
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct MetricRow: View {
    let systemImage: String
    let value: String

    var body: some View {
        Label(value, systemImage: systemImage)
            .font(.headline.monospacedDigit())
            .minimumScaleFactor(0.75)
    }
}
