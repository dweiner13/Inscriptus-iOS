//
//  DetailHeaderView.swift
//  
//
//  Created by Daniel A. Weiner on 5/2/15.
//
//

import UIKit

enum DetailHeaderViewState {
    case Default, Loading
}

class DetailHeaderView: UIView {
    
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var lookupButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var currentState: DetailHeaderViewState = .Default {
        didSet {
            switch self.currentState {
            case .Default:
                self.activityIndicator.hidden = true
                self.activityIndicator.stopAnimating()
                self.lookupButton.hidden = false
            case .Loading:
                self.activityIndicator.hidden = false
                self.activityIndicator.startAnimating()
                self.lookupButton.hidden = true
            }
        }
    }
    
    weak var buttonDelegate: DetailHeaderViewDelegate?
    
    override func awakeFromNib() {
        self.textLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline, scaleFactor: 1.15)
        
        self.activityIndicator.hidden = true
    }
    
    @IBAction func lookupButtonPressed(sender: UIButton) {
        println("Button press in DetailHeaderView")
        self.buttonDelegate?.detailHeaderView(self,
            lookupButtonPressed: sender, label: self.textLabel)
    }
}

protocol DetailHeaderViewDelegate: class {
    
    func detailHeaderView(headerView: DetailHeaderView, lookupButtonPressed button: UIButton, label: UILabel)
    
}