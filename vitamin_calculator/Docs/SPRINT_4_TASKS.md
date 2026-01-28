# Sprint 4 任务清单 - 智能提醒系统

## 📋 Sprint 概览

**Sprint 周期**: Week 7-8
**Sprint 目标**: 实现智能提醒系统，帮助用户按时服用补剂并追踪遵从度
**方法论**: Test-Driven Development (TDD)
**前置条件**: Sprint 3 已完成 ✅

---

## 🎯 用户故事 (User Stories)

### Story 1: 创建服用提醒
**作为** 用户
**我想要** 设置每日服用补剂的提醒时间
**以便** 不会忘记按时服用

**验收标准**:
- [ ] 能为每个补剂设置独立的提醒时间
- [ ] 支持设置多个提醒时间（早/中/晚）
- [ ] 支持选择重复模式（每日/工作日/周末/自定义）
- [ ] 提醒设置能持久化保存
- [ ] 所有测试通过（>90% 覆盖率）

### Story 2: 接收本地通知
**作为** 用户
**我想要** 在设定时间收到推送通知
**以便** 及时提醒我服用补剂

**验收标准**:
- [ ] 应用能正确请求通知权限
- [ ] 在设定时间准时发送本地通知
- [ ] 通知显示补剂名称和服用信息
- [ ] 支持通知声音和徽章
- [ ] 应用后台/关闭状态下通知仍能触发
- [ ] 所有测试通过（>85% 覆盖率）

### Story 3: 通知交互
**作为** 用户
**我想要** 直接在通知上进行操作
**以便** 快速标记服用状态

**验收标准**:
- [ ] 通知支持"已服用"快捷操作
- [ ] 通知支持"稍后提醒"操作
- [ ] 通知支持"跳过本次"操作
- [ ] 操作后自动更新摄入记录
- [ ] 所有测试通过

### Story 4: 提醒管理界面
**作为** 用户
**我想要** 在应用内管理所有提醒设置
**以便** 方便地查看和修改提醒

**验收标准**:
- [ ] 显示所有已设置的提醒列表
- [ ] 能编辑现有提醒
- [ ] 能删除提醒
- [ ] 能临时禁用/启用提醒
- [ ] UI 美观易用
- [ ] UI 测试通过

### Story 5: 服用遵从度统计
**作为** 用户
**我想要** 查看我的服用遵从度统计
**以便** 了解我的服用习惯是否良好

**验收标准**:
- [ ] 显示每日/每周服用完成率
- [ ] 显示连续服用天数（streak）
- [ ] 显示漏服次数统计
- [ ] 可视化展示遵从度趋势
- [ ] 所有测试通过

---

## 📝 详细任务分解

### Phase 1: 数据模型层 (Models)

#### Task 1.1: 创建 ReminderSchedule 模型
**优先级**: 🔴 High
**估时**: TDD 循环
**依赖**: Sprint 3 完成

**TDD 步骤**:
1. 编写 ReminderScheduleTests.swift 测试文件
   - 测试初始化
   - 测试属性访问
   - 测试 SwiftData 持久化
   - 测试与 Supplement 的关联
   - 测试重复模式逻辑
   - 测试下次提醒时间计算

2. 创建 ReminderSchedule.swift 实现
   ```swift
   @Model
   final class ReminderSchedule {
       var supplement: Supplement?
       var supplementName: String  // 快照，防止删除补剂后丢失
       var time: Date  // 提醒时间（只关心时分）
       var repeatMode: RepeatMode
       var customWeekdays: [Int]?  // 自定义重复的星期几 (1-7)
       var isEnabled: Bool
       var notificationIdentifier: String  // 用于管理本地通知
       var createdAt: Date
       var updatedAt: Date
   }

   enum RepeatMode: String, Codable, CaseIterable {
       case daily = "每日"
       case weekdays = "工作日"
       case weekends = "周末"
       case custom = "自定义"
   }
   ```

3. 重构优化

**验收标准**:
- [ ] 所有字段类型正确
- [ ] SwiftData @Model 配置正确
- [ ] 支持与 Supplement 的关联
- [ ] RepeatMode 枚举完整
- [ ] 能计算下次提醒时间
- [ ] 所有测试通过

---

#### Task 1.2: 创建 ComplianceRecord 模型
**优先级**: 🔴 High
**估时**: TDD 循环
**依赖**: Task 1.1

**TDD 步骤**:
1. 编写 ComplianceRecordTests.swift 测试文件
   - 测试记录提醒响应状态
   - 测试与 ReminderSchedule 关联
   - 测试统计计算

2. 创建 ComplianceRecord.swift 实现
   ```swift
   @Model
   final class ComplianceRecord {
       var reminderSchedule: ReminderSchedule?
       var scheduledTime: Date  // 计划提醒时间
       var responseTime: Date?  // 实际响应时间
       var status: ComplianceStatus
       var intakeRecord: IntakeRecord?  // 关联的摄入记录
       var createdAt: Date
   }

   enum ComplianceStatus: String, Codable, CaseIterable {
       case pending = "待响应"
       case taken = "已服用"
       case skipped = "已跳过"
       case snoozed = "已推迟"
       case missed = "已漏服"
   }
   ```

3. 重构优化

**验收标准**:
- [ ] 能正确记录提醒响应状态
- [ ] 支持与 ReminderSchedule 关联
- [ ] 支持与 IntakeRecord 关联
- [ ] ComplianceStatus 枚举完整
- [ ] 所有测试通过

---

#### Task 1.3: 创建 ComplianceStatistics 值类型
**优先级**: 🟡 Medium
**估时**: TDD 循环
**依赖**: Task 1.2

**TDD 步骤**:
1. 编写 ComplianceStatisticsTests.swift
   - 测试完成率计算
   - 测试连续天数计算
   - 测试周/月统计

2. 创建 ComplianceStatistics.swift 实现
   ```swift
   struct ComplianceStatistics {
       let period: StatisticsPeriod
       let totalReminders: Int
       let completedCount: Int
       let skippedCount: Int
       let missedCount: Int
       let currentStreak: Int
       let longestStreak: Int

       var completionRate: Double {
           guard totalReminders > 0 else { return 0 }
           return Double(completedCount) / Double(totalReminders) * 100
       }

       static func calculate(
           from records: [ComplianceRecord],
           period: StatisticsPeriod
       ) -> ComplianceStatistics
   }

   enum StatisticsPeriod {
       case day(Date)
       case week(Date)
       case month(Date)
       case all
   }
   ```

3. 重构优化

**验收标准**:
- [ ] 能正确计算完成率
- [ ] 能正确计算连续天数
- [ ] 能按不同周期统计
- [ ] 所有测试通过

---

### Phase 2: 数据访问层 (Repositories)

#### Task 2.1: 创建 ReminderRepository
**优先级**: 🔴 High
**估时**: TDD 循环
**依赖**: Task 1.1

**TDD 步骤**:
1. 编写 ReminderRepositoryTests.swift
   ```swift
   @Suite("ReminderRepository Tests")
   struct ReminderRepositoryTests {
       @Suite("Save Tests")
       @Suite("Fetch Tests")
       @Suite("Update Tests")
       @Suite("Delete Tests")
       @Suite("Query Tests")
   }
   ```

2. 实现 ReminderRepository.swift
   ```swift
   @MainActor
   final class ReminderRepository {
       func save(_ reminder: ReminderSchedule) async throws
       func update(_ reminder: ReminderSchedule) async throws
       func delete(_ reminder: ReminderSchedule) async throws
       func getAll() async throws -> [ReminderSchedule]
       func getEnabled() async throws -> [ReminderSchedule]
       func getBySupplement(_ supplement: Supplement) async throws -> [ReminderSchedule]
       func getByNotificationId(_ id: String) async throws -> ReminderSchedule?
   }
   ```

3. 重构优化

**验收标准**:
- [ ] 完整 CRUD 操作
- [ ] 按状态查询（启用/禁用）
- [ ] 按补剂查询
- [ ] 按通知ID查询
- [ ] 测试覆盖率 > 90%
- [ ] 所有测试通过

---

#### Task 2.2: 创建 ComplianceRepository
**优先级**: 🔴 High
**估时**: TDD 循环
**依赖**: Task 1.2

**TDD 步骤**:
1. 编写 ComplianceRepositoryTests.swift

2. 实现 ComplianceRepository.swift
   ```swift
   @MainActor
   final class ComplianceRepository {
       func save(_ record: ComplianceRecord) async throws
       func update(_ record: ComplianceRecord) async throws
       func getByDateRange(from: Date, to: Date) async throws -> [ComplianceRecord]
       func getByReminder(_ reminder: ReminderSchedule) async throws -> [ComplianceRecord]
       func getPending() async throws -> [ComplianceRecord]
       func markAsMissed(before date: Date) async throws
   }
   ```

3. 重构优化

**验收标准**:
- [ ] 完整 CRUD 操作
- [ ] 按日期范围查询
- [ ] 按提醒查询
- [ ] 查询待响应记录
- [ ] 批量标记漏服
- [ ] 测试覆盖率 > 90%
- [ ] 所有测试通过

---

### Phase 3: 业务逻辑层 (Services)

#### Task 3.1: 创建 NotificationService
**优先级**: 🔴 High
**估时**: TDD 循环
**依赖**: Task 1.1

**TDD 步骤**:
1. 编写 NotificationServiceTests.swift
   - 测试通知调度逻辑
   - 测试通知取消逻辑
   - 测试通知内容生成
   - 测试权限状态检查

2. 实现 NotificationService.swift
   ```swift
   final class NotificationService {
       // 权限管理
       func requestAuthorization() async throws -> Bool
       func getAuthorizationStatus() async -> UNAuthorizationStatus

       // 通知调度
       func scheduleReminder(_ reminder: ReminderSchedule) async throws
       func cancelReminder(_ reminder: ReminderSchedule) async
       func cancelAllReminders() async
       func rescheduleAllReminders(_ reminders: [ReminderSchedule]) async throws

       // 通知操作处理
       func handleNotificationResponse(
           _ response: UNNotificationResponse
       ) async -> NotificationAction

       // 徽章管理
       func updateBadgeCount(_ count: Int) async
   }

   enum NotificationAction {
       case taken(reminderId: String)
       case snoozed(reminderId: String, minutes: Int)
       case skipped(reminderId: String)
       case opened(reminderId: String)
   }
   ```

3. 重构优化

**验收标准**:
- [ ] 能请求通知权限
- [ ] 能调度本地通知
- [ ] 能取消通知
- [ ] 能处理通知响应
- [ ] 支持通知操作按钮
- [ ] 测试覆盖率 > 85%
- [ ] 所有测试通过

---

#### Task 3.2: 创建 ReminderService
**优先级**: 🔴 High
**估时**: TDD 循环
**依赖**: Task 3.1, Task 2.1

**TDD 步骤**:
1. 编写 ReminderServiceTests.swift
   - 测试创建提醒流程
   - 测试更新提醒流程
   - 测试删除提醒流程
   - 测试提醒响应处理

2. 实现 ReminderService.swift
   ```swift
   final class ReminderService {
       func createReminder(
           for supplement: Supplement,
           time: Date,
           repeatMode: RepeatMode,
           customWeekdays: [Int]?
       ) async throws -> ReminderSchedule

       func updateReminder(_ reminder: ReminderSchedule) async throws

       func deleteReminder(_ reminder: ReminderSchedule) async throws

       func toggleReminder(_ reminder: ReminderSchedule) async throws

       func handleReminderResponse(
           reminderId: String,
           action: NotificationAction
       ) async throws

       func processSnooze(
           reminder: ReminderSchedule,
           minutes: Int
       ) async throws

       func checkAndMarkMissedReminders() async throws
   }
   ```

3. 重构优化

**验收标准**:
- [ ] 能创建/更新/删除提醒
- [ ] 能启用/禁用提醒
- [ ] 能处理提醒响应
- [ ] 能处理推迟提醒
- [ ] 能检查并标记漏服
- [ ] 测试覆盖率 > 85%
- [ ] 所有测试通过

---

#### Task 3.3: 创建 ComplianceService
**优先级**: 🟡 Medium
**估时**: TDD 循环
**依赖**: Task 2.2, Task 1.3

**TDD 步骤**:
1. 编写 ComplianceServiceTests.swift
   - 测试统计计算
   - 测试连续天数计算
   - 测试趋势数据生成

2. 实现 ComplianceService.swift
   ```swift
   final class ComplianceService {
       func getStatistics(
           for period: StatisticsPeriod
       ) async throws -> ComplianceStatistics

       func getStatisticsBySupplement(
           _ supplement: Supplement,
           period: StatisticsPeriod
       ) async throws -> ComplianceStatistics

       func getTrendData(
           days: Int
       ) async throws -> [DailyComplianceData]

       func calculateStreak() async throws -> Int
   }

   struct DailyComplianceData {
       let date: Date
       let completionRate: Double
       let completedCount: Int
       let totalCount: Int
   }
   ```

3. 重构优化

**验收标准**:
- [ ] 能计算各周期统计
- [ ] 能按补剂统计
- [ ] 能生成趋势数据
- [ ] 能计算连续天数
- [ ] 测试覆盖率 > 85%
- [ ] 所有测试通过

---

### Phase 4: 视图模型层 (ViewModels)

#### Task 4.1: 创建 ReminderListViewModel
**优先级**: 🔴 High
**估时**: TDD 循环
**依赖**: Task 3.2

**TDD 步骤**:
1. 编写 ReminderListViewModelTests.swift
   - 测试加载提醒列表
   - 测试切换提醒状态
   - 测试删除提醒

2. 实现 ReminderListViewModel.swift
   ```swift
   @MainActor
   @Observable
   final class ReminderListViewModel {
       var reminders: [ReminderSchedule] = []
       var isLoading: Bool = false
       var errorMessage: String?
       var notificationPermissionStatus: UNAuthorizationStatus = .notDetermined

       func loadReminders() async
       func toggleReminder(_ reminder: ReminderSchedule) async
       func deleteReminder(_ reminder: ReminderSchedule) async
       func checkNotificationPermission() async
       func requestNotificationPermission() async
   }
   ```

3. 重构优化

**验收标准**:
- [ ] 使用 @Observable 宏
- [ ] 能加载提醒列表
- [ ] 能切换提醒状态
- [ ] 能检查通知权限
- [ ] 测试覆盖率 > 70%
- [ ] 所有测试通过

---

#### Task 4.2: 创建 ReminderFormViewModel
**优先级**: 🔴 High
**估时**: TDD 循环
**依赖**: Task 3.2

**TDD 步骤**:
1. 编写 ReminderFormViewModelTests.swift
   - 测试表单验证
   - 测试创建提醒
   - 测试编辑提醒

2. 实现 ReminderFormViewModel.swift
   ```swift
   @MainActor
   @Observable
   final class ReminderFormViewModel {
       var selectedSupplement: Supplement?
       var reminderTime: Date = Date()
       var repeatMode: RepeatMode = .daily
       var selectedWeekdays: Set<Int> = []
       var isEnabled: Bool = true
       var isLoading: Bool = false
       var errorMessage: String?

       var isFormValid: Bool { ... }

       func save() async throws
       func loadForEditing(_ reminder: ReminderSchedule)
   }
   ```

3. 重构优化

**验收标准**:
- [ ] 表单验证完善
- [ ] 支持添加/编辑模式
- [ ] 能保存提醒
- [ ] 测试覆盖率 > 70%
- [ ] 所有测试通过

---

#### Task 4.3: 创建 ComplianceViewModel
**优先级**: 🟡 Medium
**估时**: TDD 循环
**依赖**: Task 3.3

**TDD 步骤**:
1. 编写 ComplianceViewModelTests.swift
   - 测试加载统计数据
   - 测试切换周期

2. 实现 ComplianceViewModel.swift
   ```swift
   @MainActor
   @Observable
   final class ComplianceViewModel {
       var statistics: ComplianceStatistics?
       var trendData: [DailyComplianceData] = []
       var selectedPeriod: StatisticsPeriod = .week(Date())
       var isLoading: Bool = false
       var errorMessage: String?

       func loadStatistics() async
       func changePeriod(_ period: StatisticsPeriod) async
       func loadTrendData(days: Int) async
   }
   ```

3. 重构优化

**验收标准**:
- [ ] 能加载统计数据
- [ ] 能切换统计周期
- [ ] 能加载趋势数据
- [ ] 测试覆盖率 > 70%
- [ ] 所有测试通过

---

### Phase 5: UI 层 (Views)

#### Task 5.1: 创建 ReminderListView
**优先级**: 🔴 High
**估时**: UI 实现
**依赖**: Task 4.1

**实现步骤**:
1. 创建 ReminderListView.swift
   ```swift
   struct ReminderListView: View {
       @Environment(\.modelContext) private var modelContext
       @State private var viewModel: ReminderListViewModel?
       @State private var showingAddReminder = false

       var body: some View {
           NavigationStack {
               List {
                   permissionStatusSection
                   remindersSection
               }
               .navigationTitle("服用提醒")
               .toolbar {
                   ToolbarItem(placement: .primaryAction) {
                       Button("添加") { showingAddReminder = true }
                   }
               }
               .sheet(isPresented: $showingAddReminder) {
                   ReminderFormView(mode: .add)
               }
           }
       }
   }
   ```

2. 创建 ReminderRowView 子组件
3. 添加权限状态提示区域
4. 支持滑动删除和切换

**验收标准**:
- [ ] 列表正常显示
- [ ] 权限状态提示清晰
- [ ] 切换开关工作正常
- [ ] 添加/编辑功能正常
- [ ] UI 美观易用

---

#### Task 5.2: 创建 ReminderFormView
**优先级**: 🔴 High
**估时**: UI 实现
**依赖**: Task 4.2

**实现步骤**:
1. 创建 ReminderFormView.swift
   ```swift
   struct ReminderFormView: View {
       enum Mode { case add, edit(ReminderSchedule) }
       let mode: Mode

       @Environment(\.modelContext) private var modelContext
       @Environment(\.dismiss) private var dismiss
       @State private var viewModel: ReminderFormViewModel?

       var body: some View {
           NavigationStack {
               Form {
                   supplementSelectionSection
                   timeSelectionSection
                   repeatModeSection
                   weekdaySelectionSection  // 仅在 custom 模式显示
               }
               .navigationTitle(mode.isAdd ? "添加提醒" : "编辑提醒")
               .toolbar {
                   ToolbarItem(placement: .cancellationAction) {
                       Button("取消") { dismiss() }
                   }
                   ToolbarItem(placement: .confirmationAction) {
                       Button("保存") { ... }
                   }
               }
           }
       }
   }
   ```

2. 创建时间选择器
3. 创建重复模式选择器
4. 创建星期选择器（自定义模式）

**验收标准**:
- [ ] 补剂选择正常
- [ ] 时间选择正常
- [ ] 重复模式切换正常
- [ ] 自定义星期选择正常
- [ ] 表单验证工作
- [ ] 保存功能正常

---

#### Task 5.3: 创建 ComplianceView
**优先级**: 🟡 Medium
**估时**: UI 实现
**依赖**: Task 4.3

**实现步骤**:
1. 创建 ComplianceView.swift
   ```swift
   struct ComplianceView: View {
       @Environment(\.modelContext) private var modelContext
       @State private var viewModel: ComplianceViewModel?

       var body: some View {
           ScrollView {
               VStack(spacing: 20) {
                   periodSelector
                   statisticsCard
                   streakCard
                   trendChart
               }
               .padding()
           }
           .navigationTitle("服用统计")
       }
   }
   ```

2. 创建统计卡片组件
3. 创建连续天数展示
4. 使用 Swift Charts 创建趋势图

**验收标准**:
- [ ] 统计数据正确显示
- [ ] 周期切换工作正常
- [ ] 连续天数展示美观
- [ ] 趋势图表交互友好
- [ ] UI 美观易用

---

#### Task 5.4: 更新导航结构
**优先级**: 🔴 High
**估时**: 快速
**依赖**: Task 5.1

**实现步骤**:
1. 更新 ContentView TabView
   ```swift
   TabView {
       DashboardView()
           .tabItem { Label("首页", systemImage: "house.fill") }

       IntakeRecordView()
           .tabItem { Label("记录", systemImage: "plus.circle.fill") }

       SupplementListView()
           .tabItem { Label("补剂", systemImage: "pills.fill") }

       ReminderListView()  // 新增
           .tabItem { Label("提醒", systemImage: "bell.fill") }

       ProfileView()
           .tabItem { Label("我的", systemImage: "person.fill") }
   }
   ```

2. 在 ProfileView 或 DashboardView 添加遵从度统计入口
3. 确保导航流程顺畅

**验收标准**:
- [ ] TabView 正确显示提醒标签
- [ ] 各页面导航正常
- [ ] 遵从度统计入口清晰

---

### Phase 6: 通知集成

#### Task 6.1: 配置 UNUserNotificationCenter
**优先级**: 🔴 High
**估时**: 快速
**依赖**: Task 3.1

**实现步骤**:
1. 在 AppDelegate 或 App 入口配置通知中心
   ```swift
   @main
   struct vitamin_calculatorApp: App {
       @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

       // ...
   }

   class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
       func application(
           _ application: UIApplication,
           didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
       ) -> Bool {
           UNUserNotificationCenter.current().delegate = self
           return true
       }

       // 处理前台通知
       func userNotificationCenter(
           _ center: UNUserNotificationCenter,
           willPresent notification: UNNotification
       ) async -> UNNotificationPresentationOptions {
           return [.banner, .sound, .badge]
       }

       // 处理通知响应
       func userNotificationCenter(
           _ center: UNUserNotificationCenter,
           didReceive response: UNNotificationResponse
       ) async {
           // 处理用户响应
       }
   }
   ```

2. 注册通知类别和操作
   ```swift
   func registerNotificationCategories() {
       let takenAction = UNNotificationAction(
           identifier: "TAKEN",
           title: "已服用",
           options: .foreground
       )
       let snoozeAction = UNNotificationAction(
           identifier: "SNOOZE",
           title: "稍后提醒",
           options: []
       )
       let skipAction = UNNotificationAction(
           identifier: "SKIP",
           title: "跳过",
           options: .destructive
       )

       let category = UNNotificationCategory(
           identifier: "SUPPLEMENT_REMINDER",
           actions: [takenAction, snoozeAction, skipAction],
           intentIdentifiers: [],
           options: []
       )

       UNUserNotificationCenter.current().setNotificationCategories([category])
   }
   ```

**验收标准**:
- [ ] 通知中心正确配置
- [ ] 通知类别已注册
- [ ] 通知操作按钮正常工作
- [ ] 前台通知正常显示

---

#### Task 6.2: 更新 ModelContainer 配置
**优先级**: 🔴 High
**估时**: 快速
**依赖**: Task 1.1, Task 1.2

**实现步骤**:
1. 更新 vitamin_calculatorApp.swift
   ```swift
   let schema = Schema([
       UserProfile.self,
       Supplement.self,
       IntakeRecord.self,
       ReminderSchedule.self,  // 新增
       ComplianceRecord.self   // 新增
   ])
   ```

**验收标准**:
- [ ] ModelContainer 包含所有模型
- [ ] 应用启动正常
- [ ] 数据持久化正常

---

### Phase 7: 集成与优化

#### Task 7.1: 端到端测试
**优先级**: 🟡 Medium
**估时**: TDD 循环
**依赖**: 所有 Phase 5-6 任务

**测试步骤**:
1. 编写集成测试
   - 完整的创建提醒流程
   - 通知触发和响应流程
   - 遵从度统计流程
   - 提醒编辑和删除流程

2. 手动测试
   - 在模拟器测试所有功能
   - 测试通知权限流程
   - 测试后台通知触发
   - 测试各种边界情况

**验收标准**:
- [ ] 所有集成测试通过
- [ ] 手动测试无重大问题
- [ ] 通知功能可靠
- [ ] 用户体验流畅

---

#### Task 7.2: 性能优化
**优先级**: 🟢 Low
**估时**: 按需
**依赖**: Task 7.1

**优化项**:
1. 通知调度优化（批量处理）
2. 统计计算缓存
3. 数据库查询优化
4. 内存使用优化

**验收标准**:
- [ ] 通知调度快速
- [ ] 统计加载流畅
- [ ] 无明显内存泄漏

---

#### Task 7.3: 文档更新
**优先级**: 🟡 Medium
**估时**: 快速
**依赖**: Sprint 4 所有任务

**文档项**:
1. 更新 CLAUDE.md（如需要）
2. 添加代码注释
3. 创建 Sprint 4 完成报告

**验收标准**:
- [ ] 代码注释完整
- [ ] Sprint 4 完成报告已创建
- [ ] 架构文档已更新

---

## ✅ Definition of Done

每个任务完成需满足：

### 代码质量
- [ ] 所有测试通过
- [ ] 测试覆盖率 > 90% (Models/Repositories)
- [ ] 测试覆盖率 > 85% (Services)
- [ ] 测试覆盖率 > 70% (ViewModels)
- [ ] 代码遵循 Swift 编码规范
- [ ] 无编译警告（Actor isolation 警告除外）
- [ ] 代码已重构优化

### 功能完整性
- [ ] 所有验收标准满足
- [ ] 用户故事完整实现
- [ ] 边界情况处理妥当
- [ ] 错误处理完善
- [ ] 通知功能稳定可靠

### 文档
- [ ] 添加必要的代码注释
- [ ] 更新相关文档
- [ ] 创建完成报告

---

## 🎓 TDD 要求

### 严格遵循 Red-Green-Refactor 循环

1. **🔴 RED - 编写失败的测试**
   - 先写测试，明确需求
   - 测试应该失败（因为功能还没实现）
   - 测试命名清晰描述行为

2. **🟢 GREEN - 编写最小代码使测试通过**
   - 只写让测试通过的代码
   - 不过度设计
   - 快速迭代

3. **🔵 REFACTOR - 重构优化**
   - 改善代码结构
   - 消除重复
   - 保持测试通过

### 测试组织规范

使用 Swift Testing 框架的 @Suite 组织测试：

```swift
@Suite("ReminderSchedule Tests")
struct ReminderScheduleTests {

    @Suite("Initialization Tests")
    struct InitializationTests {
        @Test("Should initialize with valid data")
        func testValidInitialization() { }
    }

    @Suite("Next Reminder Calculation Tests")
    struct NextReminderTests {
        @Test("Should calculate next daily reminder")
        func testDailyNextReminder() { }
    }
}
```

### 通知测试注意事项

由于本地通知需要真机测试，建议：
- 使用 Protocol 抽象 UNUserNotificationCenter
- 在单元测试中使用 Mock
- 在 UI 测试中测试权限请求流程
- 手动在真机上测试通知触发

```swift
protocol NotificationCenterProtocol {
    func requestAuthorization(options: UNAuthorizationOptions) async throws -> Bool
    func add(_ request: UNNotificationRequest) async throws
    func removePendingNotificationRequests(withIdentifiers: [String])
}

extension UNUserNotificationCenter: NotificationCenterProtocol { }
```

### 测试覆盖要求

- Models: > 90%
- Repositories: > 90%
- Services: > 85%
- ViewModels: > 70%
- Views: 可选（UI 测试）

---

## 📊 Sprint 4 进度跟踪

### Phase 1: 数据模型层
- [ ] Task 1.1: ReminderSchedule 模型
- [ ] Task 1.2: ComplianceRecord 模型
- [ ] Task 1.3: ComplianceStatistics 值类型

### Phase 2: 数据访问层
- [ ] Task 2.1: ReminderRepository
- [ ] Task 2.2: ComplianceRepository

### Phase 3: 业务逻辑层
- [ ] Task 3.1: NotificationService
- [ ] Task 3.2: ReminderService
- [ ] Task 3.3: ComplianceService

### Phase 4: 视图模型层
- [ ] Task 4.1: ReminderListViewModel
- [ ] Task 4.2: ReminderFormViewModel
- [ ] Task 4.3: ComplianceViewModel

### Phase 5: UI 层
- [ ] Task 5.1: ReminderListView
- [ ] Task 5.2: ReminderFormView
- [ ] Task 5.3: ComplianceView
- [ ] Task 5.4: 更新导航结构

### Phase 6: 通知集成
- [ ] Task 6.1: 配置 UNUserNotificationCenter
- [ ] Task 6.2: 更新 ModelContainer

### Phase 7: 集成与优化
- [ ] Task 7.1: 端到端测试
- [ ] Task 7.2: 性能优化
- [ ] Task 7.3: 文档更新

---

## 🎯 Sprint 4 成功标准

- [ ] 所有用户故事完成
- [ ] 所有任务的 Definition of Done 满足
- [ ] 总测试数 > 180（累计）
- [ ] 测试通过率 = 100%
- [ ] 用户能创建和管理服用提醒
- [ ] 本地通知正常工作
- [ ] 遵从度统计功能正常
- [ ] UI 美观易用
- [ ] 无重大 Bug

---

## 📚 参考资源

### 技术栈
- Swift 6.0+
- SwiftUI
- SwiftData (iOS 17+)
- Swift Testing
- UserNotifications framework
- Swift Charts

### Apple 文档
- [UNUserNotificationCenter](https://developer.apple.com/documentation/usernotifications/unusernotificationcenter)
- [Scheduling Notifications](https://developer.apple.com/documentation/usernotifications/scheduling_a_notification_locally_from_your_app)
- [Handling Notifications](https://developer.apple.com/documentation/usernotifications/handling_notifications_and_notification-related_actions)

### 设计参考
- Apple Health App 提醒功能
- Streaks App
- Apple Human Interface Guidelines - Notifications

---

## 🔄 Sprint 4 之后

**Sprint 5 建议方向**:
- 条形码扫描（VisionKit）
- 产品数据库搜索（Open Food Facts API）
- 相机权限处理
- 产品识别和自动填充

---

**Sprint 4 准备就绪**: ✅
**开始日期**: TBD
**预计完成日期**: TBD

---

## 📎 附录

### A. 数据模型关系图

```
UserProfile
    |
    v
Supplement ──────────────────┐
    |                        |
    v                        v
IntakeRecord          ReminderSchedule
    ^                        |
    |                        v
    └──────────────── ComplianceRecord
```

### B. 通知流程图

```
用户设置提醒
    │
    v
ReminderService.createReminder()
    │
    v
NotificationService.scheduleReminder()
    │
    v
UNUserNotificationCenter.add()
    │
    v
系统在设定时间触发通知
    │
    v
用户响应通知
    │
    ├── "已服用" ──> 创建 IntakeRecord + ComplianceRecord(taken)
    │
    ├── "稍后提醒" ──> 重新调度通知 + ComplianceRecord(snoozed)
    │
    └── "跳过" ──> ComplianceRecord(skipped)
```

### C. 通知内容示例

```
┌─────────────────────────────────────┐
│ 💊 服用提醒                          │
├─────────────────────────────────────┤
│ 该服用 Vitamin D3 了                 │
│ 每日 1 粒                            │
├─────────────────────────────────────┤
│ [已服用]  [稍后提醒]  [跳过]          │
└─────────────────────────────────────┘
```

### D. Info.plist 配置

需要添加的权限描述：

```xml
<key>NSUserNotificationsUsageDescription</key>
<string>需要通知权限以提醒您按时服用补剂</string>
```
