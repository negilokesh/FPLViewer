//
//  TeamCell.swift
//  FPLViewer
//
//  Created by Lokesh Professional on 30/09/26.
//

import UIKit

class TeamCell: UITableViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var teamShortFormImageLabel: UILabel!
    @IBOutlet weak var teamIconView: UIView!
    @IBOutlet weak var teamName: UILabel!
    @IBOutlet weak var playerCountLabel: UILabel!
    @IBOutlet weak var seasonNumberLabel: UILabel!
    
    // MARK: - Variables
    static let identifier = "TeamCell"
    static let nib = UINib(nibName: "TeamCell", bundle: .main)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    // MARK: - Configure the cell's data and UI
    func setupTeamData(team: Team, playerCount: Int) {
        teamName.text                  = team.name
        teamShortFormImageLabel.text   = team.shortName
        playerCountLabel.text          = "\(team.shortName) · \(playerCount) players"
        seasonNumberLabel.text         = team.position.ordinalString

        let bgColor = TeamColorProvider.color(forTeamId: team.id)
        teamIconView.backgroundColor      = bgColor
        teamIconView.layer.cornerRadius   = 5
        teamShortFormImageLabel.textColor = contrastingColor(for: bgColor)
    }
    
    // Inside TeamCell, before or after setupTeamData
    private func contrastingColor(for background: UIColor) -> UIColor {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        background.getRed(&r, green: &g, blue: &b, alpha: &a)
        let luminance = 0.2126*r + 0.7152*g + 0.0722*b
        return luminance < 0.35 ? .white : .black
    }
    
}
