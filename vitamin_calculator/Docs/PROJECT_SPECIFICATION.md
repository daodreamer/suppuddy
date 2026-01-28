# 维生素计算器 (Vitamin Calculator) - 项目规格文档

## 项目概述

一个帮助用户追踪每日维生素和微量元素摄入量的iOS应用。基于德国官方营养建议值（DGE - Deutsche Gesellschaft für Ernährung），为不同人群（男性、女性、儿童）提供个性化的营养摄入管理。

### 核心价值主张
- 基于权威的德国营养学会(DGE)推荐值
- 智能计算当前补剂摄入量
- 多种便捷的产品录入方式
- 智能提醒功能，避免漏服

---

## 功能需求

### 1. 用户配置
- **用户类型选择**
  - 男性 (成年)
  - 女性 (成年)
  - 儿童 (按年龄段细分)
- **个人信息** (可选)
  - 年龄
  - 体重
  - 特殊需求 (孕期、哺乳期等)

### 2. 营养素数据库
基于德国DGE标准，包括但不限于：

#### 维生素
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
- 叶酸 (Folsäure/Folate)
- 生物素 (Biotin)
- 泛酸 (Pantothensäure)

#### 微量元素
- 钙 (Calcium)
- 镁 (Magnesium)
- 铁 (Eisen)
- 锌 (Zink)
- 硒 (Selen)
- 碘 (Jod)
- 铜 (Kupfer)
- 锰 (Mangan)
- 铬 (Chrom)
- 钼 (Molybdän)

### 3. 补剂产品管理

#### 3.1 添加产品的方式
- **手动输入**: 用户手动填写产品信息和营养成分
- **搜索功能**: 从产品数据库中搜索已有产品
- **条形码扫描**: 使用相机扫描产品条形码，自动获取产品信息

#### 3.2 产品信息
- 产品名称
- 品牌
- 条形码 (如有)
- 每份含量
- 每日建议服用次数
- 营养成分详细列表
- 产品图片 (可选)
- 备注

#### 3.3 产品管理功能
- 添加新产品
- 编辑已有产品
- 删除产品
- 标记为"当前在服用"或"已停用"

### 4. 摄入量计算
- **实时计算**: 自动计算当前所有"在服用"产品的总摄入量
- **可视化展示**: 
  - 每种营养素的当前摄入量
  - 与推荐值的对比 (百分比)
  - 颜色编码:
    - 🟢 绿色: 在推荐范围内
    - 🟡 黄色: 不足 (< 80% 推荐值)
    - 🔴 红色: 过量 (> 上限值)
- **缺失提示**: 高亮显示未覆盖或摄入不足的营养素

### 5. 提醒功能
- **智能提醒**: 根据用户设定的时间提醒服用补剂
- **灵活配置**:
  - 每日提醒时间 (可设置多个)
  - 针对特定产品的提醒
  - 周重复模式
- **提醒交互**:
  - 标记"已服用"
  - 推迟提醒
  - 跳过本次
- **服用历史记录**: 追踪用户的服用遵从度

### 6. 数据持久化
- 用户配置
- 产品列表
- 服用记录
- 提醒设置

---

## 技术架构

### 技术栈
- **平台**: iOS 17.0+
- **语言**: Swift 6.0+
- **UI框架**: SwiftUI
- **数据持久化**: SwiftData
- **通知**: UserNotifications framework
- **条形码扫描**: VisionKit / AVFoundation
- **测试**: Swift Testing framework

### 架构模式
- **MVVM (Model-View-ViewModel)**: 清晰的关注点分离
- **Repository Pattern**: 抽象数据访问层
- **Dependency Injection**: 提高可测试性

### 核心模块

```
vitamin_calculator/
├── App/
│   └── vitamin_calculatorApp.swift
├── Models/
│   ├── User/
│   │   ├── UserProfile.swift
│   │   └── UserType.swift
│   ├── Nutrition/
│   │   ├── Nutrient.swift
│   │   ├── NutrientType.swift
│   │   └── DailyRecommendation.swift
│   ├── Supplement/
│   │   ├── Supplement.swift
│   │   └── SupplementNutrient.swift
│   └── Reminder/
│       ├── ReminderSchedule.swift
│       └── IntakeRecord.swift
├── ViewModels/
│   ├── UserProfileViewModel.swift
│   ├── SupplementViewModel.swift
│   ├── NutritionCalculatorViewModel.swift
│   └── ReminderViewModel.swift
├── Views/
│   ├── ContentView.swift
│   ├── User/
│   │   └── UserProfileView.swift
│   ├── Supplement/
│   │   ├── SupplementListView.swift
│   │   ├── AddSupplementView.swift
│   │   ├── SupplementDetailView.swift
│   │   └── BarcodeScannerView.swift
│   ├── Dashboard/
│   │   ├── DashboardView.swift
│   │   └── NutrientProgressView.swift
│   └── Reminder/
│       └── ReminderSettingsView.swift
├── Services/
│   ├── DataService.swift
│   ├── NotificationService.swift
│   ├── BarcodeScannerService.swift
│   └── RecommendationService.swift
├── Repositories/
│   ├── UserRepository.swift
│   ├── SupplementRepository.swift
│   └── IntakeRepository.swift
├── Data/
│   └── DGERecommendations.swift (德国DGE推荐值数据)
├── Utilities/
│   ├── Extensions/
│   └── Constants.swift
└── Resources/
    └── Localizable.xcstrings

Tests/
├── ModelTests/
├── ViewModelTests/
├── ServiceTests/
└── RepositoryTests/

Docs/
└── PROJECT_SPECIFICATION.md (本文档)
```

---

## TDD & 敏捷开发方法论

### 测试驱动开发 (TDD) 原则

#### 核心循环: Red-Green-Refactor
1. **Red (红)**: 先编写一个失败的测试
2. **Green (绿)**: 编写最小代码使测试通过
3. **Refactor (重构)**: 优化代码，保持测试通过

#### 测试策略

##### 1. 单元测试 (Unit Tests)
- **测试对象**: Models, ViewModels, Services, Repositories
- **目标**: 
  - 验证业务逻辑正确性
  - 确保计算准确性
  - 验证数据转换
- **原则**: 
  - 每个测试只验证一个行为
  - 测试应该独立且可重复
  - 使用有意义的测试名称

##### 2. 集成测试 (Integration Tests)
- **测试对象**: 多个组件协作
- **目标**:
  - 验证 ViewModel 与 Repository 的交互
  - 验证 Service 与外部系统的集成

##### 3. UI测试 (UI Tests)
- **测试对象**: 关键用户流程
- **目标**:
  - 验证主要用户场景端到端正常工作
  - 保持最少数量，聚焦关键路径

#### 测试覆盖率目标
- Models & ViewModels: > 90%
- Services & Repositories: > 85%
- 整体代码: > 80%

#### 反模式 (要避免的)
- ❌ 为了测试而测试 (写无意义的测试)
- ❌ 测试实现细节而非行为
- ❌ 过度mock，导致测试与实际场景脱节
- ❌ 一个测试验证多个不相关的行为
- ❌ 测试间有依赖关系

#### 好的测试实践
- ✅ 测试公共API和行为
- ✅ 使用描述性的测试名称
- ✅ 遵循 Arrange-Act-Assert 模式
- ✅ 测试边界条件和错误情况
- ✅ 保持测试简单和可读
- ✅ 优先测试业务逻辑和计算准确性

### 敏捷开发流程

#### Sprint 规划
- **Sprint 周期**: 1-2周
- **每日站会**: 同步进度，识别阻碍
- **Sprint回顾**: 持续改进

#### 开发优先级

##### Sprint 1: 核心数据模型 & 基础架构 (Week 1-2)
**目标**: 建立稳固的数据基础

用户故事:
- 作为开发者，我需要定义核心数据模型，以便后续功能开发
- 作为开发者，我需要实现DGE推荐值数据，以便进行营养计算

任务:
1. 创建 `NutrientType` 枚举 (维生素、微量元素分类)
2. 创建 `Nutrient` 模型
3. 创建 `UserType` 枚举 (男性、女性、儿童)
4. 创建 `UserProfile` 模型
5. 创建 `DailyRecommendation` 模型
6. 实现 `DGERecommendations` 数据服务
7. 创建 `RecommendationService` 并编写测试
8. 配置 SwiftData 持久化

测试重点:
- ✅ 推荐值查询逻辑
- ✅ 不同用户类型返回正确的推荐值
- ✅ 边界条件处理

##### Sprint 2: 补剂产品管理 (Week 3-4)
**目标**: 实现产品添加和管理功能

用户故事:
- 作为用户，我想手动添加补剂产品，以便追踪我的营养摄入
- 作为用户，我想查看我的所有补剂产品，以便管理它们

任务:
1. 创建 `Supplement` 模型
2. 创建 `SupplementNutrient` 模型
3. 实现 `SupplementRepository`
4. 创建 `SupplementViewModel`
5. 实现 `SupplementListView`
6. 实现 `AddSupplementView` (手动输入)
7. 实现 `SupplementDetailView`

测试重点:
- ✅ CRUD操作正确性
- ✅ 数据持久化
- ✅ ViewModel状态管理
- ✅ 表单验证逻辑

##### Sprint 3: 摄入量计算与可视化 (Week 5-6)
**目标**: 实现核心计算功能和仪表盘

用户故事:
- 作为用户，我想看到我当前的营养摄入总量，以便了解我的营养状况
- 作为用户，我想知道哪些营养素不足或过量，以便调整补剂

任务:
1. 创建 `NutritionCalculatorViewModel`
2. 实现摄入量汇总算法
3. 实现与推荐值的对比逻辑
4. 创建 `DashboardView`
5. 实现 `NutrientProgressView` 组件
6. 实现颜色编码和警告系统

测试重点:
- ✅ 计算准确性（多个产品汇总）
- ✅ 百分比计算正确
- ✅ 边界值判断（不足/正常/过量）
- ✅ 空状态处理

##### Sprint 4: 提醒功能 (Week 7-8)
**目标**: 实现智能提醒系统

用户故事:
- 作为用户，我想设置提醒时间，以便不会忘记服用补剂
- 作为用户，我想记录我的服用情况，以便追踪我的遵从度

任务:
1. 创建 `ReminderSchedule` 模型
2. 创建 `IntakeRecord` 模型
3. 实现 `NotificationService`
4. 创建 `ReminderViewModel`
5. 实现 `ReminderSettingsView`
6. 实现通知权限请求
7. 实现服用记录功能

测试重点:
- ✅ 提醒调度逻辑
- ✅ 通知触发条件
- ✅ 记录保存和查询
- ✅ 权限处理

##### Sprint 5: 条形码扫描 & 产品搜索 (Week 9-10)
**目标**: 增强产品添加体验

用户故事:
- 作为用户，我想扫描产品条形码，以便快速添加产品
- 作为用户，我想搜索产品数据库，以便找到常见产品

任务:
1. 实现 `BarcodeScannerService`
2. 创建 `BarcodeScannerView`
3. 集成产品数据库API (如Open Food Facts)
4. 实现产品搜索功能
5. 处理相机权限
6. 优化用户体验流程

测试重点:
- ✅ 条形码识别逻辑
- ✅ API集成（使用mock测试）
- ✅ 错误处理（未找到产品等）
- ✅ 权限流程

##### Sprint 6: 用户配置 & 个性化 (Week 11-12)
**目标**: 完善用户体验

用户故事:
- 作为用户，我想设置我的个人信息，以便获得个性化的推荐值
- 作为用户，我想看到首次使用向导，以便快速开始使用应用

任务:
1. 实现 `UserProfileViewModel`
2. 创建 `UserProfileView`
3. 实现首次启动引导流程
4. 根据用户信息调整推荐值
5. 实现用户数据导出/导入

测试重点:
- ✅ 用户配置保存和读取
- ✅ 推荐值动态调整
- ✅ 引导流程完整性

##### Sprint 7: 优化 & 完善 (Week 13-14)
**目标**: 提升质量和用户体验

任务:
1. 性能优化
2. 无障碍功能支持
3. 本地化（德语、英语、中文）
4. 错误处理完善
5. 用户反馈收集机制
6. App图标和启动屏幕
7. 文档完善

---

## 数据模型详细设计

### 核心实体关系

```
UserProfile (1) ──┐
                  │
                  ├── UserType: 男性/女性/儿童
                  └── 查询 ──> DailyRecommendation (Many)
                  
Supplement (Many) ──┐
                    ├── SupplementNutrient (Many)
                    │   └── 引用 ──> NutrientType
                    └── ReminderSchedule (Many)
                    
IntakeRecord (Many) ──> 引用 Supplement
```

### 关键计算逻辑

#### 总摄入量计算
```
对于每种营养素:
  总摄入量 = Σ(活跃补剂中该营养素的含量 × 每日份数)
```

#### 状态判断
```
对于每种营养素:
  if 总摄入量 < 推荐值 × 0.8:
    状态 = 不足 (黄色)
  else if 总摄入量 > 最大安全摄入量:
    状态 = 过量 (红色)
  else:
    状态 = 正常 (绿色)
```

---

## 外部依赖与集成

### 条形码产品数据库
- **Open Food Facts API**: https://world.openfoodfacts.org/
  - 开源、免费
  - 支持多国产品
  - 提供营养成分数据

### 系统权限
- **相机权限**: 条形码扫描
- **通知权限**: 提醒功能
- **Info.plist 配置**:
  ```xml
  <key>NSCameraUsageDescription</key>
  <string>需要相机权限以扫描产品条形码</string>
  <key>NSUserNotificationsUsageDescription</key>
  <string>需要通知权限以提醒您服用补剂</string>
  ```

---

## 用户界面设计原则

### 设计语言
- 遵循 Apple Human Interface Guidelines
- 使用 SwiftUI 原生组件
- 支持浅色/深色模式
- 支持动态字体大小

### 主要界面
1. **仪表盘 (Dashboard)**: 营养摄入总览
2. **补剂列表**: 管理所有产品
3. **添加产品**: 多种添加方式的统一入口
4. **用户设置**: 个人信息和应用配置
5. **提醒管理**: 设置和查看提醒

### 导航结构
```
TabView
├── 仪表盘 (Dashboard)
├── 补剂 (Supplements)
├── 提醒 (Reminders)
└── 设置 (Settings)
```

---

## 本地化支持

### 支持语言
1. 德语 (主要) - de
2. 英语 - en
3. 中文 - zh-Hans

### 本地化内容
- 所有UI文本
- 营养素名称
- 错误消息
- 通知内容

---

## 性能考虑

### 优化策略
- 使用 `@Query` 进行高效的SwiftData查询
- 计算结果缓存，避免重复计算
- 图片压缩和异步加载
- 懒加载列表内容

---

## 安全与隐私

### 数据隐私
- 所有数据存储在本地设备
- 不收集用户数据
- 不需要账号系统
- 符合GDPR要求

### 数据备份
- 支持iCloud备份（可选）
- 支持手动导出/导入

---

## 成功指标

### 质量指标
- 测试覆盖率 > 80%
- 0 崩溃率
- 启动时间 < 1秒
- 页面加载时间 < 0.3秒

### 功能完整性
- 所有核心功能完成
- 支持至少2种语言
- 通过无障碍功能审查

---

## 风险与缓解

### 技术风险
1. **条形码识别准确率**
   - 缓解: 提供手动输入备选方案
   
2. **产品数据库覆盖不足**
   - 缓解: 允许用户手动添加并贡献到本地数据库

3. **推荐值数据准确性**
   - 缓解: 基于官方DGE数据，定期更新

### 范围风险
1. **功能膨胀**
   - 缓解: 严格遵循MVP原则，额外功能放入backlog

---

## 后续迭代 (Post-MVP)

### 潜在功能
- 📊 历史趋势分析
- 🍎 食物营养追踪
- 👥 家庭成员管理
- ⚠️ 营养素相互作用提示
- 🔬 血液检测结果导入
- 🏥 与医生共享报告
- 🌍 社区产品数据库共享

---

## 文档维护

本文档应该:
- ✅ 在每个Sprint开始时回顾
- ✅ 当需求变更时及时更新
- ✅ 作为团队决策的参考依据
- ✅ 在项目复盘时更新经验教训

**最后更新**: 2026-01-25  
**版本**: 1.0  
**维护者**: 开发团队
