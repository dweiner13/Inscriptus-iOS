//
//  AbbreviationCell.swift
//  inscriptus
//
//  Created by Daniel A. Weiner on 2/20/15.
//  Copyright (c) 2015 Daniel Weiner. All rights reserved.
//

import UIKit

class AbbreviationCell: UITableViewCell {
    
    @IBOutlet weak var primaryLabel: UILabel!
    @IBOutlet weak var secondaryLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
