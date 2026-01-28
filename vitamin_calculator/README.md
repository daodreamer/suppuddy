# Vitamin Calculator (维生素计算器)

一个基于德国DGE官方推荐值的维生素和微量元素摄入追踪应用。

## 🎯 核心功能

- ✅ 基于德国营养学会(DGE)标准的个性化推荐值
- 📱 智能补剂产品管理（手动输入/搜索/扫码）
- 🧮 自动计算每日营养摄入量
- 📊 可视化营养状态（不足/正常/过量）
- ⏰ 智能提醒，避免漏服

## 🛠️ 技术栈

- **平台**: iOS 17.0+
- **语言**: Swift 6.0+
- **UI**: SwiftUI
- **数据**: SwiftData
- **测试**: Swift Testing
- **架构**: MVVM + Repository Pattern

## 📁 项目结构

```
vitamin_calculator/
├── Models/          # 数据模型
├── ViewModels/      # 视图模型
├── Views/           # SwiftUI视图
├── Services/        # 业务服务
├── Repositories/    # 数据访问层
├── Data/            # DGE推荐值数据
└── Utilities/       # 工具类

Tests/               # 单元测试和集成测试
Docs/                # 项目文档
```

## 📖 文档

- [完整项目规格文档](./Docs/PROJECT_SPECIFICATION.md)

## 🚀 开发流程

本项目严格遵循 **TDD (测试驱动开发)** 和 **敏捷开发** 方法论：

### TDD循环
1. **Red**: 先写失败的测试
2. **Green**: 编写最小代码使测试通过
3. **Refactor**: 重构优化

### Sprint计划
- Sprint 1: 核心数据模型 (Week 1-2)
- Sprint 2: 补剂产品管理 (Week 3-4)
- Sprint 3: 摄入量计算与可视化 (Week 5-6)
- Sprint 4: 提醒功能 (Week 7-8)
- Sprint 5: 条形码扫描 & 搜索 (Week 9-10)
- Sprint 6: 用户配置 (Week 11-12)
- Sprint 7: 优化完善 (Week 13-14)

## 🧪 测试策略

- **单元测试**: Models, ViewModels, Services (覆盖率 > 90%)
- **集成测试**: 组件协作 (覆盖率 > 85%)
- **UI测试**: 关键用户流程

### 测试原则
- ✅ 测试行为，而非实现
- ✅ 保持测试独立且可重复
- ✅ 聚焦业务逻辑和计算准确性
- ❌ 避免为测试而测试

## 🌍 本地化

- 🇩🇪 德语 (主要)
- 🇬🇧 英语
- 🇨🇳 中文

## 🔒 隐私

- 所有数据本地存储
- 无需账号系统
- 不收集用户数据
- 符合GDPR

## 📊 成功指标

- 测试覆盖率 > 80%
- 启动时间 < 1秒
- 0 崩溃率

## 🤝 贡献指南

1. 查看当前Sprint任务
2. 先写测试（TDD）
3. 实现功能
4. 确保所有测试通过
5. 代码审查

---

**开始日期**: 2026-01-25  
**当前Sprint**: Sprint 1 - 核心数据模型
