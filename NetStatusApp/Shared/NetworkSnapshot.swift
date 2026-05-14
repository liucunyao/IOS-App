import Foundation

public struct NetworkSnapshot: Codable, Hashable, Sendable {
    public var downloadBytesPerSecond: Double
    public var uploadBytesPerSecond: Double
    public var interfaceName: String
    public var networkKind: NetworkKind
    public var sampledAt: Date

    public init(
        downloadBytesPerSecond: Double,
        uploadBytesPerSecond: Double,
        interfaceName: String,
        networkKind: NetworkKind,
        sampledAt: Date = .now
    ) {
        self.downloadBytesPerSecond = downloadBytesPerSecond
        self.uploadBytesPerSecond = uploadBytesPerSecond
        self.interfaceName = interfaceName
        self.networkKind = networkKind
        self.sampledAt = sampledAt
    }

    public static let empty = NetworkSnapshot(
        downloadBytesPerSecond: 0,
        uploadBytesPerSecond: 0,
        interfaceName: "--",
        networkKind: .unknown,
        sampledAt: .distantPast
    )
}

public enum NetworkKind: String, Codable, Hashable, Sendable {
    case wifi
    case cellular
    case wired
    case unknown

    public var displayName: String {
        switch self {
        case .wifi: return "Wi-Fi"
        case .cellular: return "Cellular"
        case .wired: return "Wired"
        case .unknown: return "Unknown"
        }
    }
}

public extension Double {
    var speedText: String {
        let units = ["B/s", "KB/s", "MB/s", "GB/s"]
        var value = self
        var index = 0

        while value >= 1024, index < units.count - 1 {
            value /= 1024
            index += 1
        }

        if index == 0 {
            return "\(Int(value)) \(units[index])"
        }

        return String(format: "%.1f %@", value, units[index])
    }
}
