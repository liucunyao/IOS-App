import Foundation
import Network

#if canImport(Darwin)
import Darwin
#endif

public actor NetworkSpeedSampler {
    private struct InterfaceCounters: Sendable {
        var receivedBytes: UInt64
        var sentBytes: UInt64
        var interfaceName: String
    }

    private var previousCounters: InterfaceCounters?
    private var previousDate: Date?
    private let pathMonitor = NWPathMonitor()
    private let pathQueue = DispatchQueue(label: "network.path.monitor")
    private var currentPath: NWPath?

    public init() {
        pathMonitor.pathUpdateHandler = { [weak self] path in
            Task {
                await self?.setCurrentPath(path)
            }
        }
        pathMonitor.start(queue: pathQueue)
    }

    deinit {
        pathMonitor.cancel()
    }

    public func sample() -> NetworkSnapshot {
        let now = Date()
        let counters = readCounters()
        defer {
            previousCounters = counters
            previousDate = now
        }

        guard let counters,
              let previousCounters,
              let previousDate else {
            return NetworkSnapshot(
                downloadBytesPerSecond: 0,
                uploadBytesPerSecond: 0,
                interfaceName: counters?.interfaceName ?? "--",
                networkKind: networkKind(),
                sampledAt: now
            )
        }

        let elapsed = max(now.timeIntervalSince(previousDate), 0.1)
        let receivedDelta = counters.receivedBytes >= previousCounters.receivedBytes
            ? counters.receivedBytes - previousCounters.receivedBytes
            : 0
        let sentDelta = counters.sentBytes >= previousCounters.sentBytes
            ? counters.sentBytes - previousCounters.sentBytes
            : 0

        return NetworkSnapshot(
            downloadBytesPerSecond: Double(receivedDelta) / elapsed,
            uploadBytesPerSecond: Double(sentDelta) / elapsed,
            interfaceName: counters.interfaceName,
            networkKind: networkKind(),
            sampledAt: now
        )
    }

    private func setCurrentPath(_ path: NWPath) {
        currentPath = path
    }

    private func networkKind() -> NetworkKind {
        guard let currentPath else {
            return .unknown
        }

        if currentPath.usesInterfaceType(.wifi) {
            return .wifi
        }

        if currentPath.usesInterfaceType(.cellular) {
            return .cellular
        }

        if currentPath.usesInterfaceType(.wiredEthernet) {
            return .wired
        }

        return .unknown
    }

    private nonisolated func readCounters() -> InterfaceCounters? {
        var addresses: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&addresses) == 0, let firstAddress = addresses else {
            return nil
        }

        defer {
            freeifaddrs(addresses)
        }

        var receivedBytes: UInt64 = 0
        var sentBytes: UInt64 = 0
        var activeNames: [String] = []
        var pointer: UnsafeMutablePointer<ifaddrs>? = firstAddress

        while pointer != nil {
            guard let interface = pointer?.pointee else {
                pointer = pointer?.pointee.ifa_next
                continue
            }

            let flags = Int32(interface.ifa_flags)
            let isUp = (flags & IFF_UP) == IFF_UP
            let isRunning = (flags & IFF_RUNNING) == IFF_RUNNING
            let isLoopback = (flags & IFF_LOOPBACK) == IFF_LOOPBACK

            if isUp, isRunning, !isLoopback,
               let namePointer = interface.ifa_name,
               let dataPointer = interface.ifa_data {
                let name = String(cString: namePointer)

                if isLikelyUserNetworkInterface(name) {
                    let data = dataPointer.assumingMemoryBound(to: if_data.self).pointee
                    receivedBytes += UInt64(data.ifi_ibytes)
                    sentBytes += UInt64(data.ifi_obytes)
                    activeNames.append(name)
                }
            }

            pointer = interface.ifa_next
        }

        guard receivedBytes > 0 || sentBytes > 0 else {
            return nil
        }

        return InterfaceCounters(
            receivedBytes: receivedBytes,
            sentBytes: sentBytes,
            interfaceName: activeNames.sorted().joined(separator: ",")
        )
    }

    private nonisolated func isLikelyUserNetworkInterface(_ name: String) -> Bool {
        name.hasPrefix("en") ||
        name.hasPrefix("pdp_ip") ||
        name.hasPrefix("utun") ||
        name.hasPrefix("ipsec")
    }
}
