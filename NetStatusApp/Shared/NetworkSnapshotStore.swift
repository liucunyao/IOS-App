import Foundation

public struct NetworkSnapshotStore: Sendable {
    public static let appGroupIdentifier = "group.com.example.NetStatus"

    private let defaults: UserDefaults
    private let snapshotKey = "latestNetworkSnapshot"

    public init(appGroupIdentifier: String = Self.appGroupIdentifier) {
        self.defaults = UserDefaults(suiteName: appGroupIdentifier) ?? .standard
    }

    public func load() -> NetworkSnapshot {
        guard let data = defaults.data(forKey: snapshotKey),
              let snapshot = try? JSONDecoder().decode(NetworkSnapshot.self, from: data) else {
            return .empty
        }

        return snapshot
    }

    public func save(_ snapshot: NetworkSnapshot) {
        guard let data = try? JSONEncoder().encode(snapshot) else {
            return
        }

        defaults.set(data, forKey: snapshotKey)
    }
}
