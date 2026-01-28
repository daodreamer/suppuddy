# 维生素计算器 (Vitamin Calculator)

<p align="center">
  <img src="https://img.shields.io/badge/Platform-iOS%2017%2B-blue.svg" alt="Platform">
  <img src="https://img.shields.io/badge/Swift-6.0-orange.svg" alt="Swift Version">
  <img src="https://img.shields.io/badge/License-MIT-green.svg" alt="License">
  <img src="https://img.shields.io/badge/Test%20Coverage-85%25%2B-brightgreen.svg" alt="Test Coverage">
</p>

一个基于德国营养学会（DGE）官方推荐值的智能维生素和微量元素摄入管理应用。帮助用户追踪每日补剂摄入，计算营养素总量，并提供个性化的健康建议。

## ✨ 功能特性

### 核心功能

🎯 **个性化推荐**
- 基于德国营养学会（DGE）官方推荐值
- 支持不同用户类型：男性、女性、儿童（6个年龄段）
- 特殊需求支持：孕期、哺乳期

💊 **补剂管理**
- 手动添加补剂及其营养成分
- 条形码扫描自动识别产品（Open Food Facts API）
- 产品搜索功能
- 管理每日服用量和时间

📊 **智能计算与可视化**
- 自动计算23种营养素的每日总摄入量
- 与DGE推荐值实时对比
- 颜色编码显示状态：
  - 🟢 绿色：摄入正常
  - 🟡 黄色：摄入不足（< 80%推荐值）
  - 🔴 红色：摄入过量（> 上限值）

📝 **摄入记录**
- 记录每日补剂服用情况
- 历史记录查询
- 统计分析

🔔 **智能提醒**（即将推出）
- 自定义提醒时间
- 服用历史追踪

### 技术亮点

🚀 **性能优化**
- 启动时间 < 1秒
- 流畅的UI动画（60fps）
- 高效的数据库查询

♿ **无障碍支持**
- 完整的VoiceOver支持
- 动态字体大小适配
- 符合WCAG 2.1颜色对比度标准
- 减少动画选项

🌍 **多语言支持**
- 德语（主要语言）
- 英语
- 简体中文
- 营养素名称标准化翻译

🎨 **精美设计**
- 深色/浅色模式支持
- 遵循Apple人机界面指南
- 直观的用户体验

## 📱 系统要求

- **iOS**: 17.0 或更高版本
- **设备**: iPhone、iPad
- **语言**: 德语、英语、简体中文

## 🏗️ 技术架构

### 技术栈

- **语言**: Swift 6.0
- **UI框架**: SwiftUI
- **数据持久化**: SwiftData
- **测试框架**: Swift Testing
- **架构模式**: MVVM + Repository Pattern
- **网络**: URLSession + Open Food Facts API
- **条形码扫描**: Vision Framework

### 架构设计

```
┌─────────────────────────────────────────────────┐
│                    Views                        │
│              (SwiftUI)                         │
└────────────────┬────────────────────────────────┘
                 │
┌────────────────▼────────────────────────────────┐
│                ViewModels                       │
│              (@Observable)                      │
└────────┬────────────────────┬───────────────────┘
         │                    │
┌────────▼────────┐  ┌────────▼───────────┐
│    Services     │  │   Repositories     │
│ (Business Logic)│  │  (Data Access)     │
└────────┬────────┘  └────────┬───────────┘
         │                    │
         │           ┌────────▼───────────┐
         │           │     SwiftData      │
         │           │   (Persistence)    │
         │           └────────────────────┘
         │
┌────────▼────────┐
│      Data       │
│  (DGE Values)   │
└─────────────────┘
```

### 核心模块

```
vitamin_calculator/
├── App/                     # 应用入口
├── Models/                  # 数据模型
│   ├── User/               # 用户相关
│   ├── Nutrition/          # 营养素数据
│   ├── Supplement/         # 补剂管理
│   └── Reminder/           # 提醒功能
├── ViewModels/             # 视图模型
├── Views/                  # SwiftUI视图
│   ├── Dashboard/          # 仪表盘
│   ├── Supplement/         # 补剂管理
│   ├── Scanner/            # 条形码扫描
│   └── User/               # 用户设置
├── Services/               # 业务逻辑层
│   ├── RecommendationService.swift
│   ├── ProductLookupService.swift
│   └── NotificationService.swift
├── Repositories/           # 数据访问层
├── Data/                   # 静态数据
│   └── DGERecommendations.swift
└── Resources/              # 资源文件
    └── Localizable.xcstrings
```

## 🧪 测试

本项目采用严格的TDD（测试驱动开发）方法论。

### 测试覆盖率

- **Models & ViewModels**: > 90%
- **Services & Repositories**: > 85%
- **整体代码**: > 85%
- **测试通过率**: 99.66% (867/870)

### 运行测试

```bash
# 运行所有测试
xcodebuild -scheme vitamin_calculator \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test

# 运行特定测试套件
xcodebuild -scheme vitamin_calculator \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -only-testing:vitamin_calculatorTests/NutrientTypeTests test

# 运行特定测试方法
xcodebuild -scheme vitamin_calculator \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -only-testing:vitamin_calculatorTests/NutrientTypeTests/testHasVitaminA test
```

### 测试类型

- **单元测试**: Models, ViewModels, Services, Repositories
- **集成测试**: 完整用户流程测试
- **UI测试**: 关键用户场景端到端测试
- **性能测试**: 启动时间和UI性能测试

## 📊 营养素支持

### 维生素（13种）

- 维生素A (Vitamin A)
- 维生素D (Vitamin D)
- 维生素E (Vitamin E)
- 维生素K (Vitamin K)
- 维生素C (Vitamin C)
- 维生素B1 (Thiamin)
- 维生素B2 (Riboflavin)
- 维生素B3 (Niacin)
- 维生素B6 (Pyridoxin)
- 维生素B12 (Cobalamin)
- 叶酸 (Folate)
- 生物素 (Biotin)
- 泛酸 (Pantothenic Acid)

### 矿物质（10种）

- 钙 (Calcium)
- 镁 (Magnesium)
- 铁 (Iron)
- 锌 (Zinc)
- 硒 (Selenium)
- 碘 (Iodine)
- 铜 (Copper)
- 锰 (Manganese)
- 铬 (Chromium)
- 钼 (Molybdenum)

## 🚀 开发指南

### 前置要求

- macOS 14.0 或更高版本
- Xcode 15.0 或更高版本
- iOS 17.0+ SDK
- Swift 6.0+

### 构建项目

```bash
# 克隆项目
git clone <repository-url>
cd vitamin_calculator

# 使用Xcode打开项目
open vitamin_calculator.xcodeproj

# 或使用命令行构建
xcodebuild -scheme vitamin_calculator \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build
```

### 开发工作流

本项目遵循TDD开发流程：

1. **Red**: 编写失败的测试
2. **Green**: 编写最小代码使测试通过
3. **Refactor**: 重构代码，保持测试通过

详细的TDD指南请参考：[TDD_BEST_PRACTICES.md](vitamin_calculator/Docs/TDD_BEST_PRACTICES.md)

### 代码规范

- 遵循Swift官方代码风格
- 使用有意义的命名
- 每个类/结构体有清晰的职责
- 优先使用协议和组合
- 避免过度设计

## 📚 文档

- [项目规格文档](vitamin_calculator/Docs/PROJECT_SPECIFICATION.md) - 完整的项目需求和架构设计
- [TDD最佳实践](vitamin_calculator/Docs/TDD_BEST_PRACTICES.md) - 测试驱动开发指南
- [CLAUDE.md](CLAUDE.md) - Claude Code工作指南
- [CHANGELOG.md](CHANGELOG.md) - 版本更新日志

### Sprint完成报告

- [Sprint 5完成报告](vitamin_calculator/Docs/SPRINT_5_COMPLETION_REPORT.md)
- [Sprint 6完成报告](vitamin_calculator/Docs/SPRINT_6_PHASE_6_7_COMPLETION_REPORT.md)
- [Sprint 7 Phase 1-6完成报告](vitamin_calculator/Docs/SPRINT_7_PHASE_6_COMPLETION_REPORT.md)

## 🎯 项目状态

### 已完成功能 ✅

- ✅ 核心数据模型和架构
- ✅ DGE推荐值数据库
- ✅ 用户配置管理
- ✅ 补剂管理（CRUD）
- ✅ 营养素计算引擎
- ✅ 仪表盘和可视化
- ✅ 条形码扫描
- ✅ 产品搜索
- ✅ 摄入记录
- ✅ 数据导入导出
- ✅ 错误处理系统
- ✅ 无障碍功能
- ✅ 多语言支持（德/英/中）
- ✅ 性能优化
- ✅ 应用图标和启动屏幕
- ✅ 完整测试覆盖（870+测试）

### 计划中功能 📋

- 🔄 智能提醒系统
- 🔄 历史趋势分析
- 🔄 食物营养追踪
- 🔄 家庭成员管理
- 🔄 营养素相互作用提示
- 🔄 血液检测结果导入

### 当前版本

**Version 1.0.0** - 准备发布

## 🤝 贡献

本项目采用严格的TDD开发方法论。如果您想贡献代码：

1. Fork本项目
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. **先编写测试**（TDD原则）
4. 编写代码使测试通过
5. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
6. 推送到分支 (`git push origin feature/AmazingFeature`)
7. 开启Pull Request

请确保：
- 所有测试通过
- 代码覆盖率不降低
- 遵循项目代码规范
- 包含适当的文档

## 📄 许可证

本项目采用MIT许可证 - 详见 [LICENSE](LICENSE) 文件

## 🙏 致谢

- **德国营养学会（DGE）** - 提供官方营养推荐值数据
- **Open Food Facts** - 提供产品数据库API
- **Apple** - SwiftUI和SwiftData框架
- **Swift Testing** - 现代化的测试框架

## 📞 联系方式

- **项目维护者**: [Your Name]
- **Email**: [your-email@example.com]
- **项目主页**: [GitHub Repository URL]

## 🌟 Star History

如果这个项目对您有帮助，请给我们一个Star ⭐️

---

**使用Swift 6和SwiftUI构建 | 遵循TDD最佳实践 | 基于DGE官方数据**

*最后更新: 2026-01-28*
