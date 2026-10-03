//
//  SquadViewController.swift
//  FPLViewer
//
//  Created by Lokesh Professional on 30/09/26.
//

import UIKit

class SquadViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var squadViewTV: UITableView!
    @IBOutlet weak var headerTitle: UILabel!

    // MARK: - Variables
    static var storyboardName: StoryboardName = .main
    var squadViewModel = SquadViewModel()
    var teamName: String = ""
    var players: [Player] = []

    // MARK: - Search UI
    private let searchBar = UISearchBar()
    private let searchContainerView = UIView()
    private var isSearchBarVisible = false

    // MARK: - Search Sizing
    private let searchBarPadding: CGFloat = 10
    private let searchBarHeight: CGFloat = 32
    private var searchTotalHeight: CGFloat { searchBarPadding * 2 + searchBarHeight }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetupOnDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initialSetupOnWillAppear()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}

// MARK: - Private Setup
extension SquadViewController {

    private func initialSetupOnDidLoad() {
        squadViewModel.setPlayers(players)
        registerCellXib()
        setupSearchUI()
        headerTitle.text = teamName
        navigationItem.hidesBackButton = true
    }

    private func initialSetupOnWillAppear() {
        navigationController?.isNavigationBarHidden = false
    }

    private func registerCellXib() {
        squadViewTV.register(PlayerCell.nib, forCellReuseIdentifier: PlayerCell.identifier)
        squadViewTV.delegate = self
        squadViewTV.dataSource = self
    }

    private func setupSearchUI() {
        // Container that will slide down over the tableView
        searchContainerView.backgroundColor = .systemBackground
        searchContainerView.clipsToBounds = true

        // Search bar inside the container — equal padding top & bottom
        searchBar.placeholder = "Search players..."
        searchBar.delegate = self
        searchBar.showsCancelButton = true
        searchBar.searchBarStyle = .minimal
        searchBar.frame = CGRect(
            x: 12,
            y: searchBarPadding,
            width: view.frame.width - 24,
            height: searchBarHeight
        )
        searchContainerView.addSubview(searchBar)
    }
}

// MARK: - IBActions
extension SquadViewController {

    @IBAction func backButtonAction(sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func searchbuttonAction(sender: UIButton) {
        isSearchBarVisible ? hideSearchBar() : showSearchBar()
    }
}

// MARK: - Search Animation
extension SquadViewController {

    private func showSearchBar() {
        isSearchBarVisible = true

        let tableTop = squadViewTV.frame.origin.y

        // Start collapsed at the top edge of tableView
        searchContainerView.frame = CGRect(
            x: 0,
            y: tableTop,
            width: view.frame.width,
            height: 0
        )
        view.insertSubview(searchContainerView, aboveSubview: squadViewTV)

        // Slide down with spring — table content pushes down simultaneously
        UIView.animate(
            withDuration: 0.4,
            delay: 0,
            usingSpringWithDamping: 0.85,
            initialSpringVelocity: 0.5,
            options: .curveEaseOut
        ) {
            self.searchContainerView.frame.size.height = self.searchTotalHeight
            self.squadViewTV.contentInset.top = self.searchTotalHeight
            self.squadViewTV.scrollIndicatorInsets.top = self.searchTotalHeight
        }

        searchBar.becomeFirstResponder()
    }

    private func hideSearchBar() {
        isSearchBarVisible = false
        searchBar.resignFirstResponder()

        // Slide back up — table content rises simultaneously
        UIView.animate(
            withDuration: 0.25,
            delay: 0,
            options: .curveEaseIn,
            animations: {
                self.searchContainerView.frame.size.height = 0
                self.squadViewTV.contentInset.top = 0
                self.squadViewTV.scrollIndicatorInsets.top = 0
            },
            completion: { _ in
                self.searchContainerView.removeFromSuperview()
                self.squadViewModel.clearSearch()
                self.searchBar.text = ""
                self.squadViewTV.reloadData()
            }
        )
    }
}

// MARK: - UISearchBarDelegate
extension SquadViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        squadViewModel.filterPlayers(with: searchText)
        squadViewTV.reloadData()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        hideSearchBar()
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension SquadViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return squadViewModel.numberOfSections()
    }

    func tableView(_ tableView: UITableView,numberOfRowsInSection section: Int) -> Int {
        return squadViewModel.numberOfPlayers(in: section)
    }

    func tableView(_ tableView: UITableView,cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PlayerCell.identifier,
            for: indexPath) as? PlayerCell else {
            return UITableViewCell()
        }
        let player = squadViewModel.player(at: indexPath)
        cell.setupPlayerData(player: player, rank: indexPath.row + 1)
        return cell
    }

    func tableView(_ tableView: UITableView,didSelectRowAt indexPath: IndexPath) {
        print("Player tapped: \(squadViewModel.player(at: indexPath))")
    }

    // MARK: - Section Headers
    func tableView(_ tableView: UITableView,viewForHeaderInSection section: Int) -> UIView? {
        if squadViewModel.isSearchActive {
            return makeHeader(title: "Results", color: UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1))
        }
        let sectionColors: [UIColor] = [
            UIColor(red: 1.0,  green: 0.95, blue: 0.6,  alpha: 1),
            UIColor(red: 0.83, green: 0.93, blue: 0.83, alpha: 1),
            UIColor(red: 0.8,  green: 0.9,  blue: 1.0,  alpha: 1),
            UIColor(red: 0.97, green: 0.84, blue: 0.84, alpha: 1)
        ]
        return makeHeader(
            title: squadViewModel.sectionTitles[section].uppercased(),
            color: sectionColors[section]
        )
    }

    func tableView(_ tableView: UITableView,heightForHeaderInSection section: Int) -> CGFloat {
        return 32
    }

    private func makeHeader(title: String, color: UIColor) -> UIView {
        let header = UIView()
        header.backgroundColor = color

        let label = UILabel()
        label.text = title
        label.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        label.textColor = UIColor.darkGray
        label.translatesAutoresizingMaskIntoConstraints = false

        header.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 16),
            label.centerYAnchor.constraint(equalTo: header.centerYAnchor)
        ])
        return header
    }
}

