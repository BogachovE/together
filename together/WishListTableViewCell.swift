//
//  WishListTableViewCell.swift
//  together
//
//  Created by ASda Bogasd on 05.03.17.
//  Copyright © 2017 Attractive Products. All rights reserved.
//

import UIKit

class WishListTableViewCell: UITableViewCell {

    @IBOutlet weak var link: UILabel!
    @IBOutlet weak var pluseButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
