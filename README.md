# IOS-App

## 项目目标

开发一个 iOS 26+ 的网络状态监测 App，用于展示苹果手机当前网络情况，包括上传速率、下载速率、网络类型、接口名称等。

核心展示方式：

- 主 App：每秒采样并实时展示上传/下载速率。
- 锁屏与灵动岛：通过 ActivityKit Live Activity 展示实时或近实时结果。
- 普通主屏小组件：展示最近一次保存的网络状态和更新时间。由于 WidgetKit 不支持普通小组件连续秒级实时刷新，因此这里不承诺普通主屏小组件像 App 内仪表盘一样实时跳动。

## 已完成内容

- 已将目标系统定位为 iOS 26+。
- 已创建 Xcode 工程：`NetStatusApp/NetworkStatus.xcodeproj`。
- 已创建共享 Scheme：`NetStatusApp/NetworkStatus.xcodeproj/xcshareddata/xcschemes/NetworkStatus.xcscheme`。
- 已配置两个 target：
  - App target：`NetworkStatus`
  - Widget Extension target：`NetworkStatusWidget`
- 已将 deployment target 设置为 `26.0`。
- 已实现主 App SwiftUI 界面，并使用 iOS 26 Liquid Glass 风格表面。
- 已实现开始/停止监测控制。
- 已实现可取消的每秒采样任务，避免监测循环无法停止。
- 已保留并接入网络速率采样逻辑：
  - 使用 `getifaddrs` 读取网络接口字节计数。
  - 计算上传/下载字节差值。
  - 使用 `NWPathMonitor` 判断 Wi-Fi、蜂窝、以太网或未知网络类型。
- 已实现 `NetworkSnapshot` 数据模型。
- 已实现 `NetworkSnapshotStore`，通过 App Group `UserDefaults` 保存最新网络快照。
- 已实现 ActivityKit Live Activity 数据结构。
- 已实现锁屏和灵动岛展示：
  - Dynamic Island expanded
  - Dynamic Island compact
  - Dynamic Island minimal
  - Lock Screen Live Activity
- 已实现普通 Widget 展示最新保存样本，并显示更新时间。
- 已限制普通 Widget 的语义为“最新状态”，避免误导为秒级实时展示。
- 已新增 App/Widget 所需的 `Info.plist`。
- 已新增 App/Widget entitlements，并配置 App Group 占位值。
- 已新增基础资产目录 `Assets.xcassets` 和 `AccentColor`。
- 已编写 `AGENT.md`，记录后续 agent 读取用的项目计划、边界和当前实现状态。
- 已将改动提交并推送到 GitHub：
  - commit：`3d28add Implement iOS 26 network status app`

## 未完成内容 / 待处理事项

- 尚未在 macOS + Xcode 26 环境下编译验证。
- 尚未在 iOS 26 真机或模拟器上运行验证。
- 当前 Windows 环境没有 `xcodebuild` 和 `swift`，因此无法在本地完成最终构建检查。
- 需要替换占位 Bundle ID：
  - App：`com.example.NetworkStatus`
  - Widget：`com.example.NetworkStatus.widget`
- 需要替换占位 App Group：
  - `group.com.example.NetStatus`
- 替换 App Group 时，需要同步修改：
  - `NetStatusApp/Shared/NetworkSnapshotStore.swift`
  - `NetStatusApp/App/NetworkStatus.entitlements`
  - `NetStatusApp/Widget/NetworkStatusWidget.entitlements`
- 需要在 Xcode 中为真实 Apple Developer Team 启用能力：
  - App target：App Groups、Live Activities
  - Widget target：App Groups
- 需要添加正式 AppIcon，当前只配置了 `AccentColor`。
- 需要在真机上验证主 App 每秒采样是否符合预期。
- 需要在真机上验证 Live Activity、锁屏和灵动岛更新效果。
- 需要验证普通 Widget 能读取最新保存快照，并正确显示更新时间。
- 若准备上架，还需要补充隐私说明、应用图标、展示截图、TestFlight 验证和 App Store 元数据。

## 当前技术边界

- 不使用私有 API。
- 不使用越狱或非 App Store 合规方案。
- “实时展示”只承诺给主 App、锁屏 Live Activity 和灵动岛。
- 普通主屏 Widget 只能作为最近状态展示入口，刷新频率由系统调度决定。

## 下一步建议

1. 在 macOS + Xcode 26 中打开 `NetStatusApp/NetworkStatus.xcodeproj`。
2. 替换真实 Bundle ID、App Group 和 Apple Developer Team。
3. 启用 App Groups 与 Live Activities。
4. 添加正式 AppIcon。
5. 在 iOS 26 真机上运行并验证：
   - App 内每秒速率变化。
   - 停止按钮能结束采样和 Live Activity。
   - 灵动岛/锁屏能展示最新速率。
   - 普通 Widget 能展示最近样本和更新时间。
