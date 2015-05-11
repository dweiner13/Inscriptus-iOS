//
//  InscribedCell.swift
//  inscriptus
//
//  Created by Daniel A. Weiner on 5/3/15.
//  Copyright (c) 2015 Daniel Weiner. All rights reserved.
//

import UIKit

class InscribedCell: UITableViewCell {
    
    @IBOutlet weak var mainLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
//        self.backgroundColor = UIColor(patternImage: UIImage(named: "engraved_background.png")!)
        
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
