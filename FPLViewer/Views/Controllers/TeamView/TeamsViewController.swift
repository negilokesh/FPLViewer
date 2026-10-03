//
//  TeamsViewController.swift
//  FPLViewer
//
//  Created by Lokesh Professional on 30/09/26.
//

import UIKit
import Combine

class TeamsViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var teamsViewTV: UITableView!

    // MARK: - ViewModel
    var teamsViewModel = TeamsViewModel()

    // MARK: - Combine
    // Stores all active Combine subscriptions
    // When this Set is deallocated, all subscriptions cancel automatically
    private var cancellables = Set<AnyCancellable>()

    // MARK: - UI Components
    private let spinner       = UIActivityIndicatorView(style: .large)
    private let refreshControl = UIRefreshControl()
    private let errorView     = UIView()
    private let errorLabel    = UILabel()
    private let retryButton   = UIButton(type: .system)
    private let bannerView    = UIView()
    private let bannerLabel   = UILabel()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetupOnDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
    }
}

// MARK: - Setup
extension TeamsViewController {

    private func initialSetupOnDidLoad() {
        registerCellXib()
        setupSpinner()
        setupErrorView()
        setupBanner()
        setupRefreshControl()
        bindViewModel()
        teamsViewModel.loadData()
    }

    private func registerCellXib() {
        teamsViewTV.register(TeamCell.nib, forCellReuseIdentifier: TeamCell.identifier)
        teamsViewTV.delegate   = self
        teamsViewTV.dataSource = self
    }

    // Centered spinner shown during initial load
    private func setupSpinner() {
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.hidesWhenStopped = true
        view.addSubview(spinner)
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    // Full-screen error view shown when first load fails and no cache exists
    private func setupErrorView() {
        errorView.backgroundColor    = .systemBackground
        errorView.isHidden           = true
        errorView.translatesAutoresizingMaskIntoConstraints = false

        errorLabel.numberOfLines     = 0
        errorLabel.textAlignment     = .center
        errorLabel.textColor         = .systemRed
        errorLabel.font              = .systemFont(ofSize: 15)
        errorLabel.translatesAutoresizingMaskIntoConstraints = false

        retryButton.setTitle("Retry", for: .normal)
        retryButton.titleLabel?.font = .boldSystemFont(ofSize: 16)
        retryButton.translatesAutoresizingMaskIntoConstraints = false
        // When tapped, calls teamsViewModel.retry()
        retryButton.addTarget(self, action: #selector(retryTapped), for: .touchUpInside)

        errorView.addSubview(errorLabel)
        errorView.addSubview(retryButton)
        view.addSubview(errorView)

        NSLayoutConstraint.activate([
            errorView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            errorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            errorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            errorView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            errorLabel.centerXAnchor.constraint(equalTo: errorView.centerXAnchor),
            errorLabel.centerYAnchor.constraint(equalTo: errorView.centerYAnchor, constant: -20),
            errorLabel.leadingAnchor.constraint(equalTo: errorView.leadingAnchor, constant: 32),
            errorLabel.trailingAnchor.constraint(equalTo: errorView.trailingAnchor, constant: -32),

            retryButton.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 16),
            retryButton.centerXAnchor.constraint(equalTo: errorView.centerXAnchor)
        ])
    }

    // Thin banner at top of table — shown when pull-to-refresh fails but data is visible
    private func setupBanner() {
        bannerView.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.9)
        bannerView.isHidden        = true
        bannerView.translatesAutoresizingMaskIntoConstraints = false

        bannerLabel.textColor      = .white
        bannerLabel.font           = .systemFont(ofSize: 13, weight: .medium)
        bannerLabel.textAlignment  = .center
        bannerLabel.translatesAutoresizingMaskIntoConstraints = false

        bannerView.addSubview(bannerLabel)
        view.addSubview(bannerView)

        NSLayoutConstraint.activate([
            bannerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            bannerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bannerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bannerView.heightAnchor.constraint(equalToConstant: 36),

            bannerLabel.centerYAnchor.constraint(equalTo: bannerView.centerYAnchor),
            bannerLabel.leadingAnchor.constraint(equalTo: bannerView.leadingAnchor, constant: 16),
            bannerLabel.trailingAnchor.constraint(equalTo: bannerView.trailingAnchor, constant: -16)
        ])
    }

    private func setupRefreshControl() {
        // UIRefreshControl triggers pull-to-refresh gesture on the table
        refreshControl.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        teamsViewTV.refreshControl = refreshControl
    }
}

// MARK: - Combine Binding
extension TeamsViewController {

    // Subscribes to teamsViewModel.$state using Combine
    // Every time state changes in the ViewModel, handleState() is called automatically
    private func bindViewModel() {
        teamsViewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.handleState(state)
            }
            .store(in: &cancellables)
    }

    // Single function that drives ALL UI changes based on state
    private func handleState(_ state: ViewState) {
        switch state {

        case .initial:
            // App just launched — hide everything, prepare for load
            teamsViewTV.isHidden = true
            errorView.isHidden   = true
            bannerView.isHidden  = true

        case .loading:
            // First fetch, no data — show spinner, hide table
            teamsViewTV.isHidden = true
            errorView.isHidden   = true
            bannerView.isHidden  = true
            spinner.startAnimating()

        case .loaded(let teams):
            // Success — hide spinner, show table with fresh data
            spinner.stopAnimating()
            refreshControl.endRefreshing()
            teamsViewTV.isHidden = false
            errorView.isHidden   = true
            bannerView.isHidden  = true
            teamsViewTV.reloadData()
            print("✅ Loaded \(teams.count) teams")

        case .failed(let error):
            // Hard failure (no cache either) — show full error screen + retry button
            spinner.stopAnimating()
            teamsViewTV.isHidden = true
            errorLabel.text      = error.errorDescription
            errorView.isHidden   = false
            bannerView.isHidden  = true

        case .refreshing:
            // Pull-to-refresh in progress — table stays visible, spinner in refresh control
            bannerView.isHidden  = true
            teamsViewTV.isHidden = false
            // refreshControl is already spinning from the gesture

        case .refreshFailed(_, let error):
            // Refresh failed — keep showing old data, show banner for 3 seconds
            refreshControl.endRefreshing()
            teamsViewTV.isHidden = false
            errorView.isHidden   = true
            showBanner(message: error.errorDescription ?? "Refresh failed")

        case .empty:
            // API returned 0 teams (shouldn't happen with FPL, but handled)
            spinner.stopAnimating()
            refreshControl.endRefreshing()
            teamsViewTV.isHidden = true
            errorLabel.text      = "No teams available."
            retryButton.isHidden = false
            errorView.isHidden   = false
        }
    }

    // Shows the orange banner for 3 seconds then auto-hides
    private func showBanner(message: String) {
        bannerLabel.text    = message
        bannerView.isHidden = false
        bannerView.alpha    = 1

        // Auto-dismiss after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            UIView.animate(withDuration: 0.4) {
                self?.bannerView.alpha = 0
            } completion: { _ in
                self?.bannerView.isHidden = true
                self?.bannerView.alpha    = 1
            }
        }
    }
}

// MARK: - Actions
extension TeamsViewController {

    // Called by pull-to-refresh gesture
    @objc private func pullToRefresh() {
        teamsViewModel.refreshData()
    }

    // Called by retry button on the error screen
    @objc private func retryTapped() {
        teamsViewModel.retry()
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension TeamsViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return teamsViewModel.numberOfTeams()
    }

    func tableView(_ tableView: UITableView,cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TeamCell.identifier,for: indexPath) as? TeamCell else {
            return UITableViewCell()
        }

        if let teams = teamsViewModel.state.teams {
            let team = teams[indexPath.row]
            let playerCount = teamsViewModel.players(forTeamId: team.id).count
            cell.setupTeamData(team: team, playerCount: playerCount)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView,didSelectRowAt indexPath: IndexPath) {
        guard let teams = teamsViewModel.state.teams else { return }
        let selected = teams[indexPath.row]

        let sb = UIStoryboard(name: StoryboardName.main.rawValue, bundle: nil)
        guard let squadVC = sb.instantiateViewController(withIdentifier: "SquadViewController") as? SquadViewController else { return
        }

        squadVC.teamName = selected.name
        squadVC.players = teamsViewModel.players(forTeamId: selected.id)
        navigationController?.pushViewController(squadVC, animated: true)
    }
}
