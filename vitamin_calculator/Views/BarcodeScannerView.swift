//
//  BarcodeScannerView.swift
//  vitamin_calculator
//
//  Created by Claude Code on 26.01.26.
//

import SwiftUI
import SwiftData
import AVFoundation

/// Main view for barcode scanning functionality
struct BarcodeScannerView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: BarcodeScannerViewModel

    let onProductScanned: (ScannedProduct) -> Void

    init(
        scannerService: BarcodeScannerService,
        lookupService: ProductLookupService,
        onProductScanned: @escaping (ScannedProduct) -> Void
    ) {
        self.onProductScanned = onProductScanned
        _viewModel = State(initialValue: BarcodeScannerViewModel(
            scannerService: scannerService,
            lookupService: lookupService
        ))
    }

    var body: some View {
        ZStack {
            // Camera preview layer
            if viewModel.cameraPermissionStatus == .authorized {
                CameraPreviewView(
                    isScanning: $viewModel.isScanning,
                    isTorchOn: $viewModel.isTorchOn,
                    onBarcodeScanned: { barcode in
                        Task {
                            await viewModel.handleScannedBarcode(barcode)
                        }
                    }
                )
                .ignoresSafeArea()
            }

            // Permission request view
            if viewModel.cameraPermissionStatus != .authorized {
                CameraPermissionView(
                    permissionStatus: viewModel.cameraPermissionStatus,
                    onRequestPermission: {
                        Task {
                            await viewModel.requestPermission()
                        }
                    }
                )
            } else {
                // Scanning overlay
                ScannerOverlayView()

                // Control buttons
                VStack {
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.title2)
                                .foregroundStyle(.white)
                                .padding()
                                .background(Color.black.opacity(0.5))
                                .clipShape(Circle())
                        }

                        Spacer()

                        Button {
                            viewModel.toggleTorch()
                        } label: {
                            Image(systemName: viewModel.isTorchOn ? "flashlight.on.fill" : "flashlight.off.fill")
                                .font(.title2)
                                .foregroundStyle(.white)
                                .padding()
                                .background(Color.black.opacity(0.5))
                                .clipShape(Circle())
                        }
                    }
                    .padding()

                    Spacer()

                    // Instruction text
                    if viewModel.scanState == .scanning {
                        Text("Align barcode within frame")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .padding()
                            .background(Color.black.opacity(0.7))
                            .cornerRadius(10)
                    }

                    Spacer()
                }

                // Result display
                if case .found(let product) = viewModel.scanState {
                    ScannedProductCard(
                        product: product,
                        onConfirm: {
                            onProductScanned(product)
                            dismiss()
                        },
                        onRescan: {
                            viewModel.clearResult()
                            viewModel.startScanning()
                        }
                    )
                }

                // Not found display
                if case .notFound(let barcode) = viewModel.scanState {
                    ProductNotFoundCard(
                        barcode: barcode,
                        onRetry: {
                            Task {
                                await viewModel.retryLastScan()
                            }
                        },
                        onCancel: {
                            viewModel.clearResult()
                            viewModel.startScanning()
                        }
                    )
                }

                // Error display
                if case .error(let message) = viewModel.scanState {
                    ErrorCard(
                        message: message,
                        onRetry: {
                            Task {
                                await viewModel.retryLastScan()
                            }
                        },
                        onCancel: {
                            viewModel.clearResult()
                            viewModel.startScanning()
                        }
                    )
                }

                // Loading overlay
                if viewModel.isLoading {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()

                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                }
            }
        }
        .task {
            await viewModel.checkPermission()
            if viewModel.cameraPermissionStatus == .authorized {
                viewModel.startScanning()
            }
        }
    }
}

// MARK: - Camera Preview (UIViewRepresentable)

struct CameraPreviewView: UIViewRepresentable {
    @Binding var isScanning: Bool
    @Binding var isTorchOn: Bool
    let onBarcodeScanned: (String) -> Void

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .black

        let captureSession = AVCaptureSession()
        context.coordinator.captureSession = captureSession

        // Setup camera input
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return view }
        guard let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice) else { return view }

        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        }

        // Setup metadata output for barcode scanning
        let metadataOutput = AVCaptureMetadataOutput()

        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(context.coordinator, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.ean13, .ean8, .upce, .code128, .code39, .qr]
        }

        // Setup preview layer
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        context.coordinator.previewLayer = previewLayer
        context.coordinator.videoCaptureDevice = videoCaptureDevice

        // Start session
        DispatchQueue.global(qos: .userInitiated).async {
            captureSession.startRunning()
        }

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // Update preview layer frame
        if let previewLayer = context.coordinator.previewLayer {
            previewLayer.frame = uiView.bounds
        }

        // Handle scanning state
        if isScanning {
            if !(context.coordinator.captureSession?.isRunning ?? false) {
                DispatchQueue.global(qos: .userInitiated).async {
                    context.coordinator.captureSession?.startRunning()
                }
            }
        } else {
            if context.coordinator.captureSession?.isRunning ?? false {
                DispatchQueue.global(qos: .userInitiated).async {
                    context.coordinator.captureSession?.stopRunning()
                }
            }
        }

        // Handle torch
        context.coordinator.updateTorch(isOn: isTorchOn)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onBarcodeScanned: onBarcodeScanned)
    }

    class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        let onBarcodeScanned: (String) -> Void
        var captureSession: AVCaptureSession?
        var previewLayer: AVCaptureVideoPreviewLayer?
        var videoCaptureDevice: AVCaptureDevice?
        private var lastScannedBarcode: String?
        private var lastScanTime: Date?

        init(onBarcodeScanned: @escaping (String) -> Void) {
            self.onBarcodeScanned = onBarcodeScanned
        }

        func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            guard let metadataObject = metadataObjects.first,
                  let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
                  let stringValue = readableObject.stringValue else { return }

            // Debounce: don't scan the same barcode within 2 seconds
            if let lastBarcode = lastScannedBarcode,
               let lastTime = lastScanTime,
               lastBarcode == stringValue,
               Date().timeIntervalSince(lastTime) < 2.0 {
                return
            }

            lastScannedBarcode = stringValue
            lastScanTime = Date()

            // Haptic feedback
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))

            onBarcodeScanned(stringValue)
        }

        func updateTorch(isOn: Bool) {
            guard let device = videoCaptureDevice, device.hasTorch else { return }

            do {
                try device.lockForConfiguration()
                device.torchMode = isOn ? .on : .off
                device.unlockForConfiguration()
            } catch {
                print("Torch could not be used: \(error)")
            }
        }
    }

    static func dismantleUIView(_ uiView: UIView, coordinator: Coordinator) {
        coordinator.captureSession?.stopRunning()
    }
}

// MARK: - Scanner Overlay

struct ScannerOverlayView: View {
    @State private var isAnimating = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Dim background
                Color.black.opacity(0.5)
                    .ignoresSafeArea()

                // Scanning frame
                Rectangle()
                    .strokeBorder(Color.white, lineWidth: 3)
                    .frame(width: 250, height: 250)
                    .overlay(
                        // Scanning line animation
                        Rectangle()
                            .fill(Color.green.opacity(0.5))
                            .frame(height: 2)
                            .offset(y: isAnimating ? 125 : -125)
                    )
                    .mask(
                        Rectangle()
                            .frame(width: 250, height: 250)
                    )
            }
            .blendMode(.destinationOut)
        }
        .compositingGroup()
        .onAppear {
            withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                isAnimating = true
            }
        }
    }
}

// MARK: - Scanned Product Card

struct ScannedProductCard: View {
    let product: ScannedProduct
    let onConfirm: () -> Void
    let onRescan: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            // Success icon
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 50))
                .foregroundStyle(.green)

            // Product info
            VStack(spacing: 8) {
                Text(product.name)
                    .font(.headline)
                    .multilineTextAlignment(.center)

                if let brand = product.brand {
                    Text(brand)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            // Buttons
            HStack(spacing: 16) {
                Button {
                    onRescan()
                } label: {
                    Text("Rescan")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

                Button {
                    onConfirm()
                } label: {
                    Text("Use Product")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(24)
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(16)
        .shadow(radius: 10)
        .padding()
    }
}

// MARK: - Product Not Found Card

struct ProductNotFoundCard: View {
    let barcode: String
    let onRetry: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundStyle(.orange)

            Text("Product Not Found")
                .font(.headline)

            Text("Barcode: \(barcode)")
                .font(.caption)
                .foregroundStyle(.secondary)

            Text("This product is not in our database. You can add it manually.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            HStack(spacing: 16) {
                Button {
                    onCancel()
                } label: {
                    Text("Try Again")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

                Button {
                    onRetry()
                } label: {
                    Text("Retry")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(24)
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(16)
        .shadow(radius: 10)
        .padding()
    }
}

// MARK: - Error Card

struct ErrorCard: View {
    let message: String
    let onRetry: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 50))
                .foregroundStyle(.red)

            Text("Error")
                .font(.headline)

            Text(message)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            HStack(spacing: 16) {
                Button {
                    onCancel()
                } label: {
                    Text("Cancel")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

                Button {
                    onRetry()
                } label: {
                    Text("Retry")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(24)
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(16)
        .shadow(radius: 10)
        .padding()
    }
}

// MARK: - Camera Permission View

struct CameraPermissionView: View {
    let permissionStatus: CameraPermissionStatus
    let onRequestPermission: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "camera.fill")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            VStack(spacing: 12) {
                Text("Camera Access Required")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text(instructionText)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            if permissionStatus == .notDetermined {
                Button {
                    onRequestPermission()
                } label: {
                    Text("Allow Camera Access")
                        .font(.headline)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.borderedProminent)
            } else {
                Button {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Text("Open Settings")
                        .font(.headline)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
    }

    private var instructionText: String {
        switch permissionStatus {
        case .notDetermined:
            return "To scan product barcodes, we need access to your camera."
        case .denied:
            return "Camera access was denied. Please enable it in Settings to scan barcodes."
        case .restricted:
            return "Camera access is restricted on this device."
        case .authorized:
            return ""
        }
    }
}

// MARK: - Preview

#Preview {
    BarcodeScannerView(
        scannerService: BarcodeScannerService(),
        lookupService: ProductLookupService(
            api: OpenFoodFactsAPI(),
            historyRepository: ScanHistoryRepository(
                modelContext: ModelContext(
                    try! ModelContainer(for: ScanHistory.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
                )
            )
        ),
        onProductScanned: { _ in }
    )
}
