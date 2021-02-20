//
//  SleepHistoryCell.swift
//  BeHappy
//
//  Created by Darrel Muonekwu on 2/17/21.
//

import UIKit

class SleepHistoryCell: UITableViewCell {

    @IBOutlet weak var hoursLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
