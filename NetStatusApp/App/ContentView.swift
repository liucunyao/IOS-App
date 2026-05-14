import SwiftUI

struct ContentView: View {
    let monitor: NetworkStatusModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    HeaderView(
                        networkKind: monitor.snapshot.networkKind.displayName,
                        isMonitoring: monitor.isMonitoring
                    )

                    ViewThatFits(in: .horizontal) {
                        HStack(spacing: 14) {
                            speedGauges
                        }

                        VStack(spacing: 14) {
                            speedGauges
                        }
                    }

                    Surface {
                        VStack(alignment: .leading, spacing: 12) {
                            StatusRow(
                                title: "Interface",
                                value: monitor.snapshot.interfaceName.isEmpty ? "--" : monitor.snapshot.interfaceName,
                                systemImage: "antenna.radiowaves.left.and.right"
                            )
                            StatusRow(
                                title: "Last sample",
                                value: monitor.snapshot.sampledAt == .distantPast ? "--" : monitor.snapshot.sampledAt.formatted(date: .omitted, time: .standard),
                                systemImage: "clock"
                            )
                            StatusRow(
                                title: "System surfaces",
                                value: "Live Activity is real-time; Home Screen widget shows the latest saved sample.",
                                systemImage: "rectangle.on.rectangle"
                            )
                        }
                    }

                    ControlButton(isMonitoring: monitor.isMonitoring) {
                        if monitor.isMonitoring {
                            monitor.stop()
                        } else {
                            monitor.start()
                        }
                    }

                    Text(monitor.statusMessage)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding()
            }
            .background(
                LinearGradient(
                    colors: [
                        Color(.systemBackground),
                        Color.blue.opacity(0.10),
                        Color.green.opacity(0.08)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
            .navigationTitle("Network Status")
        }
    }

    @ViewBuilder
    private var speedGauges: some View {
        SpeedGauge(
            title: "Download",
            value: monitor.snapshot.downloadBytesPerSecond.speedText,
            systemImage: "arrow.down.circle.fill",
            tint: .blue
        )

        SpeedGauge(
            title: "Upload",
            value: monitor.snapshot.uploadBytesPerSecond.speedText,
            systemImage: "arrow.up.circle.fill",
            tint: .green
        )
    }
}

private struct HeaderView: View {
    let networkKind: String
    let isMonitoring: Bool

    var body: some View {
        Surface {
            HStack(alignment: .center, spacing: 14) {
                Image(systemName: "network")
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundStyle(.blue)
                    .frame(width: 48, height: 48)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Real-time network")
                        .font(.title2.weight(.semibold))
                    Text(networkKind)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                MonitoringBadge(isMonitoring: isMonitoring)
            }
        }
    }
}

private struct SpeedGauge: View {
    let title: String
    let value: String
    let systemImage: String
    let tint: Color

    var body: some View {
        Surface {
            VStack(alignment: .leading, spacing: 12) {
                Label(title, systemImage: systemImage)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)

                Text(value)
                    .font(.system(size: 32, weight: .semibold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(tint)
                    .lineLimit(1)
                    .minimumScaleFactor(0.55)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

private struct StatusRow: View {
    let title: String
    let value: String
    let systemImage: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Image(systemName: systemImage)
                .foregroundStyle(.secondary)
                .frame(width: 22)

            Text(title)
                .font(.subheadline.weight(.semibold))

            Spacer(minLength: 12)

            Text(value)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.trailing)
                .lineLimit(2)
        }
    }
}

private struct MonitoringBadge: View {
    let isMonitoring: Bool

    var body: some View {
        Label(isMonitoring ? "Live" : "Paused", systemImage: isMonitoring ? "dot.radiowaves.left.and.right" : "pause.circle")
            .font(.caption.weight(.semibold))
            .foregroundStyle(isMonitoring ? .green : .secondary)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(.thinMaterial, in: Capsule())
    }
}

private struct ControlButton: View {
    let isMonitoring: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(isMonitoring ? "Stop Monitoring" : "Start Monitoring", systemImage: isMonitoring ? "stop.fill" : "play.fill")
                .frame(maxWidth: .infinity)
        }
        .controlButtonStyle()
    }
}

private struct Surface<Content: View>: View {
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .statusSurface()
    }
}

private extension View {
    @ViewBuilder
    func statusSurface() -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(.regular, in: .rect(cornerRadius: 18))
        } else {
            self.background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18))
        }
    }

    @ViewBuilder
    func controlButtonStyle() -> some View {
        if #available(iOS 26.0, *) {
            self.buttonStyle(.glassProminent)
        } else {
            self.buttonStyle(.borderedProminent)
        }
    }
}

#Preview {
    ContentView(monitor: NetworkStatusModel())
}
