# Network Status iOS App Skeleton

This workspace contains the source skeleton for a simple iOS app that monitors current network throughput and presents it in:

- the main SwiftUI app
- Home Screen widgets
- Lock Screen widgets
- Live Activities
- Dynamic Island

## Xcode Setup

Create a new iOS app project in Xcode, then add a Widget Extension with Live Activity support.

Suggested settings:

- Product name: `NetworkStatus`
- Interface: `SwiftUI`
- Minimum deployment: iOS 17.0
- App Group: `group.com.example.NetStatus`

Replace `group.com.example.NetStatus` in `Shared/NetworkSnapshotStore.swift` with your real App Group identifier.

## Target Membership

Add these files to both the app target and widget extension target:

- `Shared/NetworkSnapshot.swift`
- `Shared/NetworkSnapshotStore.swift`
- `Shared/NetworkActivityAttributes.swift`
- `Shared/NetworkSurfaceConstants.swift`

Add this file to the app target only:

- `Shared/NetworkSpeedSampler.swift`
- `App/NetworkStatusApp.swift`
- `App/NetworkStatusModel.swift`
- `App/ContentView.swift`

Add these files to the widget extension target only:

- `Widget/NetworkWidgetBundle.swift`
- `Widget/NetworkWidget.swift`
- `Widget/NetworkLiveActivityWidget.swift`

## Capabilities

Enable these capabilities:

- App target: App Groups
- Widget extension target: App Groups
- App target: Live Activities

Add this key to the app target `Info.plist`:

```xml
<key>NSSupportsLiveActivities</key>
<true/>
```

## Runtime Model

The app samples interface byte counters once per second while running. Each sample is written into App Group storage. The widget reads the most recent sample from that shared store. The Live Activity is updated through ActivityKit, which drives Lock Screen and Dynamic Island presentation.

For a simple App Store-friendly first version, keep monitoring user-initiated: the user opens the app, starts monitoring, and the app keeps Live Activity surfaces updated while iOS allows the activity to run.

## Product Notes

Home Screen widgets are best treated as "recent status" surfaces. Lock Screen and Dynamic Island should be the primary near-live surfaces because ActivityKit is designed for live data presentation.
