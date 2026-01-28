# TDD 最佳实践指南

## 🎯 TDD核心原则

### Red-Green-Refactor循环

```
┌──────────┐
│   RED    │ 1. 编写一个失败的测试
└────┬─────┘
     │
     ▼
┌──────────┐
│  GREEN   │ 2. 编写最小代码使测试通过
└────┬─────┘
     │
     ▼
┌──────────┐
│ REFACTOR │ 3. 重构代码，保持测试通过
└────┬─────┘
     │
     └──────> 重复循环
```

---

## ✅ 好的测试实践

### 1. 使用描述性的测试名称

**❌ 不好的例子**:
```swift
@Test func test1() { ... }
@Test func testFunction() { ... }
```

**✅ 好的例子**:
```swift
@Test("Adding two positive numbers returns correct sum")
func testAddingPositiveNumbers() { ... }

@Test("Nutrient calculation with empty supplement list returns zero")
func testNutrientCalculationWithEmptyList() { ... }
```

**命名模式**: `test<被测试的内容><测试的场景><期望的结果>`

---

### 2. 遵循 Arrange-Act-Assert (AAA) 模式

```swift
@Test("RecommendationService returns correct vitamin C amount for adult male")
func testVitaminCRecommendationForMale() {
    // Arrange (准备): 设置测试数据和依赖
    let service = RecommendationService()
    let user = UserProfile(name: "Test User", userType: .male)
    
    // Act (执行): 调用被测试的方法
    let recommendation = service.getRecommendation(
        for: .vitaminC,
        user: user
    )
    
    // Assert (断言): 验证结果
    #expect(recommendation?.recommendedAmount == 110.0)
    #expect(recommendation?.nutrientType == .vitaminC)
}
```

---

### 3. 每个测试只验证一个行为

**❌ 不好的例子**:
```swift
@Test func testUserProfile() {
    let user = UserProfile(name: "Test", userType: .male)
    #expect(user.name == "Test")
    #expect(user.userType == .male)
    
    user.name = "Updated"
    #expect(user.name == "Updated")
    
    // 测试了太多不相关的行为
}
```

**✅ 好的例子**:
```swift
@Test("UserProfile initializes with correct name")
func testUserProfileName() {
    let user = UserProfile(name: "Test", userType: .male)
    #expect(user.name == "Test")
}

@Test("UserProfile initializes with correct user type")
func testUserProfileType() {
    let user = UserProfile(name: "Test", userType: .male)
    #expect(user.userType == .male)
}

@Test("UserProfile name can be updated")
func testUserProfileNameUpdate() {
    let user = UserProfile(name: "Original", userType: .male)
    user.name = "Updated"
    #expect(user.name == "Updated")
}
```

---

### 4. 测试边界条件和错误情况

```swift
@Test("Nutrient amount cannot be negative")
func testNutrientNegativeAmount() {
    #expect(throws: ValidationError.self) {
        _ = Nutrient(type: .vitaminC, amount: -10)
    }
}

@Test("Supplement calculation handles empty nutrients list")
func testSupplementWithNoNutrients() {
    let supplement = Supplement(name: "Empty", nutrients: [])
    let total = supplement.totalNutrientAmount(for: .vitaminC)
    #expect(total == 0)
}

@Test("Recommendation service handles unknown user type gracefully")
func testUnknownUserType() {
    let service = RecommendationService()
    // 测试边界情况
}
```

**要测试的边界条件**:
- 空集合 / nil值
- 最小值和最大值
- 负数和零
- 非常大的数字
- 无效输入

---

### 5. 保持测试独立

**❌ 不好的例子**:
```swift
// 测试依赖于执行顺序
var sharedUser: UserProfile?

@Test func testCreateUser() {
    sharedUser = UserProfile(name: "Test", userType: .male)
    #expect(sharedUser != nil)
}

@Test func testUpdateUser() {
    // 依赖于前一个测试！
    sharedUser?.name = "Updated"
    #expect(sharedUser?.name == "Updated")
}
```

**✅ 好的例子**:
```swift
@Test func testCreateUser() {
    let user = UserProfile(name: "Test", userType: .male)
    #expect(user.name == "Test")
}

@Test func testUpdateUser() {
    // 创建自己的测试数据
    let user = UserProfile(name: "Original", userType: .male)
    user.name = "Updated"
    #expect(user.name == "Updated")
}
```

---

### 6. 使用辅助方法提高可读性

```swift
// 测试辅助方法
extension UserProfile {
    static func makeMaleTestUser(name: String = "Test User") -> UserProfile {
        UserProfile(name: name, userType: .male)
    }
    
    static func makeFemaleTestUser(name: String = "Test User") -> UserProfile {
        UserProfile(name: name, userType: .female)
    }
}

// 在测试中使用
@Test("Male user gets correct vitamin D recommendation")
func testMaleVitaminDRecommendation() {
    let service = RecommendationService()
    let user = UserProfile.makeMaleTestUser()
    
    let rec = service.getRecommendation(for: .vitaminD, user: user)
    #expect(rec?.recommendedAmount == 20.0)
}
```

---

### 7. 测试公共API，而非实现细节

**❌ 不好的例子**:
```swift
@Test func testPrivateHelperMethod() {
    let calculator = NutritionCalculator()
    // 不应该测试私有方法
    let result = calculator._internalCalculation()
    #expect(result > 0)
}
```

**✅ 好的例子**:
```swift
@Test("Nutrition calculator returns correct total intake")
func testTotalIntakeCalculation() {
    let calculator = NutritionCalculator()
    let supplements = [
        Supplement(name: "Multi", nutrients: [
            Nutrient(type: .vitaminC, amount: 100)
        ])
    ]
    
    // 测试公共接口
    let total = calculator.calculateTotalIntake(
        for: .vitaminC,
        from: supplements
    )
    
    #expect(total == 100)
}
```

---

## ❌ 避免的反模式

### 1. 为了测试而测试

**❌ 无意义的测试**:
```swift
@Test func testGetterReturnsValue() {
    let nutrient = Nutrient(type: .vitaminC, amount: 100)
    #expect(nutrient.amount == 100) // 只是测试属性存储
}
```

**这种测试没有价值**: 它只是验证Swift的基本功能，没有测试任何业务逻辑。

---

### 2. 过度使用Mock

**❌ 不好的例子**:
```swift
// 为简单的值对象创建mock
protocol NutrientProtocol {
    var type: NutrientType { get }
    var amount: Double { get }
}

class MockNutrient: NutrientProtocol { ... }

@Test func testWithMock() {
    let mock = MockNutrient(type: .vitaminC, amount: 100)
    // 使用真实对象更简单！
}
```

**✅ 好的例子**:
```swift
// 只对复杂依赖使用mock
protocol NotificationServiceProtocol {
    func scheduleNotification(for reminder: Reminder) async throws
}

class MockNotificationService: NotificationServiceProtocol {
    var scheduledReminders: [Reminder] = []
    
    func scheduleNotification(for reminder: Reminder) async throws {
        scheduledReminders.append(reminder)
    }
}

@Test("ReminderViewModel schedules notification when created")
func testReminderScheduling() async throws {
    let mockService = MockNotificationService()
    let viewModel = ReminderViewModel(notificationService: mockService)
    
    try await viewModel.createReminder(time: Date())
    
    #expect(mockService.scheduledReminders.count == 1)
}
```

**何时使用Mock**:
- ✅ 外部服务（网络、数据库、通知）
- ✅ 异步操作
- ✅ 有副作用的操作
- ❌ 简单的值对象
- ❌ 纯计算函数

---

### 3. 测试实现而非行为

**❌ 不好的例子**:
```swift
@Test func testInternalDataStructure() {
    let calculator = NutritionCalculator()
    // 测试内部实现
    #expect(calculator._cache.isEmpty)
    #expect(calculator._internalCounter == 0)
}
```

**✅ 好的例子**:
```swift
@Test("Calculator returns same result for repeated calls with same input")
func testCalculatorConsistency() {
    let calculator = NutritionCalculator()
    let supplements = makeTestSupplements()
    
    let result1 = calculator.calculate(supplements)
    let result2 = calculator.calculate(supplements)
    
    // 测试行为：相同输入产生相同输出
    #expect(result1 == result2)
}
```

---

## 🎓 SwiftData测试最佳实践

### 使用内存存储进行测试

```swift
@Test("UserProfile persists correctly")
func testUserProfilePersistence() async throws {
    // 创建内存存储，避免影响真实数据
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try ModelContainer(
        for: UserProfile.self,
        configurations: config
    )
    let context = ModelContext(container)
    
    // 创建和保存
    let profile = UserProfile(name: "Test", userType: .male)
    context.insert(profile)
    try context.save()
    
    // 验证持久化
    let descriptor = FetchDescriptor<UserProfile>()
    let profiles = try context.fetch(descriptor)
    
    #expect(profiles.count == 1)
    #expect(profiles.first?.name == "Test")
}
```

---

## 🧪 测试组织

### 使用Suite组织相关测试

```swift
@Suite("Nutrient Model Tests")
struct NutrientTests {
    
    @Suite("Initialization Tests")
    struct InitializationTests {
        @Test("Nutrient initializes with valid amount")
        func testValidInitialization() { ... }
        
        @Test("Nutrient rejects negative amount")
        func testNegativeAmount() { ... }
    }
    
    @Suite("Calculation Tests")
    struct CalculationTests {
        @Test("Adding nutrients returns correct sum")
        func testAddition() { ... }
        
        @Test("Multiplying nutrient by dosage")
        func testMultiplication() { ... }
    }
}
```

---

## 📊 测试覆盖率指南

### 目标
- **Models & ViewModels**: > 90%
- **Services & Repositories**: > 85%
- **整体项目**: > 80%

### 不需要100%覆盖率的情况
- UI代码（SwiftUI Views）
- 简单的getter/setter
- 生成的代码
- 第三方库集成

### 重点测试的内容
- ✅ 业务逻辑
- ✅ 计算和算法
- ✅ 数据转换
- ✅ 错误处理
- ✅ 边界条件

---

## 🔧 实用工具和扩展

### 自定义断言

```swift
// 创建自定义的测试辅助函数
func expectApproximatelyEqual(
    _ value: Double,
    _ expected: Double,
    tolerance: Double = 0.001,
    sourceLocation: SourceLocation = #_sourceLocation
) {
    let difference = abs(value - expected)
    #expect(
        difference <= tolerance,
        "Expected \(value) to be approximately \(expected) (±\(tolerance))",
        sourceLocation: sourceLocation
    )
}

// 使用
@Test("Nutrient calculation with floating point")
func testFloatingPointCalculation() {
    let result = calculateNutrient(...)
    expectApproximatelyEqual(result, 99.99999, tolerance: 0.01)
}
```

### 测试数据构建器

```swift
struct SupplementBuilder {
    private var name = "Test Supplement"
    private var nutrients: [Nutrient] = []
    private var isActive = true
    
    func withName(_ name: String) -> Self {
        var builder = self
        builder.name = name
        return builder
    }
    
    func withNutrient(_ type: NutrientType, amount: Double) -> Self {
        var builder = self
        builder.nutrients.append(Nutrient(type: type, amount: amount))
        return builder
    }
    
    func inactive() -> Self {
        var builder = self
        builder.isActive = false
        return builder
    }
    
    func build() -> Supplement {
        Supplement(name: name, nutrients: nutrients, isActive: isActive)
    }
}

// 使用
@Test("Calculator ignores inactive supplements")
func testInactiveSupplements() {
    let supplement = SupplementBuilder()
        .withName("Inactive Vitamin")
        .withNutrient(.vitaminC, amount: 100)
        .inactive()
        .build()
    
    let calculator = NutritionCalculator()
    let total = calculator.calculate([supplement])
    
    #expect(total == 0)
}
```

---

## 📝 TDD工作流程清单

在开始每个新功能时，遵循这个清单：

### 开始前
- [ ] 明确要实现的功能
- [ ] 确定公共API接口
- [ ] 确定边界条件和错误情况

### Red阶段
- [ ] 编写测试，明确期望的行为
- [ ] 确保测试失败（且失败原因正确）
- [ ] 测试名称清晰描述了验证的行为

### Green阶段
- [ ] 编写最简代码使测试通过
- [ ] 不要过度设计
- [ ] 确保所有测试通过

### Refactor阶段
- [ ] 消除重复代码
- [ ] 改善命名
- [ ] 提取共用逻辑
- [ ] 保持测试通过
- [ ] 提交代码

---

## 🎯 记住

> **"测试是规格说明书，而非实现细节的镜像"**

好的测试应该：
- 📖 可读性强，像文档一样
- 🎯 专注于行为，而非实现
- 🔒 稳定，不会因重构而失败
- ⚡ 快速执行
- 🔄 可重复运行

---

**记住**: TDD不是目的，而是手段。目标是编写**可维护、可信赖的代码**。

**最后更新**: 2026-01-25
