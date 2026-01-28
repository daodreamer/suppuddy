import Foundation
import Observation
import AVFoundation

/// Scan state representing the current state of the barcode scanner
enum ScanState: Equatable {
    case idle
    case scanning
    case processing
    case found(ScannedProduct)
    case notFound(barcode: String)
    case error(String)

    static func == (lhs: ScanState, rhs: ScanState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.scanning, .scanning), (.processing, .processing):
            return true
        case (.found(let p1), .found(let p2)):
            return p1.barcode == p2.barcode
        case (.notFound(let b1), .notFound(let b2)):
            return b1 == b2
        case (.error(let e1), .error(let e2)):
            return e1 == e2
        default:
            return false
        }
    }
}

/// Protocol to abstract BarcodeScannerService for testing
protocol BarcodeScannerServiceProtocol: Sendable {
    func isValidBarcode(_ code: String) -> Bool
    func checkCameraPermission() async -> AVAuthorizationStatus
    func requestCameraPermission() async -> Bool
    func convertAuthorizationStatus(_ status: AVAuthorizationStatus) -> CameraPermissionStatus
}

/// Make BarcodeScannerService conform to protocol
extension BarcodeScannerService: BarcodeScannerServiceProtocol {}

/// Protocol to abstract ProductLookupService for testing
@MainActor
protocol ProductLookupServiceProtocol {
    func lookupByBarcode(_ barcode: String) async throws -> ScannedProduct?
    func saveScanHistory(barcode: String, product: ScannedProduct?, wasSuccessful: Bool) async throws
    func searchProducts(query: String, page: Int) async throws -> ProductSearchResult
    func getRecentScans() async throws -> [ScanHistory]
    func deleteHistory(_ item: ScanHistory) async throws
    func clearHistory() async throws
}

/// Make ProductLookupService conform to protocol
extension ProductLookupService: ProductLookupServiceProtocol {}

/// ViewModel for the barcode scanner view.
/// Manages camera permissions, scanning state, and product lookup.
@MainActor
@Observable
final class BarcodeScannerViewModel {

    // MARK: - Properties

    /// Current scan state
    var scanState: ScanState = .idle

    /// Camera permission status
    var cameraPermissionStatus: CameraPermissionStatus = .notDetermined

    /// Currently scanned product
    var scannedProduct: ScannedProduct?

    /// Error message to display
    var errorMessage: String?

    /// Whether data is being loaded
    var isLoading: Bool = false

    /// Whether torch/flashlight is on
    var isTorchOn: Bool = false

    /// Whether currently scanning
    var isScanning: Bool = false

    /// Last scanned barcode for retry functionality
    private var lastScannedBarcode: String?

    /// Scanner service for barcode validation and permissions
    private let scannerService: any BarcodeScannerServiceProtocol

    /// Lookup service for product data
    private let lookupService: any ProductLookupServiceProtocol

    // MARK: - Initialization

    /// Creates a new BarcodeScannerViewModel
    /// - Parameters:
    ///   - scannerService: Service for barcode scanning operations
    ///   - lookupService: Service for product lookup
    init(
        scannerService: any BarcodeScannerServiceProtocol,
        lookupService: any ProductLookupServiceProtocol
    ) {
        self.scannerService = scannerService
        self.lookupService = lookupService
    }

    /// Convenience initializer with concrete types
    /// - Parameters:
    ///   - scannerService: Barcode scanner service
    ///   - lookupService: Product lookup service
    init(
        scannerService: BarcodeScannerService,
        lookupService: ProductLookupService
    ) {
        self.scannerService = scannerService
        self.lookupService = lookupService
    }

    // MARK: - Permission Management

    /// Checks the current camera permission status
    func checkPermission() async {
        let status = await scannerService.checkCameraPermission()
        cameraPermissionStatus = scannerService.convertAuthorizationStatus(status)
    }

    /// Requests camera permission from the user
    func requestPermission() async {
        let granted = await scannerService.requestCameraPermission()
        if granted {
            cameraPermissionStatus = .authorized
        } else {
            let status = await scannerService.checkCameraPermission()
            cameraPermissionStatus = scannerService.convertAuthorizationStatus(status)
        }
    }

    // MARK: - Scanning Control

    /// Starts the scanning process
    func startScanning() {
        isScanning = true
        scanState = .scanning
        errorMessage = nil
    }

    /// Stops the scanning process
    func stopScanning() {
        isScanning = false
    }

    /// Toggles the torch/flashlight
    func toggleTorch() {
        isTorchOn.toggle()
    }

    // MARK: - Barcode Handling

    /// Handles a scanned barcode
    /// - Parameter barcode: The scanned barcode string
    func handleScannedBarcode(_ barcode: String) async {
        // Store for retry functionality
        lastScannedBarcode = barcode

        // Validate barcode format
        guard scannerService.isValidBarcode(barcode) else {
            scanState = .error("Invalid barcode format")
            errorMessage = "Invalid barcode format"
            return
        }

        // Set processing state
        scanState = .processing
        isLoading = true
        errorMessage = nil

        do {
            // Look up product
            let product = try await lookupService.lookupByBarcode(barcode)

            if let product = product {
                // Product found
                scannedProduct = product
                scanState = .found(product)

                // Save to history
                try await lookupService.saveScanHistory(
                    barcode: barcode,
                    product: product,
                    wasSuccessful: true
                )
            } else {
                // Product not found
                scannedProduct = nil
                scanState = .notFound(barcode: barcode)

                // Save to history as unsuccessful
                try await lookupService.saveScanHistory(
                    barcode: barcode,
                    product: nil,
                    wasSuccessful: false
                )
            }
        } catch {
            // Error during lookup
            let message = error.localizedDescription
            scanState = .error(message)
            errorMessage = message
        }

        isLoading = false
    }

    /// Retries the last scanned barcode
    func retryLastScan() async {
        guard let barcode = lastScannedBarcode else { return }
        await handleScannedBarcode(barcode)
    }

    /// Clears the current result and resets to idle state
    func clearResult() {
        scannedProduct = nil
        errorMessage = nil
        scanState = .idle
        lastScannedBarcode = nil
    }
}
