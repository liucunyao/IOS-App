import ActivityKit
import Foundation

public struct NetworkActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        public var snapshot: NetworkSnapshot

        public init(snapshot: NetworkSnapshot) {
            self.snapshot = snapshot
        }
    }

    public var title: String

    public init(title: String) {
        self.title = title
    }
}
