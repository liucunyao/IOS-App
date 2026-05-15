# Network Status iOS App 项目上下文

本文档用于给后续新对话或新 agent 快速读取项目背景。开始任何开发前，优先阅读本文件。

## 项目目标

- 开发一个 iOS 26+ 手机端 App，用于监测苹果手机当前网络情况。
- 核心数据包括：
  - 下载速率
  - 上传速率
  - 网络类型，例如 Wi-Fi、蜂窝、以太网、未知
  - 网络接口名称
  - 最近采样时间
- 主 App 内需要每秒实时展示上传/下载速率。
- 锁屏与灵动岛通过 ActivityKit Live Activity 展示实时或近实时结果。
- 普通主屏 Widget 只能展示最近一次保存的网络快照和更新时间，不能承诺秒级实时刷新。

## 重要技术边界

- 不使用私有 API。
- 不使用越狱、抓包常驻、VPN 扩展伪装或其他非 App Store 合规方案。
- “实时展示”只承诺给：
  - 主 App
  - 锁屏 Live Activity
  - Dynamic Island / 灵动岛
- 普通 WidgetKit 主屏小组件不支持连续秒级实时刷新，刷新频率由系统调度控制。
- 普通 Widget 的产品语义必须是“最新状态”或“最近样本”，不要写成真正实时仪表盘。

## 当前仓库状态

- 工作区根目录：`F:\L\Codex\IOS App`
- 主要工程目录：`NetStatusApp`
- Xcode 工程：`NetStatusApp/NetworkStatus.xcodeproj`
- 共享 Scheme：`NetStatusApp/NetworkStatus.xcodeproj/xcshareddata/xcschemes/NetworkStatus.xcscheme`
- App target：`NetworkStatus`
- Widget Extension target：`NetworkStatusWidget`
- deployment target：`iOS 26.0`
- 中文进度文档：`readme_Chinese.md`
- 本上下文文件：`AGENT.md`

## 已完成内容

- 已将目标平台调整为 iOS 26+。
- 已创建完整 Xcode 工程 `NetworkStatus.xcodeproj`。
- 已创建共享 Scheme，方便 Xcode 直接选择并运行 App target。
- 已配置 App target 和 Widget Extension target。
- 已新增 App/Widget 的 `Info.plist`。
- 已新增 App/Widget entitlements，并配置 App Group 占位值。
- 已新增基础资产目录 `NetStatusApp/App/Assets.xcassets` 和 `AccentColor`。
- 已实现主 App SwiftUI UI，并采用 iOS 26 Liquid Glass 风格表面。
- 已实现主 App 开始/停止监测按钮。
- 已修复采样生命周期：使用可取消 Task，避免监测循环无法停止。
- 已实现每秒采样上传/下载速率。
- 已通过 App Group `UserDefaults` 保存最新网络快照。
- 已实现 ActivityKit Live Activity 数据结构。
- 已实现锁屏和灵动岛展示：
  - Dynamic Island expanded
  - Dynamic Island compact
  - Dynamic Island minimal
  - Lock Screen Live Activity
- 已实现普通 Widget 展示最新保存样本，并显示更新时间。
- 已将普通 Widget 文案调整为“latest saved sample / Updated ...”，避免误导为秒级实时。
- 已写入中文项目进度文档 `readme_Chinese.md`。
- 已提交并推送到 GitHub。

## 关键提交

- `3d28add Implement iOS 26 network status app`
  - 实现 iOS 26 App/Widget 工程、Live Activity、主 App UI、采样生命周期、entitlements、Info.plist、Xcode project。
- `a71c9cf 项目进度情况汇总`
  - 写入中文项目进度说明。
- `e830591 Rename Chinese README`
  - 将根目录中文 README 改名为 `readme_Chinese.md`。

## 未完成内容 / 待处理事项

- 尚未在 macOS + Xcode 26 环境下编译验证。
- 尚未在 iOS 26 真机或模拟器上运行验证。
- 当前 Windows 环境不能运行 iOS Simulator，也没有 `xcodebuild` 和 `swift`。
- 需要替换占位 Bundle ID：
  - App：`com.example.NetworkStatus`
  - Widget：`com.example.NetworkStatus.widget`
- 需要替换占位 App Group：
  - `group.com.example.NetStatus`
- 替换 App Group 时需要同步修改：
  - `NetStatusApp/Shared/NetworkSnapshotStore.swift`
  - `NetStatusApp/App/NetworkStatus.entitlements`
  - `NetStatusApp/Widget/NetworkStatusWidget.entitlements`
- 需要在 Xcode 中配置真实 Apple Developer Team。
- 需要在 Xcode 中为 App target 启用：
  - App Groups
  - Live Activities
- 需要在 Xcode 中为 Widget target 启用：
  - App Groups
- 需要添加正式 AppIcon。当前只配置了 `AccentColor`。
- 需要在 iOS 26 真机上验证：
  - 主 App 每秒采样是否正常。
  - 停止按钮是否能停止采样并结束 Live Activity。
  - 锁屏 Live Activity 是否展示并更新。
  - 灵动岛 compact/expanded/minimal 是否展示并更新。
  - 普通 Widget 是否能读取最新保存快照并显示更新时间。
- 若准备上架，还需要补充：
  - 隐私说明
  - App 图标
  - App Store 截图
  - TestFlight 测试
  - App Store Connect 元数据

## Windows 环境下的测试限制

- Windows 可以做：
  - 修改 Swift 源码
  - 修改 Xcode 工程文件
  - 维护 Git
  - 写文档
  - 检查 plist/xml/json 等静态文件
- Windows 不能完整做：
  - 运行 iOS Simulator
  - 使用 Xcode 真机构建
  - 使用 `xcodebuild` 编译 iOS App
  - 生成可上架的签名 `.ipa`
  - 验证 Live Activity 和灵动岛运行效果
- 本项目最终必须在 macOS + Xcode 26 上编译、签名和运行验证。

## App Store / TestFlight 相关结论

- 不能把当前 Windows 源码“直接放到 App Store”再下载测试。
- App Store 正式上架需要：
  - Apple Developer Program
  - App Store Connect
  - 真实 Bundle ID
  - 真实 App Group
  - 证书和 provisioning profile
  - Xcode 或 Xcode Cloud 构建上传
  - Apple 审核通过
- 正式上架前的测试应使用 TestFlight。
- 推荐测试路径：
  1. 准备 macOS + Xcode 26。
  2. 打开 `NetStatusApp/NetworkStatus.xcodeproj`。
  3. 替换真实 Bundle ID、App Group、Team。
  4. 启用 App Groups 和 Live Activities。
  5. 添加正式 AppIcon。
  6. 用 iOS 26 真机直接 Run 测试。
  7. 确认主 App、Widget、Live Activity、灵动岛都正常。
  8. 上传到 App Store Connect。
  9. 用 TestFlight 安装测试版。

## 关键源码文件

- `NetStatusApp/App/NetworkStatusApp.swift`
  - App 入口。
  - 当前启动时会调用 `monitor.start()`。
- `NetStatusApp/App/ContentView.swift`
  - 主 App UI。
  - 显示下载速率、上传速率、网络类型、接口名、最近采样时间、监测状态、开始/停止按钮。
  - 使用 iOS 26 `glassEffect`，并提供 fallback。
- `NetStatusApp/App/NetworkStatusModel.swift`
  - 监测生命周期。
  - 持有 `NetworkSpeedSampler`、`NetworkSnapshotStore`、Live Activity。
  - 每秒采样、保存快照、更新 Live Activity。
  - 对普通 Widget timeline reload 做节流。
- `NetStatusApp/Shared/NetworkSpeedSampler.swift`
  - 使用 `getifaddrs` 读取接口计数。
  - 根据字节差值计算速率。
  - 使用 `NWPathMonitor` 判断网络类型。
- `NetStatusApp/Shared/NetworkSnapshot.swift`
  - 网络快照模型和速率格式化。
- `NetStatusApp/Shared/NetworkSnapshotStore.swift`
  - App Group 存储桥。
- `NetStatusApp/Shared/NetworkActivityAttributes.swift`
  - ActivityKit attributes 和 content state。
- `NetStatusApp/Shared/NetworkSurfaceConstants.swift`
  - Widget kind 常量。
- `NetStatusApp/Widget/NetworkWidget.swift`
  - 普通 Widget。
  - 展示最新保存样本，不承诺实时。
- `NetStatusApp/Widget/NetworkLiveActivityWidget.swift`
  - 锁屏 Live Activity 和灵动岛 UI。
- `NetStatusApp/Widget/NetworkWidgetBundle.swift`
  - Widget bundle 入口。

## 实现注意事项

- 如果继续修改 UI，保持 iOS 26+ 目标，不要退回 iOS 17 语义。
- 如果修改普通 Widget，不要写“实时秒级刷新”的承诺。
- 如果修改 App Group，必须保证 App target、Widget target、代码中的 group id 三处一致。
- 如果要验证构建，优先在 macOS/Xcode 26 执行，而不是在 Windows 上猜测。
- 当前仓库 remote：
  - `origin = https://github.com/liucunyao/IOS-App.git`
- 之前 `git push` 在沙箱内会因为 Windows schannel 凭证失败，需要在沙箱外使用系统 Git 凭证推送。

## 下一步建议

1. 在 macOS + Xcode 26 打开 `NetStatusApp/NetworkStatus.xcodeproj`。
2. 替换真实 Bundle ID、App Group 和 Apple Developer Team。
3. 启用 App Groups 与 Live Activities capability。
4. 添加正式 AppIcon。
5. 在 iOS 26 真机上运行主 App。
6. 验证主 App 每秒速率变化。
7. 验证停止按钮可以结束采样和 Live Activity。
8. 验证锁屏与灵动岛展示。
9. 添加普通 Widget，验证它能显示最近样本和更新时间。
10. 通过 TestFlight 做外部分发测试，不要直接依赖正式 App Store 上架作为开发测试方式。
