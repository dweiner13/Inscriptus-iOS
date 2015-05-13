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
    
    var gradientLayer: CAGradientLayer!
    
    override func awakeFromNib() {
//        self.centerBackgroundView.layer.borderColor = UIColor(red:0.78, green:0.769, blue:0.769, alpha:1).CGColor
        //        self.centerBackgroundView.layer.borderWidth = 2
        
        var gradient = CAGradientLayer()
        gradient.frame = self.centerBackgroundView.bounds
        gradient.colors = [
            UIColor.whiteColor().CGColor,
            UIColor.grayColor().CGColor
        ]
        gradient.cornerRadius = 5
        gradient.masksToBounds = true
        self.centerBackgroundView.layer.insertSublayer(gradient, atIndex: 0)
        self.gradientLayer = gradient
    }
    
    func updateBackgroundFrame() {
        self.gradientLayer.frame = self.centerBackgroundView.bounds
    }
    
    override func setHighlighted(highlighted: Bool, animated: Bool) {
        if highlighted {
            self.gradientLayer.frame = self.centerBackgroundView.bounds
        }
        else {
            self.gradientLayer.frame = self.centerBackgroundView.bounds
        }
    }
}
