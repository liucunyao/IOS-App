# Network Status

Network Status is an iOS 26+ SwiftUI app for monitoring current device network throughput.

## What is real time

- Main app: samples upload and download speed once per second while monitoring is active.
- Lock Screen and Dynamic Island: updated through ActivityKit Live Activities.
- Home Screen widget: shows the latest saved sample from App Group storage. WidgetKit does not support guaranteed continuous per-second updates for regular widgets, so this surface intentionally labels the data as the latest sample.

## Project layout

- `NetworkStatus.xcodeproj`: Xcode project with the app target and widget extension target.
- `NetworkStatus.xcodeproj/xcshareddata/xcschemes/NetworkStatus.xcscheme`: shared app scheme.
- `App/`: SwiftUI app, iOS 26 glass-oriented UI, monitoring lifecycle, Live Activity updates.
- `App/Assets.xcassets`: app accent color. Add a real AppIcon before distribution.
- `Shared/`: network snapshot model, App Group store, sampler, ActivityKit attributes.
- `Widget/`: regular widgets plus Lock Screen, Dynamic Island, and Live Activity UI.

## Required signing changes

Before running on a real device, replace the placeholder identifiers:

- App bundle identifier: `com.example.NetworkStatus`
- Widget bundle identifier: `com.example.NetworkStatus.widget`
- App Group: `group.com.example.NetStatus`

Update the same App Group value in:

- `Shared/NetworkSnapshotStore.swift`
- `App/NetworkStatus.entitlements`
- `Widget/NetworkStatusWidget.entitlements`

Enable these capabilities in Xcode for the matching targets:

- App target: App Groups, Live Activities
- Widget target: App Groups

Add a production `AppIcon` asset before archiving for TestFlight or App Store distribution.

The app target includes:

- `NSSupportsLiveActivities`
- `NSSupportsLiveActivitiesFrequentUpdates`

## Validation

This repository was updated from a Windows workspace, where `xcodebuild` and the iOS simulator are not available. Final validation must be done on macOS with Xcode 26 and an iOS 26 device or simulator.
