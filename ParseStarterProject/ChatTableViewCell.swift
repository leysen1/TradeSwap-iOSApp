//
//  ChatTableViewCell.swift
//  ParseStarterProject-Swift
//
//  Created by Charlotte Leysen on 03/11/2016.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class ChatTableViewCell: UITableViewCell {

    
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var usernameLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
