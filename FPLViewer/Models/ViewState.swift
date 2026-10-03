//
//  ViewState.swift
//  FPLViewer
//
//  Created by Lokesh Professional on 30/09/26.
//

import Foundation

// Every possible screen condition maps to exactly one case
enum ViewState {

    case initial                              // App just launched, nothing done yet
    case loading                              // First fetch in progress, no data yet
    case loaded([Team])                       // Data fetched successfully
    case failed(AppError)                     // First fetch failed, no data to show
    case refreshing([Team])                   // Pull-to-refresh in progress, old data visible
    case refreshFailed([Team], AppError)      // Refresh failed, old data still visible
    case empty                                // Fetch succeeded but returned 0 teams

    // Convenience: returns the team data if any state holds it
    var teams: [Team]? {
        switch self {
        case .loaded(let t),
             .refreshing(let t),
             .refreshFailed(let t, _): return t
        default:                       return nil
        }
    }
}
