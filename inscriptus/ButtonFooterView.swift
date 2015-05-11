//
//  DetailHeaderView.swift
//  
//
//  Created by Daniel A. Weiner on 5/2/15.
//
//

import UIKit

enum ButtonFooterViewState {
    case Default, Loading
}

class ButtonFooterView: UIView {
    
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    weak var buttonDelegate: ButtonFooterViewDelegate?
    
    var currentState: DetailHeaderViewState = .Default {
        didSet {
            switch self.currentState {
            case .Default:
                self.activityIndicator.hidden = true
                self.activityIndicator.stopAnimating()
                self.button.hidden = false
            case .Loading:
                self.activityIndicator.hidden = false
                self.activityIndicator.startAnimating()
                self.button.hidden = true
            }
        }
    }
    
    override func awakeFromNib() {self.activityIndicator.hidden = true
    }
    
    @IBAction func buttonPressed(sender: UIButton) {
        println("Button press in ButtonFooterView")
        self.buttonDelegate?.buttonFooterView(self,
            buttonPressed: sender)
    }
}

protocol ButtonFooterViewDelegate: class {
    
    func buttonFooterView(footerView: ButtonFooterView, buttonPressed button: UIButton)
    
}