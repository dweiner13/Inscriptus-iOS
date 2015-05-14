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

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setAbbreviation(abbreviation: Abbreviation, searchController: UISearchController?) {
        var inSearch = false
        if searchController != nil {
            inSearch = searchController!.active && count(searchController!.searchBar.text) != 0
        }
        if let displayText = abbreviation.displayText {
            self.primaryLabel.text = displayText
            self.rightImageView.image = nil
        }
        else {
            self.primaryLabel.text = nil
            if let displayImage = abbreviation.displayImage {
                let image = UIImage(contentsOfFile: NSBundle.mainBundle().pathForResource(displayImage, ofType: ".png")!)!
                let scalingFactor = self.rightImageView.frame.height / image.size.height
                self.rightImageViewWidthConstraint.constant = image.size.width * scalingFactor
                self.rightImageView.image = image
            }
        }
        // highlight match if searching full text
        if inSearch && searchController!.searchBar.selectedScopeButtonIndex == MasterViewController.searchScopeIndexFulltext {
            // Done to get an NSRange instead of Swift Range. Attributed strings need NSRange.
            let longTextNS = abbreviation.longText as NSString
            let matchedRange = longTextNS.rangeOfString(searchController!.searchBar.text, options: .CaseInsensitiveSearch)
            
            let attrString = NSMutableAttributedString(string: abbreviation.longText)
            let attrs: [NSObject: AnyObject] = [
                NSBackgroundColorAttributeName: searchMatchBackgroundColor,
                NSUnderlineStyleAttributeName:  NSUnderlineStyle.StyleThick.rawValue,
                NSUnderlineColorAttributeName:  searchMatchUnderlineColor,
            ]
            attrString.addAttributes(attrs, range: matchedRange)
            
            self.secondaryLabel.attributedText = NSAttributedString(attributedString: attrString);
        }
        else {
            self.secondaryLabel.text = abbreviation.longText;
        }
        
        if AbbreviationCollection.sharedAbbreviationCollection.favorites.containsObject(abbreviation) {
            self.favoritedFlag.hidden = false
        }
        else {
            self.favoritedFlag.hidden = true
        }
    }
}
