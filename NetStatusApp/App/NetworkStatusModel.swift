import ActivityKit
import Foundation
import Observation
import WidgetKit

@Observable
@MainActor
final class NetworkStatusModel {
    var snapshot: NetworkSnapshot = .empty
    var isMonitoring = false

    private let sampler = NetworkSpeedSampler()
    private let store = NetworkSnapshotStore()
    private var activity: Activity<NetworkActivityAttributes>?

    func start() async {
        guard !isMonitoring else {
            return
        }

        isMonitoring = true
        await startLiveActivityIfNeeded()

        while !Task.isCancelled {
            let nextSnapshot = await sampler.sample()
            snapshot = nextSnapshot
            store.save(nextSnapshot)
            updateSystemSurfaces(with: nextSnapshot)

            try? await Task.sleep(for: .seconds(1))
        }
    }

    func stop() async {
        isMonitoring = false
        await activity?.end(nil, dismissalPolicy: .immediate)
        activity = nil
    }

    private func updateSystemSurfaces(with snapshot: NetworkSnapshot) {
        WidgetCenter.shared.reloadTimelines(ofKind: NetworkSurfaceConstants.widgetKind)

        Task {
            await activity?.update(
                ActivityContent(
                    state: NetworkActivityAttributes.ContentState(snapshot: snapshot),
                    staleDate: Date().addingTimeInterval(10)
                )
            )
        }
    }

    private func startLiveActivityIfNeeded() async {
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
