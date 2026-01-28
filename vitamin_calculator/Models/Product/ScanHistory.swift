//
//  ScanHistory.swift
//  vitamin_calculator
//
//  Created by TDD on 26.01.26.
//

import Foundation
import SwiftData

/// Represents a history record of a barcode scan attempt.
/// Used to cache scanned products and track scan success/failure.
@Model
final class ScanHistory {
    // MARK: - Stored Properties

    /// The barcode that was scanned
    var barcode: String

    /// The product name (from the scanned result or entered by user)
    var productName: String

    /// Brand name (optional)
    var brand: String?

    /// URL to product image (optional)
    var imageUrl: String?

    /// Timestamp when the scan occurred
    var scannedAt: Date

    /// Whether the scan successfully retrieved product information
    var wasSuccessful: Bool

    /// Encoded product data for caching ScannedProduct
    @Attribute(.transformable(by: "NSSecureUnarchiveFromDataTransformer"))
    private var productData: Data?

    // MARK: - Computed Properties

    /// The cached product data from the scan
    var cachedProduct: ScannedProduct? {
        get {
            guard let data = productData,
                  let decoded = try? JSONDecoder().decode(ScannedProduct.self, from: data) else {
                return nil
            }
            return decoded
        }
        set {
            productData = try? JSONEncoder().encode(newValue)
        }
    }

    // MARK: - Initialization

    /// Creates a new scan history record
    /// - Parameters:
    ///   - barcode: The barcode that was scanned
    ///   - productName: The product name
    ///   - brand: Brand name (optional)
    ///   - imageUrl: URL to product image (optional)
    ///   - wasSuccessful: Whether the scan successfully retrieved product information
    init(
        barcode: String,
        productName: String,
        brand: String?,
        imageUrl: String?,
        wasSuccessful: Bool
    ) {
        self.barcode = barcode
        self.productName = productName
        self.brand = brand
        self.imageUrl = imageUrl
        self.wasSuccessful = wasSuccessful
        self.scannedAt = Date()
    }
}
