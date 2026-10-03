//
//  TeamsViewModel.swift
//  FPLViewer
//
//  Created by Lokesh Professional on 30/09/26.
//

import Foundation
import Combine     // Combine framework — for @Published and reactive binding

class TeamsViewModel {

    // MARK: - @Published state (Combine)
    // @Published wraps state so any change emits through the $state publisher
    // ViewController subscribes to $state and reacts to every emission
    @Published private(set) var state: ViewState = .initial

    // Stores all players so we can filter by team when user taps a row
    private var allPlayers: [Player] = []

    // Stores Combine subscriptions — cancels them when ViewModel is deallocated
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Public accessors
    func numberOfTeams() -> Int   { state.teams?.count ?? 0 }
    func team(at index: Int) -> Team { state.teams![index] }

    func players(forTeamId id: Int) -> [Player] {
        return allPlayers.filter { $0.team == id }
    }

    // MARK: - Initial Load
    // Called once on viewDidLoad
    // Strategy: load cache first (instant), then always try network (fresh data)
    func loadData() {

        // Step 1: Check cache — if exists, decode and show immediately
        if let cachedData = CacheService.shared.load(),
           let response = try? FPLService.shared.decode(cachedData) {
            allPlayers  = response.elements
            state       = response.teams.isEmpty ? .empty : .loaded(response.teams)
        }

        // Step 2: Attempt network fetch
        // If we have cached data → show .refreshing (keeps table visible)
        // If no cache → show .loading (blank + spinner)
        state = (state.teams != nil) ? .refreshing(state.teams!) : .loading

        Task {
            do {
                // fetchRawData() suspends until network completes (async/await)
                let rawData  = try await FPLService.shared.fetchRawData()
                let response = try FPLService.shared.decode(rawData)

                // Save fresh data to cache for next offline launch
                CacheService.shared.save(rawData)

                // Always update UI on the main thread
                await MainActor.run {
                    self.allPlayers = response.elements
                    self.state = response.teams.isEmpty ? .empty : .loaded(response.teams)
                }

            } catch {
                await MainActor.run {
                    let appError = AppError.from(error)
                    if let existingTeams = self.state.teams {
                        // Had data (cache) → refresh failed, keep showing old data
                        self.state = .refreshFailed(existingTeams, appError)
                    } else {
                        // No data at all → hard failure with retry button
                        self.state = .failed(appError)
                    }
                }
            }
        }
    }

    // MARK: - Pull-to-Refresh
    // Only hits network — never re-reads cache
    func refreshData() {
        guard let existingTeams = state.teams else {
            // If no data yet, do a full load instead
            loadData()
            return
        }

        // Show spinner in refresh control while keeping table data visible
        state = .refreshing(existingTeams)

        Task {
            do {
                let rawData  = try await FPLService.shared.fetchRawData()
                let response = try FPLService.shared.decode(rawData)
                CacheService.shared.save(rawData)

                await MainActor.run {
                    self.allPlayers = response.elements
                    self.state = response.teams.isEmpty ? .empty : .loaded(response.teams)
                }

            } catch {
                await MainActor.run {
                    // Refresh failed — keep showing old data + show banner
                    self.state = .refreshFailed(existingTeams, AppError.from(error))
                }
            }
        }
    }

    // MARK: - Retry
    // Called when user taps Retry button on the failure screen
    func retry() {
        state = .initial    // reset state before re-loading
        loadData()
    }
}
