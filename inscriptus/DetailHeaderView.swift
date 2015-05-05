//
//  DetailHeaderView.swift
//  
//
//  Created by Daniel A. Weiner on 5/2/15.
//
//

import UIKit

class DetailHeaderView: UIView {
    
    @IBOutlet weak var textLabel: UILabel!
    
    override func awakeFromNib() {
        self.textLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline, scaleFactor: 1.15)
    }

}
