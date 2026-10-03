//
//  CacheService.swift
//  FPLViewer
//
//  Created by Lokesh Professional on 30/09/26.
//

import Foundation

final class CacheService {

    static let shared = CacheService()
    private init() {}   

    private let fileName = "fpl_bootstrap_cache.json"

    // Builds the full file path inside the app's Documents directory
    private var cacheURL: URL? {
        FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent(fileName)
    }

    // Writes raw JSON Data to disk — called after every successful API response
    func save(_ data: Data) {
        guard let url = cacheURL else { return }
        try? data.write(to: url, options: .atomic)  // .atomic = safe write, no corruption
    }

    // Reads cached JSON Data from disk — called on app launch before network call
    // Returns nil if no cache file exists yet
    func load() -> Data? {
        guard let url = cacheURL,
              FileManager.default.fileExists(atPath: url.path) else { return nil }
        return try? Data(contentsOf: url)
    }

    // Removes the cache file — useful for testing or logout
    func clear() {
        guard let url = cacheURL else { return }
        try? FileManager.default.removeItem(at: url)
    }
}
