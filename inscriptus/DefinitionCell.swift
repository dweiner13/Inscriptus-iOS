//
//  definitionCell.swift
//  Latin Companion iOS
//
//  Created by Daniel A. Weiner on 2/7/15.
//  Copyright (c) 2015 Daniel Weiner. All rights reserved.
//

import UIKit

class DefinitionCell: UITableViewCell {
    
    @IBOutlet weak var definitionTextView: UITextView!
    @IBOutlet weak var meaningsTextView: UITextView!
    
    @IBOutlet weak var definitionHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var topMarginConstraint: NSLayoutConstraint!
    
    var connectedToPreviousCell: Bool = false {
        willSet {
            self.topMarginConstraint.constant = 0
            self.definitionTextView.textContainerInset = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        definitionTextView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 4, right: 8)
        meaningsTextView.textContainerInset = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
