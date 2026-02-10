# 快速参考卡片 (Quick Reference)

## 🎯 当前Sprint状态

**Sprint 1**: 核心数据模型 & 基础架构  
**周期**: Week 1-2  
**状态**: 🟡 待开始

---

## 📁 文档索引

| 文档 | 用途 | 何时查看 |
|------|------|----------|
| [README.md](../README.md) | 项目概览 | 首次了解项目 |
| [PROJECT_SPECIFICATION.md](./PROJECT_SPECIFICATION.md) | 完整规格文档 | 需要详细功能说明时 |
| [SPRINT_1_TASKS.md](./SPRINT_1_TASKS.md) | 当前Sprint任务 | 每日开发时 |
| [TDD_BEST_PRACTICES.md](./TDD_BEST_PRACTICES.md) | TDD指南 | 编写测试时 |
| [QUICK_REFERENCE.md](./QUICK_REFERENCE.md) | 本文档 | 快速查找信息 |

---

## 🛠️ 技术栈速查

```swift
// 平台
iOS 17.0+

// 语言
Swift 6.0+

// 框架
SwiftUI          // UI
SwiftData        // 持久化
Swift Testing    // 测试
UserNotifications // 提醒
VisionKit        // 条形码扫描

// 架构
MVVM + Repository Pattern
```

---

## 📐 项目结构

```
vitamin_calculator/
├── Models/              # 数据模型 (SwiftData @Model)
│   ├── User/
│   ├── Nutrition/
│   ├── Supplement/
│   └── Reminder/
├── ViewModels/          # 业务逻辑 (@Observable)
├── Views/               # SwiftUI界面
├── Services/            # 业务服务
├── Repositories/        # 数据访问层
├── Data/                # 静态数据 (DGE推荐值)
└── Utilities/           # 工具类

Tests/                   # 测试 (Swift Testing)
Docs/                    # 文档
```

---

## 🧪 TDD快速提示

### Red-Green-Refactor
```
1. RED    → 编写失败的测试
2. GREEN  → 最小代码通过测试
3. REFACTOR → 重构优化
```

### 测试模板

```swift
@Test("描述性的测试名称")
func testSomething() async throws {
    // Arrange (准备)
    let input = ...
    
    // Act (执行)
    let result = ...
    
    // Assert (断言)
    #expect(result == expected)
}
```

### SwiftData测试模板

```swift
@Test("测试数据持久化")
func testPersistence() async throws {
    // 使用内存存储
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try ModelContainer(
        for: YourModel.self,
        configurations: config
    )
    let context = ModelContext(container)
    
    // 测试逻辑...
}
```

---

## 📊 核心数据模型速查

### 营养素类型
```swift
enum NutrientType {
    // 维生素
    case vitaminA, vitaminD, vitaminE, vitaminK
    case vitaminC
    case vitaminB1, vitaminB2, vitaminB3, vitaminB6, vitaminB12
    case folate, biotin, pantothenicAcid
    
    // 微量元素
    case calcium, magnesium, iron, zinc, selenium
    case iodine, copper, manganese, chromium, molybdenum
}
```

### 用户类型
```swift
enum UserType {
    case male                    // 成年男性
    case female                  // 成年女性
    case child(age: Int)         // 儿童 (带年龄)
}
```

### 关键模型关系
```
UserProfile 
  └─> UserType → DailyRecommendation

Supplement
  ├─> [SupplementNutrient]
  └─> [ReminderSchedule]

IntakeRecord → Supplement
```

---

## 🎨 命名约定

### 文件命名
- Models: `ModelName.swift` (如 `UserProfile.swift`)
- Views: `FeatureNameView.swift` (如 `DashboardView.swift`)
- ViewModels: `FeatureViewModel.swift` (如 `SupplementViewModel.swift`)
- Services: `ServiceNameService.swift` (如 `RecommendationService.swift`)
- Tests: `ModelNameTests.swift` (如 `NutrientTests.swift`)

### 变量命名
- 使用驼峰命名法
- Bool变量使用 `is/has/should` 前缀
- 集合使用复数形式

```swift
// ✅ 好的命名
let isActive: Bool
let hasReminder: Bool
let supplements: [Supplement]
let totalIntake: Double

// ❌ 避免
let active: Bool
let reminder: Bool
let supplementList: [Supplement]
let total: Double
```

---

## 🔍 常用代码片段

### 创建测试用户
```swift
let testUser = UserProfile(
    name: "Test User",
    userType: .male
)
```

### 创建测试营养素
```swift
let vitamin = Nutrient(
    type: .vitaminC,
    amount: 100.0
)
```

### SwiftUI预览
```swift
#Preview {
    YourView()
        .modelContainer(for: [UserProfile.self])
}
```

---

## ⚡ 快速命令

### 运行测试
```
⌘ + U (Command + U)
```

### 运行单个测试
```
点击测试旁边的菱形图标
```

### 查看测试覆盖率
```
Product → Test (⌘U) 
然后在Coverage标签查看
```

---

## 📈 质量指标

| 指标 | 目标 | 检查方式 |
|------|------|----------|
| 测试覆盖率 | > 80% | Xcode Coverage报告 |
| Models/ViewModels覆盖率 | > 90% | Xcode Coverage报告 |
| 编译警告 | 0 | Build时检查 |
| 崩溃率 | 0 | 测试时验证 |
| 启动时间 | < 1s | Instruments测试 |

---

## 🎯 Sprint 1关键任务

### Phase 1: 营养素模型
- [ ] NutrientType枚举
- [ ] Nutrient模型

### Phase 2: 用户模型
- [ ] UserType枚举
- [ ] UserProfile模型 (SwiftData)

### Phase 3: DGE数据
- [ ] DailyRecommendation模型
- [ ] DGERecommendations数据
- [ ] RecommendationService

### Phase 4: Repository
- [ ] UserRepository

**完成定义**: 所有测试通过 + 覆盖率>90% + 无警告

---

## 🐛 常见问题解决

### SwiftData错误
```swift
// 问题: Cannot find 'ModelContext' in scope
// 解决: 导入SwiftData
import SwiftData
```

### 测试错误
```swift
// 问题: 测试无法找到模型
// 解决: 确保测试target包含必要的源文件
```

### 通知权限
```swift
// 在Info.plist添加
<key>NSUserNotificationsUsageDescription</key>
<string>需要通知权限以提醒您服用补剂</string>
```

---

## 📚 学习资源

### Apple官方文档
- [SwiftData Documentation](https://developer.apple.com/documentation/swiftdata)
- [Swift Testing](https://developer.apple.com/documentation/testing)
- [SwiftUI Tutorials](https://developer.apple.com/tutorials/swiftui)

### DGE官方数据
- [DGE Referenzwerte](https://www.dge.de/wissenschaft/referenzwerte/)

---

## 💡 开发技巧

### 1. 先思考接口，再写代码
```swift
// 先设计使用方式
let rec = service.getRecommendation(for: .vitaminC, user: user)

// 然后实现
```

### 2. 保持函数简短
- 一个函数只做一件事
- 函数长度 < 20行为佳

### 3. 频繁提交
```
git commit -m "feat: implement NutrientType enum with tests"
git commit -m "test: add edge case for negative nutrient amount"
```

### 4. 及时重构
- 看到重复代码立即提取
- 测试通过后立即重构
- 不要等到"以后"

---

## 🎨 UI设计原则

### 颜色编码
- 🟢 **绿色**: 营养摄入正常 (80%-100%)
- 🟡 **黄色**: 营养摄入不足 (< 80%)
- 🔴 **红色**: 营养摄入过量 (> 上限)

### 导航结构
```
TabView
├── 🏠 仪表盘
├── 💊 补剂
├── ⏰ 提醒
└── ⚙️ 设置
```

---

## ✅ 每日检查清单

### 开始开发前
- [ ] 查看Sprint任务
- [ ] 确认当前要完成的Story
- [ ] 阅读相关测试案例

### 开发过程中
- [ ] 先写测试 (Red)
- [ ] 实现功能 (Green)
- [ ] 重构代码 (Refactor)
- [ ] 运行所有测试确保无回归

### 提交前
- [ ] 所有测试通过
- [ ] 无编译警告
- [ ] 代码已格式化
- [ ] 添加必要注释
- [ ] 更新文档（如需要）

---

## 🚀 下一步

完成Sprint 1后:
1. Sprint回顾会议
2. 总结经验教训
3. 规划Sprint 2: 补剂产品管理

---

**最后更新**: 2026-01-25  
**当前Sprint**: Sprint 1  
**下一个里程碑**: 完成核心数据模型
