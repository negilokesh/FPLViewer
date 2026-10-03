//
//  PlayerCell.swift
//  FPLViewer
//
//  Created by Lokesh Professional on 30/09/26.
//

import UIKit

class PlayerCell: UITableViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var numberListLabel: UILabel!
    @IBOutlet weak var playerNameLabel: UILabel!
    @IBOutlet weak var playerPostionLabel: UILabel!
    @IBOutlet weak var playerPointLabel: UILabel!
    @IBOutlet weak var playerPriceLabel: UILabel!
    
    // MARK: - Variables
    static let identifier = "PlayerCell"
    static let nib = UINib(nibName: "PlayerCell", bundle: .main)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    // MARK: - Configure the cell's data and UI
    func setupPlayerData(player: Player, rank: Int) {
        numberListLabel.text   = "\(rank)"
        playerNameLabel.text   = player.webName
        playerPostionLabel.text = player.positionName
        playerPointLabel.text  = "\(player.totalPoints) pts"
        playerPriceLabel.text  = player.priceString  
    }
}
