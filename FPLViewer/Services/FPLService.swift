//
//  FPLService.swift
//  FPLViewer
//
//  Created by Lokesh Professional on 30/09/26.
//

import Foundation

enum FPLError: Error, LocalizedError {
    case invalidURL
    case badResponse(Int)
    case decodingFailed(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:             return "Invalid URL."
        case .badResponse(let code):  return "Status \(code)."
        case .decodingFailed(let e):  return e.localizedDescription
        }
    }
}

final class FPLService {

    static let shared = FPLService()
    private init() {}

    private let apiURL = "https://fantasy.premierleague.com/api/bootstrap-static/"

    // MARK: - Fetch raw Data from network
    // Returns Data (not decoded) so CacheService can store it directly
    func fetchRawData() async throws -> Data {
        guard let url = URL(string: apiURL) else { throw FPLError.invalidURL }

        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 30

        // Swift Concurrency: suspends here until URLSession completes
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse,
              (200...299).contains(http.statusCode) else {
            let code = (response as? HTTPURLResponse)?.statusCode ?? -1
            throw FPLError.badResponse(code)
        }

        return data
    }

    // MARK: - Decode raw Data into FPLResponse
    // Separated from fetch so CacheService can call this too
    func decode(_ data: Data) throws -> FPLResponse {
        do {
            return try JSONDecoder().decode(FPLResponse.self, from: data)
        } catch {
            throw FPLError.decodingFailed(error)
        }
    }
}
