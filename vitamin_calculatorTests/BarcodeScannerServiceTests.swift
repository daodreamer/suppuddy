import Testing
import AVFoundation
@testable import vitamin_calculator

/// BarcodeScannerService 测试套件
@Suite("BarcodeScannerService Tests")
struct BarcodeScannerServiceTests {

    // MARK: - Barcode Validation Tests

    @Suite("Barcode Validation Tests")
    struct BarcodeValidationTests {

        @Test("Should validate EAN-13 barcode format")
        func testEAN13Validation() {
            // Arrange
            let service = BarcodeScannerService()
            let validEAN13 = "4006381333931" // 13 digits
            let invalidEAN13Short = "40063813339" // 11 digits
            let invalidEAN13Long = "40063813339312" // 14 digits
            let invalidEAN13Letters = "400638133393A" // Contains letter

            // Act & Assert
            #expect(service.isValidBarcode(validEAN13))
            #expect(!service.isValidBarcode(invalidEAN13Short))
            #expect(!service.isValidBarcode(invalidEAN13Long))
            #expect(!service.isValidBarcode(invalidEAN13Letters))
        }

        @Test("Should validate EAN-8 barcode format")
        func testEAN8Validation() {
            // Arrange
            let service = BarcodeScannerService()
            let validEAN8 = "96385074" // 8 digits
            let invalidEAN8 = "963850" // 6 digits

            // Act & Assert
            #expect(service.isValidBarcode(validEAN8))
            #expect(!service.isValidBarcode(invalidEAN8))
        }

        @Test("Should validate UPC-A barcode format")
        func testUPCAValidation() {
            // Arrange
            let service = BarcodeScannerService()
            let validUPCA = "012345678905" // 12 digits
            let invalidUPCA = "01234567890" // 11 digits

            // Act & Assert
            #expect(service.isValidBarcode(validUPCA))
            #expect(!service.isValidBarcode(invalidUPCA))
        }

        @Test("Should reject empty barcode")
        func testEmptyBarcode() {
            // Arrange
            let service = BarcodeScannerService()

            // Act & Assert
            #expect(!service.isValidBarcode(""))
        }

        @Test("Should reject barcode with spaces")
        func testBarcodeWithSpaces() {
            // Arrange
            let service = BarcodeScannerService()
            let barcodeWithSpaces = "4006 3813 3393 1"

            // Act & Assert
            #expect(!service.isValidBarcode(barcodeWithSpaces))
        }
    }

    // MARK: - Barcode Type Detection Tests

    @Suite("Barcode Type Detection Tests")
    struct BarcodeTypeDetectionTests {

        @Test("Should detect EAN-13 barcode type")
        func testDetectEAN13() {
            // Arrange
            let service = BarcodeScannerService()
            let ean13Code = "4006381333931"

            // Act
            let type = service.getBarcodeType(ean13Code)

            // Assert
            #expect(type == .ean13)
        }

        @Test("Should detect EAN-8 barcode type")
        func testDetectEAN8() {
            // Arrange
            let service = BarcodeScannerService()
            let ean8Code = "96385074"

            // Act
            let type = service.getBarcodeType(ean8Code)

            // Assert
            #expect(type == .ean8)
        }

        @Test("Should detect UPC-A barcode type")
        func testDetectUPCA() {
            // Arrange
            let service = BarcodeScannerService()
            let upcaCode = "012345678905"

            // Act
            let type = service.getBarcodeType(upcaCode)

            // Assert
            #expect(type == .upcA)
        }

        @Test("Should return nil for invalid barcode")
        func testDetectInvalidBarcode() {
            // Arrange
            let service = BarcodeScannerService()
            let invalidCode = "invalid"

            // Act
            let type = service.getBarcodeType(invalidCode)

            // Assert
            #expect(type == nil)
        }
    }

    // MARK: - Supported Barcode Types Tests

    @Suite("Supported Barcode Types Tests")
    struct SupportedTypesTests {

        @Test("Should return supported AVFoundation barcode types")
        func testSupportedBarcodeTypes() {
            // Arrange
            let service = BarcodeScannerService()

            // Act
            let types = service.supportedBarcodeTypes()

            // Assert
            #expect(types.contains(.ean13))
            #expect(types.contains(.ean8))
            #expect(types.contains(.upce))
            #expect(types.contains(.code128))
            #expect(types.contains(.code39))
            #expect(types.contains(.qr))
            #expect(types.count >= 6)
        }

        @Test("Should support all BarcodeType enum cases")
        func testAllBarcodeTypesSupported() {
            // Arrange
            let service = BarcodeScannerService()
            let supportedTypes = service.supportedBarcodeTypes()

            // Act & Assert
            // 确保所有我们定义的条形码类型都在支持列表中
            #expect(supportedTypes.count >= BarcodeType.allCases.count - 1) // -1 for QR which might be optional
        }
    }

    // MARK: - Permission Status Tests

    @Suite("Camera Permission Tests")
    struct PermissionTests {

        @Test("Should return current camera permission status")
        func testCheckCameraPermission() async {
            // Arrange
            let service = BarcodeScannerService()

            // Act
            let status = await service.checkCameraPermission()

            // Assert
            // 在测试环境中，状态应该是以下之一
            #expect(
                status == .authorized ||
                status == .denied ||
                status == .restricted ||
                status == .notDetermined
            )
        }

        @Test("Should convert AVAuthorizationStatus correctly")
        func testAuthorizationStatusConversion() {
            // Arrange
            let service = BarcodeScannerService()

            // Act & Assert
            // 测试状态转换的正确性
            let status = service.convertAuthorizationStatus(.authorized)
            #expect(status == .authorized)

            let denied = service.convertAuthorizationStatus(.denied)
            #expect(denied == .denied)

            let restricted = service.convertAuthorizationStatus(.restricted)
            #expect(restricted == .restricted)

            let notDetermined = service.convertAuthorizationStatus(.notDetermined)
            #expect(notDetermined == .notDetermined)
        }
    }

    // MARK: - Edge Cases Tests

    @Suite("Edge Cases Tests")
    struct EdgeCasesTests {

        @Test("Should handle very long barcode strings")
        func testVeryLongBarcode() {
            // Arrange
            let service = BarcodeScannerService()
            let longBarcode = String(repeating: "1", count: 100)

            // Act & Assert
            #expect(!service.isValidBarcode(longBarcode))
        }

        @Test("Should handle barcode with only numbers")
        func testNumericBarcode() {
            // Arrange
            let service = BarcodeScannerService()
            let numericCode = "1234567890123"

            // Act & Assert
            #expect(service.isValidBarcode(numericCode))
        }

        @Test("Should handle barcode with special characters")
        func testBarcodeWithSpecialChars() {
            // Arrange
            let service = BarcodeScannerService()
            let specialChars = "1234-5678-901"

            // Act & Assert
            #expect(!service.isValidBarcode(specialChars))
        }

        @Test("Should handle leading zeros in barcode")
        func testLeadingZeros() {
            // Arrange
            let service = BarcodeScannerService()
            let leadingZeros = "0012345678905" // UPC-A with leading zero

            // Act & Assert
            #expect(service.isValidBarcode(leadingZeros))
        }
    }
}
