//
//  SquadViewModel.swift
//  FPLViewer
//
//  Created by Lokesh Professional on 30/09/26.
//


import Foundation
import UIKit

class SquadViewModel {

    // MARK: - Data
    // Now stores real Player objects instead of dummy strings
    private var allPlayers: [Player] = []
    private(set) var filteredPlayers: [Player] = []
    private(set) var isSearchActive = false

    // MARK: - Section Titles
    let sectionTitles = ["Goalkeepers", "Defenders", "Midfielders", "Forwards"]

    // Groups players by position into 4 sections
    // elementType: 1=GK, 2=DEF, 3=MID, 4=FWD
    private var playersBySection: [[Player]] {
        return [
            allPlayers.filter { $0.elementType == 1 }.sorted { $0.totalPoints > $1.totalPoints },
            allPlayers.filter { $0.elementType == 2 }.sorted { $0.totalPoints > $1.totalPoints },
            allPlayers.filter { $0.elementType == 3 }.sorted { $0.totalPoints > $1.totalPoints },
            allPlayers.filter { $0.elementType == 4 }.sorted { $0.totalPoints > $1.totalPoints },
        ]
    }

    // MARK: - Set Players (called from SquadViewController after receiving data)
    func setPlayers(_ players: [Player]) {
        allPlayers = players
    }

    // MARK: - Helpers
    func numberOfSections() -> Int {
        return isSearchActive ? 1 : sectionTitles.count
    }

    func numberOfPlayers(in section: Int) -> Int {
        if isSearchActive {
            return filteredPlayers.count
        }
        return playersBySection[section].count
    }

    // Now returns Player object (not String)
    func player(at indexPath: IndexPath) -> Player {
        if isSearchActive {
            return filteredPlayers[indexPath.row]
        }
        return playersBySection[indexPath.section][indexPath.row]
    }

    // MARK: - Search
    func filterPlayers(with searchText: String) {
        if searchText.isEmpty {
            filteredPlayers = []
            isSearchActive = false
        } else {
            isSearchActive = true
            let query = searchText.lowercased()
            filteredPlayers = allPlayers.filter {
                $0.webName.lowercased().contains(query) ||
                $0.firstName.lowercased().contains(query) ||
                $0.secondName.lowercased().contains(query)
            }
        }
    }

    func clearSearch() {
        filteredPlayers = []
        isSearchActive = false
    }
}
