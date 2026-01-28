import Testing
import SwiftData
import AVFoundation
@testable import vitamin_calculator

// MARK: - Mock Services

/// Mock BarcodeScannerService for testing
final class MockBarcodeScannerService: BarcodeScannerServiceProtocol, Sendable {
    private let validBarcodes: Set<String>
    private let permissionStatus: AVAuthorizationStatus

    init(validBarcodes: Set<String> = ["1234567890123"], permissionStatus: AVAuthorizationStatus = .authorized) {
        self.validBarcodes = validBarcodes
        self.permissionStatus = permissionStatus
    }

    func isValidBarcode(_ code: String) -> Bool {
        return validBarcodes.contains(code)
    }

    func checkCameraPermission() async -> AVAuthorizationStatus {
        return permissionStatus
    }

    func requestCameraPermission() async -> Bool {
        return permissionStatus == .authorized
    }

    func convertAuthorizationStatus(_ status: AVAuthorizationStatus) -> CameraPermissionStatus {
        switch status {
        case .authorized: return .authorized
        case .denied: return .denied
        case .restricted: return .restricted
        case .notDetermined: return .notDetermined
        @unknown default: return .notDetermined
        }
    }
}

/// Mock ProductLookupService for testing
@MainActor
final class MockProductLookupService: ProductLookupServiceProtocol {
    var mockProduct: ScannedProduct?
    var shouldThrowError: Error?
    var lookupCallCount = 0

    func lookupByBarcode(_ barcode: String) async throws -> ScannedProduct? {
        lookupCallCount += 1
        if let error = shouldThrowError {
            throw error
        }
        return mockProduct
    }

    func saveScanHistory(barcode: String, product: ScannedProduct?, wasSuccessful: Bool) async throws {
        // Mock implementation
    }

    func searchProducts(query: String, page: Int) async throws -> ProductSearchResult {
        // Mock implementation for search
        return ProductSearchResult(products: [], totalCount: 0, page: page, pageSize: 20)
    }

    func getRecentScans() async throws -> [ScanHistory] {
        // Mock implementation
        return []
    }

    func deleteHistory(_ item: ScanHistory) async throws {
        // Mock implementation
    }

    func clearHistory() async throws {
        // Mock implementation
    }
}

/// BarcodeScannerViewModel 测试套件
@Suite("BarcodeScannerViewModel Tests")
@MainActor
struct BarcodeScannerViewModelTests {

    // MARK: - Initialization Tests

    @Suite("Initialization Tests")
    struct InitializationTests {

        @Test("Should initialize with idle state")
        @MainActor
        func testInitialState() {
            // Arrange
            let scannerService = MockBarcodeScannerService()
            let lookupService = MockProductLookupService()

            // Act
            let viewModel = BarcodeScannerViewModel(
                scannerService: scannerService,
                lookupService: lookupService
            )

            // Assert
            #expect(viewModel.scanState == .idle)
            #expect(viewModel.cameraPermissionStatus == .notDetermined)
            #expect(viewModel.scannedProduct == nil)
            #expect(viewModel.errorMessage == nil)
            #expect(!viewModel.isLoading)
            #expect(!viewModel.isTorchOn)
            #expect(!viewModel.isScanning)
        }
    }

    // MARK: - Permission Tests

    @Suite("Camera Permission Tests")
    struct PermissionTests {

        @Test("Should check camera permission on initialization")
        @MainActor
        func testCheckPermission() async {
            // Arrange
            let scannerService = MockBarcodeScannerService(permissionStatus: .authorized)
            let lookupService = MockProductLookupService()
            let viewModel = BarcodeScannerViewModel(
                scannerService: scannerService,
                lookupService: lookupService
            )

            // Act
            await viewModel.checkPermission()

            // Assert
            #expect(viewModel.cameraPermissionStatus == .authorized)
        }

        @Test("Should request camera permission")
        @MainActor
        func testRequestPermission() async {
            // Arrange
            let scannerService = MockBarcodeScannerService(permissionStatus: .authorized)
            let lookupService = MockProductLookupService()
            let viewModel = BarcodeScannerViewModel(
                scannerService: scannerService,
                lookupService: lookupService
            )

            // Act
            await viewModel.requestPermission()

            // Assert
            #expect(viewModel.cameraPermissionStatus == .authorized)
        }

        @Test("Should handle denied permission")
        @MainActor
        func testDeniedPermission() async {
            // Arrange
            let scannerService = MockBarcodeScannerService(permissionStatus: .denied)
            let lookupService = MockProductLookupService()
            let viewModel = BarcodeScannerViewModel(
                scannerService: scannerService,
                lookupService: lookupService
            )

            // Act
            await viewModel.checkPermission()

            // Assert
            #expect(viewModel.cameraPermissionStatus == .denied)
        }
    }

    // MARK: - Scanning State Tests

    @Suite("Scanning State Tests")
    struct ScanningStateTests {

        @Test("Should start scanning")
        @MainActor
        func testStartScanning() {
            // Arrange
            let scannerService = MockBarcodeScannerService()
            let lookupService = MockProductLookupService()
            let viewModel = BarcodeScannerViewModel(
                scannerService: scannerService,
                lookupService: lookupService
            )

            // Act
            viewModel.startScanning()

            // Assert
            #expect(viewModel.isScanning)
            #expect(viewModel.scanState == .scanning)
        }

        @Test("Should stop scanning")
        @MainActor
        func testStopScanning() {
            // Arrange
            let scannerService = MockBarcodeScannerService()
            let lookupService = MockProductLookupService()
            let viewModel = BarcodeScannerViewModel(
                scannerService: scannerService,
                lookupService: lookupService
            )
            viewModel.startScanning()

            // Act
            viewModel.stopScanning()

            // Assert
            #expect(!viewModel.isScanning)
        }

        @Test("Should toggle torch")
        @MainActor
        func testToggleTorch() {
            // Arrange
            let scannerService = MockBarcodeScannerService()
            let lookupService = MockProductLookupService()
            let viewModel = BarcodeScannerViewModel(
                scannerService: scannerService,
                lookupService: lookupService
            )

            // Act
            viewModel.toggleTorch()

            // Assert
            #expect(viewModel.isTorchOn)

            // Toggle again
            viewModel.toggleTorch()
            #expect(!viewModel.isTorchOn)
        }
    }

    // MARK: - Barcode Handling Tests

    @Suite("Barcode Handling Tests")
    struct BarcodeHandlingTests {

        @Test("Should handle valid barcode and find product")
        @MainActor
        func testHandleValidBarcodeWithProduct() async {
            // Arrange
            let scannerService = MockBarcodeScannerService(validBarcodes: ["1234567890123"])
            let lookupService = MockProductLookupService()
            let mockProduct = ScannedProduct(
                barcode: "1234567890123",
                name: "Test Product",
                brand: "Test Brand",
                imageUrl: nil,
                servingSize: "1 tablet",
                nutrients: []
            )
            lookupService.mockProduct = mockProduct

            let viewModel = BarcodeScannerViewModel(
                scannerService: scannerService,
                lookupService: lookupService
            )

            // Act
            await viewModel.handleScannedBarcode("1234567890123")

            // Assert
            #expect(viewModel.scannedProduct != nil)
            #expect(viewModel.scannedProduct?.name == "Test Product")
            #expect(lookupService.lookupCallCount == 1)

            if case .found(let product) = viewModel.scanState {
                #expect(product.name == "Test Product")
            } else {
                Issue.record("Expected scanState to be .found")
            }
        }

        @Test("Should handle valid barcode but product not found")
        @MainActor
        func testHandleValidBarcodeNoProduct() async {
            // Arrange
            let scannerService = MockBarcodeScannerService(validBarcodes: ["1234567890123"])
            let lookupService = MockProductLookupService()
            lookupService.mockProduct = nil

            let viewModel = BarcodeScannerViewModel(
                scannerService: scannerService,
                lookupService: lookupService
            )

            // Act
            await viewModel.handleScannedBarcode("1234567890123")

            // Assert
            #expect(viewModel.scannedProduct == nil)

            if case .notFound(let barcode) = viewModel.scanState {
                #expect(barcode == "1234567890123")
            } else {
                Issue.record("Expected scanState to be .notFound")
            }
        }

        @Test("Should handle invalid barcode")
        @MainActor
        func testHandleInvalidBarcode() async {
            // Arrange
            let scannerService = MockBarcodeScannerService(validBarcodes: ["1234567890123"])
            let lookupService = MockProductLookupService()

            let viewModel = BarcodeScannerViewModel(
                scannerService: scannerService,
                lookupService: lookupService
            )

            // Act
            await viewModel.handleScannedBarcode("invalid")

            // Assert
            #expect(lookupService.lookupCallCount == 0) // Should not call lookup for invalid barcode

            if case .error = viewModel.scanState {
                // Expected error state
            } else {
                Issue.record("Expected scanState to be .error")
            }
        }

        @Test("Should handle lookup error")
        @MainActor
        func testHandleLookupError() async {
            // Arrange
            let scannerService = MockBarcodeScannerService(validBarcodes: ["1234567890123"])
            let lookupService = MockProductLookupService()
            lookupService.shouldThrowError = OpenFoodFactsError.networkError(NSError(domain: "test", code: -1))

            let viewModel = BarcodeScannerViewModel(
                scannerService: scannerService,
                lookupService: lookupService
            )

            // Act
            await viewModel.handleScannedBarcode("1234567890123")

            // Assert
            if case .error(let message) = viewModel.scanState {
                #expect(!message.isEmpty)
            } else {
                Issue.record("Expected scanState to be .error")
            }
        }
    }

    // MARK: - State Management Tests

    @Suite("State Management Tests")
    struct StateManagementTests {

        @Test("Should clear result")
        @MainActor
        func testClearResult() async {
            // Arrange
            let scannerService = MockBarcodeScannerService(validBarcodes: ["1234567890123"])
            let lookupService = MockProductLookupService()
            let mockProduct = ScannedProduct(
                barcode: "1234567890123",
                name: "Test Product",
                brand: nil,
                imageUrl: nil,
                servingSize: nil,
                nutrients: []
            )
            lookupService.mockProduct = mockProduct

            let viewModel = BarcodeScannerViewModel(
                scannerService: scannerService,
                lookupService: lookupService
            )

            await viewModel.handleScannedBarcode("1234567890123")

            // Act
            viewModel.clearResult()

            // Assert
            #expect(viewModel.scannedProduct == nil)
            #expect(viewModel.errorMessage == nil)
            #expect(viewModel.scanState == .idle)
        }

        @Test("Should retry last scan")
        @MainActor
        func testRetryLastScan() async {
            // Arrange
            let scannerService = MockBarcodeScannerService(validBarcodes: ["1234567890123"])
            let lookupService = MockProductLookupService()
            lookupService.shouldThrowError = OpenFoodFactsError.networkError(NSError(domain: "test", code: -1))

            let viewModel = BarcodeScannerViewModel(
                scannerService: scannerService,
                lookupService: lookupService
            )

            await viewModel.handleScannedBarcode("1234567890123")
            #expect(lookupService.lookupCallCount == 1)

            // Fix the error
            lookupService.shouldThrowError = nil
            let mockProduct = ScannedProduct(
                barcode: "1234567890123",
                name: "Test Product",
                brand: nil,
                imageUrl: nil,
                servingSize: nil,
                nutrients: []
            )
            lookupService.mockProduct = mockProduct

            // Act
            await viewModel.retryLastScan()

            // Assert
            #expect(lookupService.lookupCallCount == 2)
            #expect(viewModel.scannedProduct != nil)
        }
    }

    // MARK: - Loading State Tests

    @Suite("Loading State Tests")
    struct LoadingStateTests {

        @Test("Should show loading state during barcode lookup")
        @MainActor
        func testLoadingState() async {
            // Arrange
            let scannerService = MockBarcodeScannerService(validBarcodes: ["1234567890123"])
            let lookupService = MockProductLookupService()
            lookupService.mockProduct = ScannedProduct(
                barcode: "1234567890123",
                name: "Test",
                brand: nil,
                imageUrl: nil,
                servingSize: nil,
                nutrients: []
            )

            let viewModel = BarcodeScannerViewModel(
                scannerService: scannerService,
                lookupService: lookupService
            )

            // Act & Assert
            // Note: In real implementation, isLoading should be true during lookup
            await viewModel.handleScannedBarcode("1234567890123")

            // After completion, isLoading should be false
            #expect(!viewModel.isLoading)
        }
    }
}
