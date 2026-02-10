import Foundation
import AVFoundation

/// 条形码类型枚举
enum BarcodeType: String, CaseIterable, Sendable {
    case ean13 = "EAN-13"
    case ean8 = "EAN-8"
    case upcA = "UPC-A"
    case upcE = "UPC-E"
    case code128 = "Code 128"
    case code39 = "Code 39"
    case qrCode = "QR Code"
}

/// 相机权限状态
enum CameraPermissionStatus: Sendable {
    case authorized
    case denied
    case restricted
    case notDetermined
}

/// 条形码扫描服务
/// 提供条形码验证、类型检测和相机权限管理功能
final class BarcodeScannerService: Sendable {

    // MARK: - Initialization

    init() {}

    // MARK: - Barcode Validation

    /// 验证条形码格式是否有效
    /// - Parameter code: 条形码字符串
    /// - Returns: 如果格式有效返回 true，否则返回 false
    func isValidBarcode(_ code: String) -> Bool {
        // 空字符串无效
        guard !code.isEmpty else { return false }

        // 检查是否只包含数字
        let numericSet = CharacterSet.decimalDigits
        guard code.unicodeScalars.allSatisfy({ numericSet.contains($0) }) else {
            return false
        }

        // 检查长度是否符合标准条形码格式
        let validLengths = [8, 12, 13] // EAN-8, UPC-A, EAN-13
        return validLengths.contains(code.count)
    }

    /// 检测条形码类型
    /// - Parameter code: 条形码字符串
    /// - Returns: 条形码类型，如果无法识别则返回 nil
    func getBarcodeType(_ code: String) -> BarcodeType? {
        guard isValidBarcode(code) else { return nil }

        switch code.count {
        case 8:
            return .ean8
        case 12:
            return .upcA
        case 13:
            return .ean13
        default:
            return nil
        }
    }

    // MARK: - Supported Types

    /// 返回支持的条形码类型（AVFoundation）
    /// - Returns: AVFoundation 条形码类型数组
    func supportedBarcodeTypes() -> [AVMetadataObject.ObjectType] {
        return [
            .ean13,
            .ean8,
            .upce,
            .code128,
            .code39,
            .qr
        ]
    }

    // MARK: - Camera Permission

    /// 检查当前相机权限状态
    /// - Returns: AVFoundation 授权状态
    func checkCameraPermission() async -> AVAuthorizationStatus {
        return AVCaptureDevice.authorizationStatus(for: .video)
    }

    /// 请求相机权限
    /// - Returns: 如果用户授权返回 true，否则返回 false
    func requestCameraPermission() async -> Bool {
        return await AVCaptureDevice.requestAccess(for: .video)
    }

    /// 转换 AVAuthorizationStatus 到自定义的 CameraPermissionStatus
    /// - Parameter status: AVFoundation 授权状态
    /// - Returns: 自定义的权限状态
    func convertAuthorizationStatus(_ status: AVAuthorizationStatus) -> CameraPermissionStatus {
        switch status {
        case .authorized:
            return .authorized
        case .denied:
            return .denied
        case .restricted:
            return .restricted
        case .notDetermined:
            return .notDetermined
        @unknown default:
            return .notDetermined
        }
    }
}
