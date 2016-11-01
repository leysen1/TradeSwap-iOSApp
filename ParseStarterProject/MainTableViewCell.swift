//
//  MainTableViewCell.swift
//  ParseStarterProject-Swift
//
//  Created by Charlotte Leysen on 31/10/2016.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class MainTableViewCell: UITableViewCell {

    @IBOutlet var userLabel: UILabel!
    @IBOutlet var interestedInLabel: UILabel!
    @IBOutlet var imageProfile: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
