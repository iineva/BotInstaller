//
//  CommitCell.swift
//  BotInstaller
//
//  Created by Steven on 16/1/6.
//  Copyright © 2016年 Neva. All rights reserved.
//

import UIKit

class CommitCell: UITableViewCell {

    @IBOutlet weak var titleLab: UILabel!
    @IBOutlet weak var subtitleLab: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLab.adjustsFontSizeToFitWidth = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
