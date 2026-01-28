# Sprint 7 任务清单 - 优化 & 完善

## 📋 Sprint 概览

**Sprint 周期**: Week 13-14
**Sprint 目标**: 提升应用质量和用户体验，准备发布
**方法论**: 质量保证 & 用户体验优化
**前置条件**: Sprint 6 已完成 ✅

---

## 🎯 用户故事 (User Stories)

### Story 1: 性能优化
**作为** 用户
**我想要** 应用运行流畅、响应迅速
**以便** 获得良好的使用体验

**验收标准**:
- [ ] 应用启动时间 < 1秒
- [ ] 页面切换无卡顿
- [ ] 列表滚动流畅（60fps）
- [ ] 内存使用合理（无泄漏）
- [ ] 电池消耗优化

### Story 2: 无障碍功能支持
**作为** 有视觉/听觉障碍的用户
**我想要** 应用支持无障碍功能
**以便** 能够正常使用应用

**验收标准**:
- [ ] VoiceOver 完全支持
- [ ] 支持动态字体大小
- [ ] 颜色对比度符合 WCAG 标准
- [ ] 支持减少动画设置
- [ ] 所有控件有适当的标签

### Story 3: 多语言支持
**作为** 不同语言背景的用户
**我想要** 使用我熟悉的语言
**以便** 更好地理解和使用应用

**验收标准**:
- [ ] 支持德语（主要）
- [ ] 支持英语
- [ ] 支持简体中文
- [ ] 营养素名称正确翻译
- [ ] 日期/数字格式本地化

### Story 4: 应用品牌完善
**作为** 用户
**我想要** 看到精美的应用图标和启动界面
**以便** 获得专业、可信赖的第一印象

**验收标准**:
- [ ] 应用图标设计完成
- [ ] 启动屏幕设计完成
- [ ] 图标适配所有尺寸
- [ ] 支持深色/浅色模式图标

### Story 5: 错误处理完善
**作为** 用户
**我想要** 在遇到错误时得到清晰的提示
**以便** 知道如何解决问题或寻求帮助

**验收标准**:
- [ ] 所有错误有友好的中文提示
- [ ] 网络错误有重试选项
- [ ] 提供错误报告机制
- [ ] 关键操作有确认提示

---

## 📝 详细任务分解

### Phase 1: 性能优化

#### Task 1.1: 启动性能优化
**优先级**: 🔴 High
**估时**: 分析 + 优化
**依赖**: 无

**实现步骤**:
1. 分析启动时间
   ```swift
   // 使用 Instruments 分析 App Launch
   // 检查 pre-main 和 post-main 时间
   ```

2. 优化措施
   - 延迟非关键初始化
   - 减少主线程阻塞操作
   - 优化 SwiftData 初始化
   - 使用 lazy loading

3. 验证优化效果
   ```swift
   // 使用 os_signpost 测量关键路径
   import os.signpost
   let log = OSLog(subsystem: "com.app", category: "performance")
   os_signpost(.begin, log: log, name: "App Launch")
   // ...
   os_signpost(.end, log: log, name: "App Launch")
   ```

**验收标准**:
- [ ] 冷启动 < 1秒
- [ ] 热启动 < 0.5秒
- [ ] 无主线程阻塞警告

---

#### Task 1.2: UI 性能优化
**优先级**: 🔴 High
**估时**: 分析 + 优化
**依赖**: 无

**实现步骤**:
1. 优化列表性能
   ```swift
   // 使用 LazyVStack 替代 VStack（大数据量）
   LazyVStack {
       ForEach(items) { item in
           ItemRow(item: item)
       }
   }

   // 为 ForEach 添加显式 id
   ForEach(supplements, id: \.persistentModelID) { ... }
   ```

2. 优化图片加载
   ```swift
   // 使用 AsyncImage 配合缓存
   AsyncImage(url: imageURL) { phase in
       switch phase {
       case .success(let image):
           image.resizable().aspectRatio(contentMode: .fit)
       case .failure:
           Image(systemName: "photo")
       case .empty:
           ProgressView()
       @unknown default:
           EmptyView()
       }
   }
   ```

3. 减少不必要的重绘
   - 使用 `@Observable` 的细粒度更新
   - 提取子视图减少重绘范围
   - 使用 `equatable` 优化

**验收标准**:
- [ ] 列表滚动 60fps
- [ ] 无掉帧警告
- [ ] 图片加载流畅

---

#### Task 1.3: 内存优化
**优先级**: 🟡 Medium
**估时**: 分析 + 优化
**依赖**: 无

**实现步骤**:
1. 使用 Instruments 分析内存
   - 检查内存泄漏
   - 检查内存峰值
   - 检查僵尸对象

2. 优化措施
   ```swift
   // 使用 weak 引用避免循环引用
   class Service {
       weak var delegate: ServiceDelegate?
   }

   // Task 取消
   @State private var loadTask: Task<Void, Never>?

   .onDisappear {
       loadTask?.cancel()
   }

   // 图片缓存策略
   URLCache.shared.memoryCapacity = 50_000_000 // 50MB
   ```

3. SwiftData 优化
   ```swift
   // 批量操作优化
   modelContext.autosaveEnabled = false
   // 批量插入...
   try modelContext.save()
   ```

**验收标准**:
- [ ] 无内存泄漏
- [ ] 内存使用合理
- [ ] 长时间使用稳定

---

#### Task 1.4: 数据库性能优化
**优先级**: 🟡 Medium
**估时**: 分析 + 优化
**依赖**: 无

**实现步骤**:
1. 优化查询
   ```swift
   // 使用 predicate 减少数据加载
   let descriptor = FetchDescriptor<IntakeRecord>(
       predicate: #Predicate { $0.date >= startDate && $0.date <= endDate },
       sortBy: [SortDescriptor(\.date, order: .reverse)]
   )
   descriptor.fetchLimit = 100

   // 只加载需要的属性
   descriptor.propertiesToFetch = [\.date, \.supplementName]
   ```

2. 索引优化
   ```swift
   // 为常用查询字段添加索引
   @Model
   final class IntakeRecord {
       @Attribute(.unique) var id: UUID
       var date: Date  // 考虑添加索引
   }
   ```

3. 后台处理
   ```swift
   // 大量数据操作放到后台
   Task.detached(priority: .background) {
       // 数据处理...
   }
   ```

**验收标准**:
- [ ] 查询响应 < 100ms
- [ ] 大数据量操作不阻塞 UI
- [ ] 数据库大小合理

---

### Phase 2: 无障碍功能

#### Task 2.1: VoiceOver 支持
**优先级**: 🔴 High
**估时**: UI 审查 + 修改
**依赖**: 无

**实现步骤**:
1. 审查所有视图的无障碍标签
   ```swift
   // 为所有交互元素添加标签
   Button(action: recordIntake) {
       Image(systemName: "plus.circle.fill")
   }
   .accessibilityLabel("记录摄入")
   .accessibilityHint("记录一次补剂摄入")

   // 为复杂组件添加描述
   NutrientProgressRing(nutrient: .vitaminC, percentage: 85)
       .accessibilityLabel("维生素C")
       .accessibilityValue("完成85%")
   ```

2. 组合无障碍元素
   ```swift
   // 将相关元素组合为一个无障碍元素
   HStack {
       Text(supplement.name)
       Spacer()
       Text("\(supplement.servingsPerDay)份/天")
   }
   .accessibilityElement(children: .combine)
   .accessibilityLabel("\(supplement.name)，每天\(supplement.servingsPerDay)份")
   ```

3. 测试 VoiceOver 体验
   - 使用 Accessibility Inspector
   - 在真机上测试 VoiceOver
   - 确保所有流程可完成

**验收标准**:
- [ ] 所有元素有适当标签
- [ ] 导航逻辑清晰
- [ ] 完整流程可用 VoiceOver 完成

---

#### Task 2.2: 动态字体支持
**优先级**: 🔴 High
**估时**: UI 审查 + 修改
**依赖**: 无

**实现步骤**:
1. 使用动态字体
   ```swift
   // 使用系统字体样式
   Text("标题")
       .font(.headline)

   // 自定义字体也支持动态大小
   Text("内容")
       .font(.custom("CustomFont", size: 17, relativeTo: .body))
   ```

2. 检查布局适配
   ```swift
   // 使用 @ScaledMetric 适配间距
   @ScaledMetric var iconSize: CGFloat = 24
   @ScaledMetric var spacing: CGFloat = 8

   // 避免固定高度
   .frame(minHeight: 44)  // 而不是 .frame(height: 44)
   ```

3. 测试极端字体大小
   - 测试最小字体（AX1）
   - 测试最大字体（AX5）
   - 确保内容不被截断

**验收标准**:
- [ ] 所有文本使用动态字体
- [ ] 极端字体大小下布局正常
- [ ] 无文本截断问题

---

#### Task 2.3: 颜色对比度优化
**优先级**: 🟡 Medium
**估时**: 设计审查 + 修改
**依赖**: 无

**实现步骤**:
1. 审查颜色对比度
   - 使用 Accessibility Inspector 检查
   - 确保文本对比度 >= 4.5:1
   - 确保大文本对比度 >= 3:1

2. 优化配色
   ```swift
   // 使用语义化颜色
   Text("重要提示")
       .foregroundStyle(.primary)

   // 确保颜色在深色模式下可见
   Color.adaptiveAccent // 自定义自适应颜色
   ```

3. 支持高对比度模式
   ```swift
   @Environment(\.accessibilityReduceTransparency) var reduceTransparency

   // 根据设置调整透明度
   .opacity(reduceTransparency ? 1.0 : 0.8)
   ```

**验收标准**:
- [ ] 所有文本对比度达标
- [ ] 深色/浅色模式都清晰
- [ ] 通过无障碍审查

---

#### Task 2.4: 减少动画支持
**优先级**: 🟡 Medium
**估时**: UI 审查 + 修改
**依赖**: 无

**实现步骤**:
1. 检测减少动画设置
   ```swift
   @Environment(\.accessibilityReduceMotion) var reduceMotion

   // 根据设置调整动画
   .animation(reduceMotion ? .none : .easeInOut, value: isExpanded)
   ```

2. 优化过渡动画
   ```swift
   // 使用简单过渡替代复杂动画
   .transition(reduceMotion ? .opacity : .scale.combined(with: .opacity))
   ```

**验收标准**:
- [ ] 尊重系统减少动画设置
- [ ] 无强制动画
- [ ] 功能不依赖动画

---

### Phase 3: 本地化

#### Task 3.1: 设置本地化基础设施
**优先级**: 🔴 High
**估时**: 配置
**依赖**: 无

**实现步骤**:
1. 配置 Xcode 项目
   - 添加支持的语言：de, en, zh-Hans
   - 创建 Localizable.xcstrings 文件

2. 创建字符串目录结构
   ```
   Resources/
   ├── Localizable.xcstrings
   ├── InfoPlist.xcstrings
   └── Localizable/
       ├── de.lproj/
       ├── en.lproj/
       └── zh-Hans.lproj/
   ```

3. 配置本地化工具
   ```swift
   // 使用 String(localized:) 新 API
   Text(String(localized: "welcome_title"))

   // 或使用 LocalizedStringKey
   Text("welcome_title")
   ```

**验收标准**:
- [ ] 项目支持3种语言
- [ ] 本地化文件结构正确
- [ ] 能切换语言测试

---

#### Task 3.2: UI 文本本地化
**优先级**: 🔴 High
**估时**: 翻译 + 集成
**依赖**: Task 3.1

**实现步骤**:
1. 提取所有 UI 文本
   ```swift
   // 替换硬编码文本
   // Before:
   Text("首页")

   // After:
   Text("tab_home", bundle: .main)
   ```

2. 创建翻译文件
   ```json
   // Localizable.xcstrings
   {
     "tab_home": {
       "localizations": {
         "de": { "stringUnit": { "value": "Startseite" }},
         "en": { "stringUnit": { "value": "Home" }},
         "zh-Hans": { "stringUnit": { "value": "首页" }}
       }
     }
   }
   ```

3. 翻译内容分类
   - 导航和标签
   - 按钮和操作
   - 提示和错误信息
   - 设置和配置

**验收标准**:
- [ ] 所有 UI 文本已本地化
- [ ] 德语翻译准确
- [ ] 英语翻译准确
- [ ] 中文翻译准确

---

#### Task 3.3: 营养素名称本地化
**优先级**: 🔴 High
**估时**: 翻译
**依赖**: Task 3.1

**实现步骤**:
1. 扩展 NutrientType 本地化
   ```swift
   extension NutrientType {
       var localizedName: String {
           String(localized: LocalizationValue(rawValue))
       }
   }

   // Localizable.xcstrings
   {
     "vitaminA": {
       "localizations": {
         "de": { "stringUnit": { "value": "Vitamin A" }},
         "en": { "stringUnit": { "value": "Vitamin A" }},
         "zh-Hans": { "stringUnit": { "value": "维生素A" }}
       }
     }
   }
   ```

2. 翻译所有23种营养素
   - 13种维生素
   - 10种矿物质

**验收标准**:
- [ ] 所有营养素名称已翻译
- [ ] 使用标准科学命名
- [ ] 德语使用 DGE 标准名称

---

#### Task 3.4: 日期和数字格式化
**优先级**: 🟡 Medium
**估时**: 实现
**依赖**: Task 3.1

**实现步骤**:
1. 使用本地化格式化器
   ```swift
   // 日期格式化
   Text(date, format: .dateTime.year().month().day())

   // 数字格式化
   Text(amount, format: .number.precision(.fractionLength(1)))

   // 测量单位
   let measurement = Measurement(value: 100, unit: UnitMass.milligrams)
   Text(measurement, format: .measurement(width: .abbreviated))
   ```

2. 处理复数形式
   ```swift
   // 使用 stringsdict 处理复数
   // %lld 份
   Text("servings_count \(count)")

   // Localizable.stringsdict
   // one: "%lld 份"
   // other: "%lld 份"
   // (德语和英语有不同的复数规则)
   ```

**验收标准**:
- [ ] 日期格式正确本地化
- [ ] 数字格式正确本地化
- [ ] 复数形式正确处理

---

### Phase 4: 应用品牌

#### Task 4.1: 设计应用图标
**优先级**: 🔴 High
**估时**: 设计
**依赖**: 无

**实现步骤**:
1. 设计图标概念
   - 体现"维生素/营养"主题
   - 简洁、现代的设计风格
   - 在小尺寸下也清晰可辨

2. 创建图标尺寸
   ```
   AppIcon.appiconset/
   ├── AppIcon-20@2x.png (40x40)
   ├── AppIcon-20@3x.png (60x60)
   ├── AppIcon-29@2x.png (58x58)
   ├── AppIcon-29@3x.png (87x87)
   ├── AppIcon-40@2x.png (80x80)
   ├── AppIcon-40@3x.png (120x120)
   ├── AppIcon-60@2x.png (120x120)
   ├── AppIcon-60@3x.png (180x180)
   └── AppIcon-1024.png (1024x1024)
   ```

3. 创建深色模式变体（可选）
   - iOS 18+ 支持深色模式图标

**验收标准**:
- [ ] 图标设计完成
- [ ] 所有尺寸导出
- [ ] 视觉效果良好

---

#### Task 4.2: 设计启动屏幕
**优先级**: 🟡 Medium
**估时**: 设计 + 实现
**依赖**: Task 4.1

**实现步骤**:
1. 创建 Launch Screen
   ```swift
   // LaunchScreen.storyboard 或 Info.plist 配置
   <key>UILaunchScreen</key>
   <dict>
       <key>UIColorName</key>
       <string>LaunchBackgroundColor</string>
       <key>UIImageName</key>
       <string>LaunchLogo</string>
   </dict>
   ```

2. 设计启动画面
   - 使用应用图标或简化版
   - 背景色与应用主题一致
   - 支持深色/浅色模式

**验收标准**:
- [ ] 启动屏幕显示正常
- [ ] 与应用风格一致
- [ ] 支持深色/浅色模式

---

### Phase 5: 错误处理完善

#### Task 5.1: 统一错误处理
**优先级**: 🔴 High
**估时**: 重构
**依赖**: 无

**实现步骤**:
1. 创建统一错误类型
   ```swift
   enum AppError: LocalizedError {
       case network(NetworkError)
       case database(DatabaseError)
       case validation(ValidationError)
       case permission(PermissionError)
       case unknown(Error)

       var errorDescription: String? {
           switch self {
           case .network(let error):
               return error.localizedDescription
           case .database(let error):
               return error.localizedDescription
           // ...
           }
       }

       var recoverySuggestion: String? { ... }
   }

   enum NetworkError: LocalizedError {
       case noConnection
       case timeout
       case serverError(Int)
       case invalidResponse

       var errorDescription: String? {
           switch self {
           case .noConnection:
               return String(localized: "error_no_connection")
           case .timeout:
               return String(localized: "error_timeout")
           // ...
           }
       }
   }
   ```

2. 创建错误处理工具
   ```swift
   struct ErrorHandler {
       static func handle(_ error: Error) -> AppError {
           if let appError = error as? AppError {
               return appError
           }
           // 转换其他错误类型...
           return .unknown(error)
       }
   }
   ```

**验收标准**:
- [ ] 所有错误有统一类型
- [ ] 错误消息已本地化
- [ ] 提供恢复建议

---

#### Task 5.2: 错误 UI 组件
**优先级**: 🔴 High
**估时**: 实现
**依赖**: Task 5.1

**实现步骤**:
1. 创建错误提示视图
   ```swift
   struct ErrorView: View {
       let error: AppError
       let retryAction: (() -> Void)?

       var body: some View {
           VStack(spacing: 16) {
               Image(systemName: "exclamationmark.triangle")
                   .font(.largeTitle)
                   .foregroundStyle(.red)

               Text(error.errorDescription ?? "发生错误")
                   .font(.headline)
                   .multilineTextAlignment(.center)

               if let suggestion = error.recoverySuggestion {
                   Text(suggestion)
                       .font(.subheadline)
                       .foregroundStyle(.secondary)
               }

               if let retry = retryAction {
                   Button("重试", action: retry)
                       .buttonStyle(.borderedProminent)
               }
           }
           .padding()
       }
   }
   ```

2. 创建错误 Toast/Banner
   ```swift
   struct ErrorBanner: View {
       let message: String
       @Binding var isPresented: Bool

       var body: some View {
           if isPresented {
               HStack {
                   Image(systemName: "xmark.circle.fill")
                       .foregroundStyle(.red)
                   Text(message)
                   Spacer()
                   Button {
                       isPresented = false
                   } label: {
                       Image(systemName: "xmark")
                   }
               }
               .padding()
               .background(.red.opacity(0.1))
               .clipShape(RoundedRectangle(cornerRadius: 8))
           }
       }
   }
   ```

**验收标准**:
- [ ] 错误视图美观清晰
- [ ] 支持重试操作
- [ ] 可关闭错误提示

---

#### Task 5.3: 网络错误处理
**优先级**: 🔴 High
**估时**: 实现
**依赖**: Task 5.1

**实现步骤**:
1. 实现网络状态监控
   ```swift
   import Network

   @Observable
   final class NetworkMonitor {
       var isConnected = true
       private let monitor = NWPathMonitor()

       init() {
           monitor.pathUpdateHandler = { [weak self] path in
               Task { @MainActor in
                   self?.isConnected = path.status == .satisfied
               }
           }
           monitor.start(queue: DispatchQueue.global())
       }
   }
   ```

2. 添加离线模式处理
   ```swift
   // 在需要网络的操作前检查
   guard networkMonitor.isConnected else {
       throw AppError.network(.noConnection)
   }

   // 显示离线提示
   if !networkMonitor.isConnected {
       OfflineBanner()
   }
   ```

**验收标准**:
- [ ] 能检测网络状态
- [ ] 离线时有清晰提示
- [ ] 网络恢复后能继续操作

---

### Phase 6: 最终测试

#### Task 6.1: 全面功能测试
**优先级**: 🔴 High
**估时**: 测试
**依赖**: 所有前置任务

**测试范围**:
1. 所有用户流程
   - 首次启动引导
   - 补剂管理全流程
   - 摄入记录全流程
   - 提醒功能全流程
   - 条形码扫描全流程
   - 用户设置全流程
   - 数据导入导出

2. 边界情况
   - 空数据状态
   - 大量数据（100+补剂，1000+记录）
   - 极端输入值
   - 网络中断/恢复

3. 设备兼容性
   - iPhone SE（小屏幕）
   - iPhone 17 Pro Max（大屏幕）
   - 不同 iOS 版本（17.0+）

**验收标准**:
- [ ] 所有流程正常工作
- [ ] 边界情况处理正确
- [ ] 各设备兼容性良好

---

#### Task 6.2: 性能测试
**优先级**: 🟡 Medium
**估时**: 测试
**依赖**: Task 1.1-1.4

**测试范围**:
1. 使用 Instruments 测试
   - Time Profiler
   - Allocations
   - Leaks
   - Energy Log
   - Network

2. 性能指标验证
   - 启动时间
   - 内存使用峰值
   - CPU 使用率
   - 帧率

**验收标准**:
- [ ] 启动时间 < 1秒
- [ ] 无内存泄漏
- [ ] CPU 使用合理
- [ ] 帧率稳定 60fps

---

#### Task 6.3: 无障碍测试
**优先级**: 🟡 Medium
**估时**: 测试
**依赖**: Task 2.1-2.4

**测试范围**:
1. VoiceOver 测试
   - 完整流程导航
   - 所有元素可访问
   - 标签准确描述

2. 动态字体测试
   - 最小字体
   - 最大字体
   - 布局适配

3. 颜色对比度测试
   - 使用 Accessibility Inspector
   - 检查所有颜色组合

**验收标准**:
- [ ] VoiceOver 完全可用
- [ ] 动态字体布局正常
- [ ] 对比度符合标准

---

#### Task 6.4: 本地化测试
**优先级**: 🟡 Medium
**估时**: 测试
**依赖**: Task 3.1-3.4

**测试范围**:
1. 各语言 UI 检查
   - 德语界面完整性
   - 英语界面完整性
   - 中文界面完整性

2. 文本长度适配
   - 德语通常比英语长 30%
   - 检查文本截断

3. 日期/数字格式
   - 各语言格式正确
   - 区域设置正确响应

**验收标准**:
- [ ] 三种语言完整可用
- [ ] 无文本截断
- [ ] 格式化正确

---

### Phase 7: 文档与发布准备

#### Task 7.1: 更新项目文档
**优先级**: 🟡 Medium
**估时**: 文档
**依赖**: 无

**文档内容**:
1. 更新 README.md
   - 项目概述
   - 功能列表
   - 技术栈
   - 截图/GIF

2. 更新 CLAUDE.md
   - 最新的架构信息
   - 新增的命令/测试

3. 创建 CHANGELOG.md
   - 版本历史
   - 功能更新记录

**验收标准**:
- [ ] README 完整更新
- [ ] CLAUDE.md 更新
- [ ] CHANGELOG 创建

---

#### Task 7.2: 代码清理
**优先级**: 🔴 High
**估时**: 清理
**依赖**: 所有功能完成

**清理内容**:
1. 删除调试代码
   ```swift
   // 删除 print/debugPrint
   // 删除 #if DEBUG 中的测试代码
   // 删除未使用的代码
   ```

2. 代码格式化
   - 统一代码风格
   - 修复 SwiftLint 警告

3. 删除未使用资源
   - 未使用的图片
   - 未使用的本地化字符串

**验收标准**:
- [ ] 无调试代码残留
- [ ] 代码风格统一
- [ ] 无未使用资源

---

#### Task 7.3: App Store 准备
**优先级**: 🔴 High
**估时**: 准备
**依赖**: 所有任务完成

**准备内容**:
1. App Store 元数据
   - 应用名称（各语言）
   - 副标题
   - 描述文本
   - 关键词
   - 隐私政策 URL

2. 截图准备
   - iPhone 6.9" (iPhone 17 Pro Max)
   - iPhone 6.3" (iPhone 17 Pro)
   - iPad Pro 12.9"（如支持）

3. 审核信息
   - 演示账号（如需要）
   - 审核说明
   - 联系方式

**验收标准**:
- [ ] 元数据准备完成
- [ ] 截图准备完成
- [ ] 隐私政策准备完成

---

## ✅ Definition of Done

每个任务完成需满足：

### 代码质量
- [ ] 无编译警告
- [ ] 无运行时错误
- [ ] 代码已清理优化
- [ ] 性能指标达标

### 用户体验
- [ ] 无障碍功能完善
- [ ] 本地化完整
- [ ] 错误处理友好
- [ ] 性能流畅

### 发布准备
- [ ] 文档完整
- [ ] App Store 元数据准备
- [ ] 通过所有测试

---

## 📊 Sprint 7 进度跟踪

### Phase 1: 性能优化
- [ ] Task 1.1: 启动性能优化
- [ ] Task 1.2: UI 性能优化
- [ ] Task 1.3: 内存优化
- [ ] Task 1.4: 数据库性能优化

### Phase 2: 无障碍功能
- [ ] Task 2.1: VoiceOver 支持
- [ ] Task 2.2: 动态字体支持
- [ ] Task 2.3: 颜色对比度优化
- [ ] Task 2.4: 减少动画支持

### Phase 3: 本地化
- [ ] Task 3.1: 设置本地化基础设施
- [ ] Task 3.2: UI 文本本地化
- [ ] Task 3.3: 营养素名称本地化
- [ ] Task 3.4: 日期和数字格式化

### Phase 4: 应用品牌
- [ ] Task 4.1: 设计应用图标
- [ ] Task 4.2: 设计启动屏幕

### Phase 5: 错误处理完善
- [ ] Task 5.1: 统一错误处理
- [ ] Task 5.2: 错误 UI 组件
- [ ] Task 5.3: 网络错误处理

### Phase 6: 最终测试
- [ ] Task 6.1: 全面功能测试
- [ ] Task 6.2: 性能测试
- [ ] Task 6.3: 无障碍测试
- [ ] Task 6.4: 本地化测试

### Phase 7: 文档与发布准备
- [ ] Task 7.1: 更新项目文档
- [ ] Task 7.2: 代码清理
- [ ] Task 7.3: App Store 准备

---

## 🎯 Sprint 7 成功标准

- [ ] 所有用户故事完成
- [ ] 所有任务的 Definition of Done 满足
- [ ] 启动时间 < 1秒
- [ ] 无内存泄漏
- [ ] VoiceOver 完全可用
- [ ] 三种语言支持完整
- [ ] 应用图标和启动屏幕完成
- [ ] 所有测试通过
- [ ] App Store 准备就绪
- [ ] 无重大 Bug

---

## 📚 参考资源

### 性能优化
- [WWDC: Analyze hangs with Instruments](https://developer.apple.com/videos/play/wwdc2023/10248/)
- [WWDC: Ultimate application performance survival guide](https://developer.apple.com/videos/play/wwdc2021/10181/)

### 无障碍
- [Apple Accessibility Guidelines](https://developer.apple.com/accessibility/)
- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)

### 本地化
- [Apple Localization Guide](https://developer.apple.com/localization/)
- [String Catalogs](https://developer.apple.com/documentation/xcode/localizing-and-varying-text-with-a-string-catalog)

### App Store
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [App Store Connect Help](https://developer.apple.com/help/app-store-connect/)

---

## 🔄 Sprint 7 之后

**发布后维护建议**:
- 监控崩溃报告（Xcode Organizer）
- 收集用户反馈
- 定期更新 DGE 数据
- 持续性能优化
- 新功能迭代（参考 Post-MVP 列表）

---

**Sprint 7 准备就绪**: ✅
**开始日期**: TBD
**预计完成日期**: TBD

---

## 📎 附录

### A. 性能基准

| 指标 | 目标值 | 测量方法 |
|------|--------|----------|
| 冷启动时间 | < 1秒 | Instruments App Launch |
| 热启动时间 | < 0.5秒 | Instruments App Launch |
| 列表滚动帧率 | 60fps | Core Animation instrument |
| 内存使用 | < 100MB | Allocations |
| 能耗 | Low | Energy Log |

### B. 无障碍检查清单

- [ ] 所有图片有 alt 文本
- [ ] 所有按钮有标签
- [ ] 所有表单字段有关联标签
- [ ] 颜色不是唯一的信息传递方式
- [ ] 焦点顺序逻辑清晰
- [ ] 错误消息清晰可理解
- [ ] 超时可延长或禁用
- [ ] 动画可停止或减少

### C. 本地化字符串示例

```json
{
  "app_name": {
    "localizations": {
      "de": { "stringUnit": { "value": "Vitamin Rechner" }},
      "en": { "stringUnit": { "value": "Vitamin Calculator" }},
      "zh-Hans": { "stringUnit": { "value": "维生素计算器" }}
    }
  },
  "tab_dashboard": {
    "localizations": {
      "de": { "stringUnit": { "value": "Übersicht" }},
      "en": { "stringUnit": { "value": "Dashboard" }},
      "zh-Hans": { "stringUnit": { "value": "首页" }}
    }
  }
}
```

### D. App Store 截图规格

| 设备 | 尺寸 | 格式 |
|------|------|------|
| iPhone 6.9" | 1320 x 2868 | PNG/JPEG |
| iPhone 6.3" | 1206 x 2622 | PNG/JPEG |
| iPad Pro 12.9" | 2048 x 2732 | PNG/JPEG |

### E. 版本发布检查清单

- [ ] 版本号已更新
- [ ] 构建号已更新
- [ ] 所有测试通过
- [ ] 无调试代码
- [ ] 无 TODO/FIXME 遗留
- [ ] 崩溃报告已配置
- [ ] 隐私政策已更新
- [ ] 截图已更新
- [ ] 发布说明已编写
- [ ] Archive 构建成功
- [ ] App Store 验证通过
