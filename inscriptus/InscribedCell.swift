//
//  InscribedCell.swift
//  inscriptus
//
//  Created by Daniel A. Weiner on 5/3/15.
//  Copyright (c) 2015 Daniel Weiner. All rights reserved.
//

import UIKit

class InscribedCell: UITableViewCell {
    
    @IBOutlet weak var centerBackgroundView: UIView!
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var centerImageView: UIImageView!
    @IBOutlet weak var centerImageWidthConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        self.centerBackgroundView.layer.borderColor = UIColor(red:0.78, green:0.769, blue:0.769, alpha:1).CGColor
        self.centerBackgroundView.layer.borderWidth = 2
        
        var gradient = CAGradientLayer()
        gradient.frame = self.centerBackgroundView.bounds
        gradient.colors = [
            UIColor.whiteColor().CGColor,
            UIColor.grayColor().CGColor
        ]
        self.centerBackgroundView.layer.insertSublayer(gradient, atIndex: 0)
        
//        self.centerBackgroundView.backgroundColor = UIColor(red:0.845, green:0.806, blue:0.806, alpha:1)
    }
    
    override func setHighlighted(highlighted: Bool, animated: Bool) {
        if highlighted {
            self.centerBackgroundView?.backgroundColor =  UIColor(red:0.862, green:0.849, blue:0.849, alpha:1)

        }
        else {
            self.centerBackgroundView?.backgroundColor = UIColor(red:0.925, green:0.906, blue:0.906, alpha:1)
        }
    }
}
