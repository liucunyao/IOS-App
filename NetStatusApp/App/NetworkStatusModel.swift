import ActivityKit
import Foundation
import Observation
import WidgetKit

@Observable
@MainActor
final class NetworkStatusModel {
    var snapshot: NetworkSnapshot = .empty
    var isMonitoring = false
    var statusMessage = "Ready to monitor"

    private let sampler = NetworkSpeedSampler()
    private let store = NetworkSnapshotStore()
    private var activity: Activity<NetworkActivityAttributes>?
    private var monitoringTask: Task<Void, Never>?
    private var lastWidgetReload = Date.distantPast

    func start() {
        guard monitoringTask == nil else {
            return
        }

        isMonitoring = true
        statusMessage = "Live monitoring active"

        monitoringTask = Task { [weak self] in
            await self?.runMonitoringLoop()
        }
    }

    func stop() {
        monitoringTask?.cancel()
        monitoringTask = nil
        isMonitoring = false
        statusMessage = "Monitoring stopped"

        Task {
            await activity?.end(nil, dismissalPolicy: .immediate)
            activity = nil
        }
    }

    private func runMonitoringLoop() async {
        while !Task.isCancelled, isMonitoring {
            let nextSnapshot = await sampler.sample()
            snapshot = nextSnapshot
            store.save(nextSnapshot)
            await startLiveActivityIfNeeded(with: nextSnapshot)
            updateSystemSurfaces(with: nextSnapshot)

            try? await Task.sleep(for: .seconds(1))
        }

        isMonitoring = false
        monitoringTask = nil
    }

    private func updateSystemSurfaces(with snapshot: NetworkSnapshot) {
        if Date().timeIntervalSince(lastWidgetReload) >= 60 {
            lastWidgetReload = Date()
            WidgetCenter.shared.reloadTimelines(ofKind: NetworkSurfaceConstants.widgetKind)
        }

        Task {
            await activity?.update(
                ActivityContent(
                    state: NetworkActivityAttributes.ContentState(snapshot: snapshot),
                    staleDate: Date().addingTimeInterval(10)
                )
            )
        }
    }

    private func startLiveActivityIfNeeded(with snapshot: NetworkSnapshot) async {
        guard activity == nil else {
            return
        }

        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            return
        }

        if let existing = Activity<NetworkActivityAttributes>.activities.first {
            activity = existing
            return
        }

        do {
            activity = try Activity.request(
                attributes: NetworkActivityAttributes(title: "Network"),
                content: ActivityContent(
                    state: NetworkActivityAttributes.ContentState(snapshot: snapshot),
                    staleDate: Date().addingTimeInterval(10)
                ),
                pushType: nil
            )
        } catch {
            activity = nil
        }
    }
}
