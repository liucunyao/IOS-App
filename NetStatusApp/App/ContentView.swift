import SwiftUI

struct ContentView: View {
    let monitor: NetworkStatusModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                SpeedGauge(
                    title: "Download",
                    value: monitor.snapshot.downloadBytesPerSecond.speedText,
                    tint: .blue
                )

                SpeedGauge(
                    title: "Upload",
                    value: monitor.snapshot.uploadBytesPerSecond.speedText,
                    tint: .green
                )

                HStack {
                    Label(monitor.snapshot.networkKind.displayName, systemImage: "network")
                    Spacer()
                    Text(monitor.snapshot.interfaceName.isEmpty ? "--" : monitor.snapshot.interfaceName)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                .font(.subheadline)
                .padding()
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))

                Spacer()
            }
            .padding()
            .navigationTitle("Network Status")
        }
    }
}

private struct SpeedGauge: View {
    let title: String
    let value: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.system(size: 42, weight: .semibold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(tint)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.background.secondary, in: RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    ContentView(monitor: NetworkStatusModel())
}
