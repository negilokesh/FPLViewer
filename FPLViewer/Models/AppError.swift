//
//  AppError.swift
//  FPLViewer
//
//  Created by Lokesh Professional on 30/09/26.
//

import Foundation

// AppError wraps all possible failure types into one clean enum
// This makes it easy to show the right message in the UI
enum AppError: Error, LocalizedError {
    case network(String)
    case decoding(String)
    case noInternet
    case unknown(String)

    // Converts any Error into our AppError type
    static func from(_ error: Error) -> AppError {
        // Check if it's a network connectivity error
        let nsError = error as NSError
        if nsError.domain == NSURLErrorDomain &&
           nsError.code == NSURLErrorNotConnectedToInternet {
            return .noInternet
        }

        if let fplError = error as? FPLError {
            switch fplError {
            case .invalidURL:              return .network("Invalid API URL")
            case .badResponse(let code):   return .network("Server returned \(code)")
            case .decodingFailed(let e):   return .decoding(e.localizedDescription)
            }
        }
        return .unknown(error.localizedDescription)
    }

    // Human-readable message shown in the UI
    var errorDescription: String? {
        switch self {
        case .network(let msg):  return "Network error: \(msg)"
        case .decoding(let msg): return "Data error: \(msg)"
        case .noInternet:        return "No internet connection.\nShowing cached data."
        case .unknown(let msg):  return msg
        }
    }
}
