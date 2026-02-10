# Swift 6.2 最佳实践优化报告

> 分析日期: 2026-02-10
> 当前 Swift 版本: 项目配置 `SWIFT_VERSION = 5.0`（实际使用 Swift 6 特性）
> 最新 Swift 版本: Swift 6.2.2
> 最新 iOS 版本: iOS 26

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

### 1. SWIFT_VERSION 应更新为 6.0（高优先级）

**当前状态**: `SWIFT_VERSION = 5.0`（6处配置）

**问题**: 虽然已启用了 `SWIFT_APPROACHABLE_CONCURRENCY` 和 `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`，但 Swift 版本号仍是 5.0，无法启用完整的 Swift 6 严格并发检查。

**建议**: 将 `SWIFT_VERSION` 改为 `6.0`，启用完整的数据竞争安全检查。

**参考**: [Swift 6.2 Released | Swift.org](https://www.swift.org/blog/swift-6.2-released/)

---

### 2. 冗余的 `@MainActor` 注解（中优先级）

**当前状态**: 所有 ViewModel、Service、Repository 都显式标记了 `@MainActor`

**Swift 6.2 变化**: 项目已设置 `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`，这意味着所有类型**默认就在 MainActor 上**，显式标注是冗余的。

**受影响的文件**（约30+个）:

- 所有 ViewModel 文件上的 `@MainActor`
- `ProductLookupService`, `DataExportService` 等 Service 上的 `@MainActor`
- `SupplementRepository`, `UserRepository` 等 Repository 上的 `@MainActor`

**建议**: 移除冗余的 `@MainActor`，仅在确实需要覆盖默认隔离的地方使用 `nonisolated` 或 `@concurrent`。

**参考**: [Should you opt-in to Swift 6.2's Main Actor isolation? - Donny Wals](https://www.donnywals.com/should-you-opt-in-to-swift-6-2s-main-actor-isolation/)

---

### 3. 缺少 `@concurrent` 用于 CPU 密集型操作（高优先级）

**当前状态**: 所有操作都在 MainActor 上运行

**Swift 6.2 新特性**: `@concurrent` 属性用于标记需要在后台线程执行的 CPU 密集型工作。

**应该标记为 `@concurrent` 的方法**:

- `DataExportService.exportToJSON()` — JSON 编码可能耗时
- `DataImportService` 中的数据验证和导入
- `OpenFoodFactsAPI.decodeProduct(from:)` — JSON 解码
- `Supplement` 的 `nutrients` computed property 中的 `JSONDecoder/JSONEncoder` 操作

```swift
// 优化前
func exportToJSON() async throws -> URL { ... }

// 优化后（Swift 6.2）
@concurrent
func exportToJSON() async throws -> URL { ... }
```

**参考**: [Understanding nonisolated, nonisolated(nonsending), and @concurrent in Swift 6.2](https://medium.com/@iamCoder/understanding-nonisolated-nonisolated-nonsending-and-concurrent-in-swift-6-2-388b34f4fe4d)

---

### 4. 缺少 `nonisolated(nonsending)` 标记（中优先级）

**Swift 6.2 新特性**: `nonisolated(nonsending)` 表示函数不触碰 actor 状态，且继承调用者的执行上下文。

**应该使用 `nonisolated(nonsending)` 的场景**:

- `RecommendationService` 的所有方法 — 纯计算，不涉及任何 actor 状态
- `IntakeService` 中的纯计算方法（`getDailySummary`, `generateHealthTips`）
- `NutrientMappingService` 的映射方法

**参考**: [Exploring concurrency changes in Swift 6.2 - Donny Wals](https://www.donnywals.com/exploring-concurrency-changes-in-swift-6-2/)

---

### 5. Repository 中不必要的 `async`（中优先级）

**当前状态**: 所有 Repository 方法都标记为 `async throws`

**问题**: `ModelContext` 的 `fetch()`, `insert()`, `save()`, `delete()` 都是**同步方法**。将它们包装成 `async` 是不必要的开销。

```swift
// 当前 — 不必要的 async
func getAll() async throws -> [Supplement] {
    let descriptor = FetchDescriptor<Supplement>()
    return try modelContext.fetch(descriptor)  // 这是同步调用
}

// 优化后
func getAll() throws -> [Supplement] {
    let descriptor = FetchDescriptor<Supplement>()
    return try modelContext.fetch(descriptor)
}
```

**受影响**: `SupplementRepository`, `UserRepository`, `IntakeRecordRepository`, `ScanHistoryRepository` 的几乎所有方法。

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

### 9. `NetworkMonitor` 应改用 AsyncStream（高优先级）

**当前状态** (`Utilities/NetworkMonitor.swift`):

```swift
@Observable
final class NetworkMonitor {
    var isConnected = true
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "...")

    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor [weak self] in
                self?.isConnected = path.status == .satisfied
            }
        }
        monitor.start(queue: queue)
    }
}
```

**问题**: 混合使用 GCD (`DispatchQueue`) 和 Swift Concurrency (`Task { @MainActor in }`) 不是最佳实践。

**Swift 6.2 建议**: 使用 `AsyncStream` 替代 GCD 回调模式：

```swift
@Observable
final class NetworkMonitor {
    var isConnected = true

    func startMonitoring() async {
        let monitor = NWPathMonitor()
        let stream = AsyncStream<NWPath> { continuation in
            monitor.pathUpdateHandler = { path in
                continuation.yield(path)
            }
            monitor.start(queue: .global())
        }
        for await path in stream {
            isConnected = path.status == .satisfied
        }
    }
}
```

**参考**: [Approachable Concurrency in Swift 6.2 - Antoine van der Lee](https://www.avanderlee.com/concurrency/approachable-concurrency-in-swift-6-2-a-clear-guide/)

---

### 10. 硬编码的中文字符串（中优先级）

**当前状态**: `DashboardView.swift` 中有大量硬编码中文：

- `"加载中..."`, `"首页"`, `"今日营养素摄入"`, `"健康提示"`, `"暂无数据"` 等
- `TodaySummaryCard` 中的日期格式硬编码为中文 locale (`"zh_CN"`)

**问题**: 项目已经支持 3 种语言（de, en, zh-Hans），但 View 层有硬编码中文字符串，而不是使用 `Localizable.xcstrings`。

**建议**: 所有用户可见字符串应通过 String Catalog 管理。

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

### 12. DateFormatter 重复创建（性能优化）

**当前状态** (`DashboardView.swift` `TodaySummaryCard`):

```swift
private var formattedDate: String {
    let formatter = DateFormatter()  // 每次计算都创建新实例
    formatter.dateFormat = "yyyy年M月d日 EEEE"
    formatter.locale = Locale(identifier: "zh_CN")
    return formatter.string(from: Date())
}
```

**问题**: `DateFormatter` 创建成本很高，每次 View 刷新都会重新创建。

**建议**: 使用 Swift 的 `.formatted()` API：

```swift
private var formattedDate: String {
    Date().formatted(
        .dateTime.year().month().day().weekday(.wide)
        .locale(Locale(identifier: "zh_CN"))
    )
}
```

---

## 优化优先级总结

| 优先级 | 优化项 | 影响范围 | 工作量 |
|--------|--------|----------|--------|
| **高** | SWIFT_VERSION 升级到 6.0 | 项目配置 | 小 |
| **高** | 添加 `@concurrent` 用于 CPU 密集型操作 | Services, Models | 中 |
| **高** | NetworkMonitor 改用 AsyncStream | 1 文件 | 小 |
| **中** | 移除冗余 `@MainActor` | 30+ 文件 | 中 |
| **中** | Repository 移除不必要的 `async` | 4 文件 | 中 |
| **中** | ViewModel 直接初始化替代 Optional 模式 | Views | 中 |
| **中** | 添加 `nonisolated(nonsending)` | Services | 小 |
| **中** | 硬编码中文字符串国际化 | Views | 中 |
| **低** | DateFormatter 缓存优化 | Views | 小 |
| **低** | InlineArray / Span 应用 | Models | 小 |
| **前瞻** | iOS 26 Liquid Glass 适配 | Views | 大 |

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
