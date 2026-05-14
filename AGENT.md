# Network Status iOS App Plan

## Summary

- Target platform: iOS 26+.
- Main app shows real-time upload/download throughput by sampling once per second while monitoring is active.
- Lock Screen and Dynamic Island use ActivityKit Live Activities for real-time or near-real-time display.
- Regular Home Screen widgets cannot guarantee continuous per-second updates. They should show the latest saved sample and make the timestamp visible.

## Product Boundary

- Do not use private APIs, jailbreak-only approaches, or non-App-Store-safe mechanisms.
- "Real-time" is promised only for the main app, Lock Screen Live Activity, and Dynamic Island.
- Regular WidgetKit widgets are treated as recent-status surfaces, not a live per-second dashboard.

## Implementation Shape

- Xcode project: `NetStatusApp/NetworkStatus.xcodeproj`.
- Shared scheme: `NetStatusApp/NetworkStatus.xcodeproj/xcshareddata/xcschemes/NetworkStatus.xcscheme`.
- App target: `NetworkStatus`.
- Widget Extension target: `NetworkStatusWidget`.
- Minimum deployment target: iOS 26.0.
- Asset catalog: `NetStatusApp/App/Assets.xcassets` currently provides `AccentColor` only. A production AppIcon still needs a real icon asset.
- Placeholder identifiers currently need replacement before device signing:
  - App bundle ID: `com.example.NetworkStatus`
  - Widget bundle ID: `com.example.NetworkStatus.widget`
  - App Group: `group.com.example.NetStatus`

## Key Components

- `NetStatusApp/App/NetworkStatusModel.swift`
  - Owns monitoring lifecycle.
  - Starts/stops a cancellable sampling task.
  - Samples every second while active.
  - Saves snapshots to App Group storage.
  - Updates Live Activity every second.
  - Throttles regular Widget timeline reload requests.

- `NetStatusApp/Shared/NetworkSpeedSampler.swift`
  - Reads interface byte counters with `getifaddrs`.
  - Computes upload/download byte deltas per elapsed second.
  - Uses `NWPathMonitor` to classify Wi-Fi, cellular, wired, or unknown.

- `NetStatusApp/Shared/NetworkSnapshotStore.swift`
  - Stores the latest `NetworkSnapshot` in App Group `UserDefaults`.
  - App and Widget targets must use the same App Group value.

- `NetStatusApp/Widget/NetworkLiveActivityWidget.swift`
  - ActivityKit Lock Screen and Dynamic Island presentation.
  - This is the primary system surface for live network speeds.

- `NetStatusApp/Widget/NetworkWidget.swift`
  - Regular Home Screen and accessory widgets.
  - Displays the latest saved sample and "Updated ..." timestamp.
  - Must not claim guaranteed per-second updates.

## UI Direction

- Main app uses SwiftUI with iOS 26 Liquid Glass-style surfaces where available.
- Provide fallbacks for earlier APIs only where source compatibility needs it, but product target remains iOS 26+.
- Primary view should show:
  - download speed
  - upload speed
  - network type
  - interface name
  - last sample time
  - monitoring state
  - start/stop control

## Validation Plan

- On macOS with Xcode 26:
  - Build the app and widget extension.
  - Replace placeholder bundle IDs and App Group with real Apple Developer identifiers.
  - Add a production AppIcon asset before archiving for distribution.
  - Enable App Groups and Live Activities capabilities.
  - Run on an iOS 26 device or simulator.

- Runtime checks:
  - Main app updates upload/download speeds once per second while monitoring is active.
  - Stop button cancels sampling and ends the Live Activity.
  - Live Activity appears on Lock Screen and Dynamic Island and updates from current snapshots.
  - Regular widget reads the latest stored snapshot and shows the last update time.

## Environment Note

- This workspace is currently on Windows/PowerShell.
- `xcodebuild` and `swift` were not available during implementation, so final compile/sign/run verification must happen on macOS with Xcode 26.
