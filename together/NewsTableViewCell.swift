//
//  NewsTableViewCell.swift
//  together
//
//  Created by ASda Bogasd on 24.01.17.
//  Copyright © 2017 Attractive Products. All rights reserved.
//

import UIKit

class NewsTableViewCell: UITableViewCell {
    @IBOutlet var textLabrl: UILabel!
    @IBOutlet var topicLabel: UILabel!
    @IBOutlet var avatarImage: UIImageView!
    @IBOutlet var typeIcon: UIImageView!
    @IBOutlet var imageButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
