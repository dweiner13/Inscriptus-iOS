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
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    weak var buttonDelegate: DetailHeaderViewDelegate?
    
    override func awakeFromNib() {
        self.textLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline, scaleFactor: 1.15)
        
        self.activityIndicator.hidden = true
    }
    
    @IBAction func buttonPressed(sender: UIButton) {
        println("Button press in DetailHeaderView")
        self.buttonDelegate?.detailHeaderView(self, buttonPressed: button, label: self.textLabel)
    }
}

protocol DetailHeaderViewDelegate: class {
    
    func detailHeaderView(headerView: DetailHeaderView, buttonPressed button: UIButton, label: UILabel)
    
}