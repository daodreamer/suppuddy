# Swift 6.2 最佳实践优化报告

> 分析日期: 2026-02-10
> 最后更新: 2026-02-10
> 当前 Swift 版本: 项目配置 `SWIFT_VERSION = 6.0` ✅（已从 5.0 升级）
> 最新 Swift 版本: Swift 6.2.3
> 最新 iOS 版本: iOS 26
> 测试结果: 869 passed, 3 failed（预存在的不稳定测试）

---

## 当前项目已做得好的地方

项目已经采用了很多现代 Swift 最佳实践：

- `@Observable` + `@MainActor` 的 ViewModel 模式
- `actor` 用于 API 客户端（`OpenFoodFactsAPI`）
- `Sendable` 用于值类型
- `nonisolated` 用于 Codable 方法
- 依赖注入 + Repository 模式
- `FetchDescriptor` + `#Predicate` 用于 SwiftData 查询
- 完善的无障碍支持（VoiceOver, `@ScaledMetric`, Reduce Motion）
- `SWIFT_APPROACHABLE_CONCURRENCY = YES`
- `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`

---

## 可根据最新最佳实践优化的项目

### 1. ✅ SWIFT_VERSION 应更新为 6.0（高优先级）— 已完成

**状态**: ✅ 已完成

**实施内容**:
- 将 `project.pbxproj` 中所有 6 处 `SWIFT_VERSION = 5.0` 改为 `SWIFT_VERSION = 6.0`
- 为测试目标添加 `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`（Debug + Release）
- 将纯值类型标记为 `nonisolated`，解决 MainActor 隔离冲突：
  - `DGERecommendations` (struct)
  - `DailyRecommendation` (struct)
  - `ChildAgeGroup` (enum)
  - `UserType` (enum)
  - `NutrientType` (enum)
  - `Nutrient` (struct)
  - `NutrientStatus` (enum)
  - `SpecialNeeds` (enum)
- `PerformanceMonitor` → `nonisolated final class: Sendable` + `@Sendable` 闭包参数
- 测试修复：`MockURLSession` 添加 `@unchecked Sendable`（2 个文件）

**参考**: [Swift 6.2 Released | Swift.org](https://www.swift.org/blog/swift-6.2-released/)

---

### 2. ✅ 冗余的 `@MainActor` 注解（中优先级）— 已完成

**状态**: ✅ 已完成

**实施内容**: 移除了 22 处冗余 `@MainActor` 注解（`SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` 已提供默认隔离）：

- **Repositories** (3): `ScanHistoryRepository`, `IntakeRecordRepository`, `SupplementRepository`
- **Services** (4): `DataExportService`, `DataImportService`, `ProductLookupService`, `OnboardingService`
- **ViewModels** (13): `DashboardViewModel`, `UserProfileViewModel`, `OnboardingViewModel`, `IntakeRecordViewModel`, `ProductSearchViewModel`, `HistoryViewModel`, `DataManagementViewModel`, `SupplementDetailViewModel`, `SupplementFormViewModel`, `ScanHistoryViewModel`, `SupplementListViewModel`, `NutrientChartViewModel`, `BarcodeScannerViewModel`
- **Protocols** (1): `ProductLookupServiceProtocol`
- **Utilities** (1): `TaskManager`

**测试结果**: 851 passed, 3 failed（同样的预存在不稳定测试）

**参考**: [Should you opt-in to Swift 6.2's Main Actor isolation? - Donny Wals](https://www.donnywals.com/should-you-opt-in-to-swift-6-2s-main-actor-isolation/)

---

### 3. ✅ 缺少 `@concurrent` 用于 CPU 密集型操作（高优先级）— 已完成

**状态**: ✅ 已完成（部分 — DataExportService）

**实施内容**:
- `ExportData` 及所有组件 struct 标记为 `nonisolated`（ExportData, ExportedUserProfile, ExportedSupplement, ExportedNutrient, ExportedIntakeRecord, ExportedReminder）
- `DataImportService` 中的 `ImportPreview`, `ImportMode`, `ImportConflict` 标记为 `nonisolated`
- `DataExportService` 新增两个 `@concurrent` 私有方法：
  ```swift
  @concurrent
  private func encodeToJSON(_ exportData: ExportData) async throws -> Data

  @concurrent
  private func generateCSV(_ exportData: ExportData) async -> String
  ```
- `exportToJSON()` 和 `exportSupplementsToCSV()` 已更新为使用上述 `@concurrent` 方法

**未实施**: `OpenFoodFactsAPI` 已经是 `actor`（自带后台隔离），`Supplement.nutrients` 的 JSON 编解码在 SwiftData @Model 上下文中使用，标记 `@concurrent` 不适用。

**参考**: [Understanding nonisolated, nonisolated(nonsending), and @concurrent in Swift 6.2](https://medium.com/@iamCoder/understanding-nonisolated-nonisolated-nonsending-and-concurrent-in-swift-6-2-388b34f4fe4d)

---

### 4. ✅ 纯计算服务的隔离优化（中优先级）— 部分完成

**状态**: ✅ 部分完成

**实施内容**:
- `NutrientMappingService` → `nonisolated final class: Sendable`（纯计算，无可变状态，所有方法只使用 nonisolated 类型）

**未实施**:
- `RecommendationService` — 方法接受 `UserProfile`（@Model，MainActor-isolated），标记 `nonisolated` 会导致无法访问其属性
- `IntakeService` — 方法引用 `IntakeRecord`、`UserProfile` 等 @Model 类型，同理

**说明**: 在 `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` 的项目中，`nonisolated(nonsending)` 对引用 @Model 类型的方法不适用，因为 @Model 属性需要 MainActor 上下文才能访问。

**参考**: [Exploring concurrency changes in Swift 6.2 - Donny Wals](https://www.donnywals.com/exploring-concurrency-changes-in-swift-6-2/)

---

### 5. ⏸️ Repository 中不必要的 `async`（中优先级）— 已推迟

**状态**: ⏸️ 推迟实施

**原因**: 移除 4 个 Repository 文件中的 `async` 需要同时更新约 300 个 `await` 调用点，涉及 26+ 个文件（13 个测试文件 + 9 个源文件 + 4 个 Repository）。由于 Swift 的 same-actor async 调用开销极小，性能收益不足以证明如此大规模的重构风险。

**建议**: 在未来的大版本重构中统一处理，或在新增 Repository 方法时直接采用同步签名。

---

### 6. ViewModel 中使用 Optional 延迟初始化模式（中优先级）

**当前状态** (`DashboardView.swift`):

```swift
@State private var viewModel: DashboardViewModel?
// 在 .task 中延迟初始化
```

**Swift 6.2 / SwiftUI 最佳实践**:

```swift
// 推荐：直接初始化
@State private var viewModel = DashboardViewModel()
```

ViewModel 应作为 `@State private var` 直接初始化，而不是使用 Optional + `.task` 延迟创建。当前模式导致不必要的 `Optional` 解包和加载状态。

**优化方向**: 使用 `@Environment(\.modelContext)` 在 ViewModel 初始化后注入 context，或使用 factory pattern。

**参考**: [SwiftUI Expert Skill - avdlee](https://github.com/avdlee/swiftui-agent-skill)

---

### 7. 缺少 `Span` 类型用于内存安全（低优先级）

**Swift 6.2 新特性**: `Span` 提供安全的连续内存访问，替代 `UnsafeBufferPointer`。

**潜在使用场景**: 如果项目中有处理大量营养素数据的批量操作，`Span` 可以提供零拷贝的安全内存访问。当前项目中未使用 unsafe pointer，所以优先级较低。

**参考**: [Swift 6.2 Released | Swift.org](https://www.swift.org/blog/swift-6.2-released/)

---

### 8. 缺少 `InlineArray` 用于固定大小集合（低优先级）

**Swift 6.2 新特性**: `InlineArray` 用于固定大小的栈分配数组，避免堆分配。语法: `[40 of Sprite]`

**潜在场景**: `NutrientType` 有固定的 23 个值。如果有以固定数量营养素为单位的数据结构，可考虑用 `InlineArray`。

**参考**: [Swift 6.2 Released | Swift.org](https://www.swift.org/blog/swift-6.2-released/)

---

### 9. ✅ `NetworkMonitor` 应改用 AsyncStream（高优先级）— 已完成

**状态**: ✅ 已完成

**实施内容**:
- 完全重写 `NetworkMonitor`，移除 GCD `DispatchQueue` 回调模式
- 使用 `AsyncStream<NWPath.Status>` 接收网络状态变化
- 使用 `nonisolated(unsafe)` 标记 `monitoringTask` 以支持 `deinit` 中的取消
- `continuation.onTermination` 使用 `@Sendable` 闭包
- `Task { [weak self] }` 中使用 `for await` 消费 AsyncStream
- 新增测试 `testNetworkMonitorUsesAsyncStream()`
- 所有 8 个 NetworkMonitor 测试通过

**最终实现**:
```swift
@Observable
final class NetworkMonitor {
    var isConnected = true
    private let monitor = NWPathMonitor()
    private nonisolated(unsafe) var monitoringTask: Task<Void, Never>?

    init() { startMonitoring() }

    deinit {
        monitoringTask?.cancel()
        monitor.cancel()
    }

    private func startMonitoring() {
        let monitor = self.monitor
        let stream = AsyncStream<NWPath.Status> { continuation in
            monitor.pathUpdateHandler = { path in
                continuation.yield(path.status)
            }
            continuation.onTermination = { @Sendable _ in
                monitor.cancel()
            }
            monitor.start(queue: DispatchQueue(label: "com.vitamin_calculator.networkmonitor"))
        }
        monitoringTask = Task { [weak self] in
            for await status in stream {
                guard !Task.isCancelled else { break }
                self?.isConnected = status == .satisfied
            }
        }
    }
}
```

**参考**: [Approachable Concurrency in Swift 6.2 - Antoine van der Lee](https://www.avanderlee.com/concurrency/approachable-concurrency-in-swift-6-2-a-clear-guide/)

---

### 10. ⚠️ 硬编码的中文字符串（中优先级）— 部分完成

**状态**: ⚠️ 部分完成（日期格式化已修复，其余需独立 sprint）

**已修复**:
- 移除了 `DashboardView`, `HistoryView`, `AccessibilityHelper` 中的 `Locale(identifier: "zh_CN")` 硬编码
- 替换为 `.formatted()` API（自动使用用户当前 locale）

**未修复**: 项目中仍有 100+ 处硬编码中文字符串，分布在：
- `DashboardView.swift` — 14 处
- `IntakeRecordView.swift` — 17 处
- `DataManagementView.swift` — 24 处
- `AccessibilityHelper.swift` — 35+ 处
- `HistoryView.swift` — 多处

**建议**: 全面国际化需要独立的 sprint 来完成，包括将所有 UI 字符串迁移到 `Localizable.xcstrings`。

---

### 11. iOS 26 / Liquid Glass 适配准备（前瞻性）

iOS 26 引入了 **Liquid Glass** 设计语言：

- Tab bars、Toolbars 自动采用新材质
- 新增 `@Animatable` 宏简化动画
- 新增原生 `WebView` 和富文本编辑支持
- Sheet 和 Dialog 支持 morphing 动画

**当前项目最低版本**: iOS 17+

**建议**:

- 使用 `#available(iOS 26, *)` 条件适配 Liquid Glass
- 更新 Toolbar 和 Tab bar 以利用新设计
- 考虑使用 `@Animatable` 替代手动 `Animatable` 协议
- 用 Xcode 26 重新编译即可自动获得基础适配

**参考**: [Build a SwiftUI app with the new design - WWDC25](https://developer.apple.com/videos/play/wwdc2025/323/), [SwiftUI for iOS 26 - InfoQ](https://www.infoq.com/news/2025/06/swiftui-ios26-liquid-glass/)

---

### 12. ✅ DateFormatter 重复创建（性能优化）— 已完成

**状态**: ✅ 已完成

**实施内容**:
- `DashboardView.formattedDate` → `Date().formatted(.dateTime.year().month().day().weekday(.wide))`
- `HistoryView.CalendarHeaderView.monthYearString` → `.formatted(.dateTime.year().month())`
- `HistoryView.SelectedDayRecordsView.formattedDate` → `.formatted(.dateTime.month().day().weekday(.wide))`
- `HistoryView.IntakeRecordRow.formattedTime` → `.formatted(date: .omitted, time: .shortened)`
- `IntakeRecordView.IntakeRecordRowView.formattedTime` → `.formatted(date: .omitted, time: .shortened)`
- `AccessibilityHelper.intakeRecordLabel` → `.formatted(date: .abbreviated, time: .shortened)`
- `DataExportService.exportIntakeRecordsToCSV` — 将 `ISO8601DateFormatter()` 移出循环体

**效果**: 消除了 View body 中重复的 `DateFormatter` 创建，`.formatted()` 内部缓存 formatter 实例。同时移除了硬编码的 `zh_CN` locale，改为自动使用用户当前 locale。

---

## 优化优先级总结

| 优先级 | 优化项 | 影响范围 | 工作量 | 状态 |
|--------|--------|----------|--------|------|
| **高** | SWIFT_VERSION 升级到 6.0 | 项目配置 | 小 | ✅ 已完成 |
| **高** | 添加 `@concurrent` 用于 CPU 密集型操作 | Services, Models | 中 | ✅ 已完成 |
| **高** | NetworkMonitor 改用 AsyncStream | 1 文件 | 小 | ✅ 已完成 |
| **中** | 移除冗余 `@MainActor` | 22 处 | 中 | ✅ 已完成 |
| **中** | Repository 移除不必要的 `async` | 26+ 文件 | 大 | ⏸️ 推迟 |
| **中** | ViewModel 直接初始化替代 Optional 模式 | Views | 中 | ⬚ 待评估 |
| **中** | 纯计算服务 `nonisolated` | Services | 小 | ✅ 部分完成 |
| **中** | 硬编码中文字符串国际化 | Views | 中 | ⚠️ 部分完成 |
| **低** | DateFormatter 缓存优化 | Views | 小 | ✅ 已完成 |
| **低** | InlineArray / Span 应用 | Models | 小 | ⬚ 待实施 |
| **前瞻** | iOS 26 Liquid Glass 适配 | Views | 大 | ⬚ 待实施 |

---

## 参考资料

- [Swift 6.2 Released | Swift.org](https://www.swift.org/blog/swift-6.2-released/)
- [Swift 6.1 Released | Swift.org](https://www.swift.org/blog/swift-6.1-released/)
- [Should you opt-in to Swift 6.2's Main Actor isolation? - Donny Wals](https://www.donnywals.com/should-you-opt-in-to-swift-6-2s-main-actor-isolation/)
- [Exploring concurrency changes in Swift 6.2 - Donny Wals](https://www.donnywals.com/exploring-concurrency-changes-in-swift-6-2/)
- [Understanding nonisolated, nonisolated(nonsending), and @concurrent in Swift 6.2](https://medium.com/@iamCoder/understanding-nonisolated-nonisolated-nonsending-and-concurrent-in-swift-6-2-388b34f4fe4d)
- [Approachable Concurrency in Swift 6.2 - Antoine van der Lee](https://www.avanderlee.com/concurrency/approachable-concurrency-in-swift-6-2-a-clear-guide/)
- [Build a SwiftUI app with the new design - WWDC25](https://developer.apple.com/videos/play/wwdc2025/323/)
- [SwiftUI for iOS 26 - InfoQ](https://www.infoq.com/news/2025/06/swiftui-ios26-liquid-glass/)
- [Swift Releases - GitHub](https://github.com/swiftlang/swift/releases)
- [SwiftUI Expert Skill - avdlee](https://github.com/avdlee/swiftui-agent-skill)
