//
//  AbbreviationCell.swift
//  inscriptus
//
//  Created by Daniel A. Weiner on 2/20/15.
//  Copyright (c) 2015 Daniel Weiner. All rights reserved.
//

import UIKit

let searchMatchBackgroundColor = UIColor(red:0.984, green:0.969, blue:0.787, alpha:1)
let searchMatchUnderlineColor = UIColor(red:0.93, green:0.801, blue:0, alpha:1)

class AbbreviationCell: UITableViewCell {
    
    @IBOutlet weak var rightImageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var primaryLabel: UILabel!
    @IBOutlet weak var secondaryLabel: UILabel!
    @IBOutlet weak var rightImageView: UIImageView!
    @IBOutlet weak var favoritedFlag: UIImageView!
    
    var abbreviation: Abbreviation?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setAbbreviation(_ abbreviation: Abbreviation, searchController: UISearchController?) {
        var inSearch = false
        if searchController != nil {
            inSearch = searchController!.isActive && searchController!.searchBar.text!.count != 0
        }
        if let displayText = abbreviation.displayText {
            self.primaryLabel.text = displayText
            self.rightImageView.image = nil
        }
        else {
            self.primaryLabel.text = nil
            if let displayImage = abbreviation.displayImage {
                let image = UIImage(contentsOfFile: Bundle.main.path(forResource: displayImage, ofType: ".png")!)!
                let scalingFactor = self.rightImageView.frame.height / image.size.height
                self.rightImageViewWidthConstraint.constant = image.size.width * scalingFactor
                self.rightImageView.image = image
            }
        }
        // highlight match if searching full text
        if inSearch && searchController!.searchBar.selectedScopeButtonIndex == MasterViewController.searchScopeIndexFulltext {
            // Done to get an NSRange instead of Swift Range. Attributed strings need NSRange.
            let longTextNS = abbreviation.longText as NSString
            let matchedRange = longTextNS.range(of: searchController!.searchBar.text!, options: .caseInsensitive)
            
            let attrString = NSMutableAttributedString(string: abbreviation.longText)
            let attrs: [NSAttributedString.Key: Any] = [
                NSAttributedString.Key.backgroundColor: searchMatchBackgroundColor,
                NSAttributedString.Key.underlineStyle:  NSUnderlineStyle.thick.rawValue as AnyObject,
                NSAttributedString.Key.underlineColor:  searchMatchUnderlineColor,
            ]
            attrString.addAttributes(attrs, range: matchedRange)
            
            self.secondaryLabel.attributedText = NSAttributedString(attributedString: attrString);
        }
        else {
            self.secondaryLabel.text = abbreviation.longText;
        }
        
        if AbbreviationCollection.sharedAbbreviationCollection.favorites.contains(abbreviation) {
            self.favoritedFlag.isHidden = false
        }
        else {
            self.favoritedFlag.isHidden = true
        }
    }
}
