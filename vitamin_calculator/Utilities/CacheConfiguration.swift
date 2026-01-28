//
//  CacheConfiguration.swift
//  vitamin_calculator
//
//  Created by Claude Code on 28.01.26.
//  Sprint 7 Phase 1: Memory Optimization - Cache Configuration
//

import Foundation

/// Configures app-wide caching strategies
/// Sprint 7 Phase 1: Added to optimize memory usage
final class CacheConfiguration {

    /// Configures the shared URLCache for optimal memory usage
    /// Call this during app initialization
    static func configure() {
        // Configure URL cache with reasonable limits
        // Memory: 50MB, Disk: 100MB
        let memoryCapacity = 50_000_000  // 50 MB
        let diskCapacity = 100_000_000   // 100 MB

        let cache = URLCache(
            memoryCapacity: memoryCapacity,
            diskCapacity: diskCapacity,
            directory: nil
        )

        URLCache.shared = cache
    }

    /// Clears all cached data
    static func clearCache() {
        URLCache.shared.removeAllCachedResponses()
    }

    /// Clears cache older than specified date
    /// - Parameter date: Remove cache older than this date
    static func clearCache(olderThan date: Date) {
        URLCache.shared.removeCachedResponses(since: date)
    }
}
