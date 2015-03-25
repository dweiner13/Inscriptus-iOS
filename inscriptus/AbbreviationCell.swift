//
//  AbbreviationCell.swift
//  inscriptus
//
//  Created by Daniel A. Weiner on 2/20/15.
//  Copyright (c) 2015 Daniel Weiner. All rights reserved.
//

import UIKit

class AbbreviationCell: UITableViewCell {
    
    @IBOutlet weak var rightImageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var primaryLabel: UILabel!
    @IBOutlet weak var secondaryLabel: UILabel!
    @IBOutlet weak var rightImageView: UIImageView!
    
    var abbreviation: Abbreviation?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setAbbreviation(abbreviation: Abbreviation, searchController: UISearchController?) {
        let inSearch = searchController != nil && searchController!.active && count(searchController!.searchBar.text) != 0
        if let displayText = abbreviation.displayText {
            // highlight match if searching abbreviation text
            if inSearch && searchController!.searchBar.selectedScopeButtonIndex == MasterViewController.searchScopeIndexAbbreviation {
                let displayTextNS = displayText as NSString
                // Done to get an NSRange instead of Swift Range. Attributed strings need NSRange.
                var matchedRange = displayTextNS.rangeOfString(searchController!.searchBar.text, options: .CaseInsensitiveSearch)
                
                // If not found, then it's because display text has interpuncts
                if matchedRange.location == NSNotFound {
                    println(displayTextNS)
                    println(searchController!.searchBar.text)
                    matchedRange = abbreviation.rangeOfDisplayTextMatchingSearchText(searchController!.searchBar.text)!
                }
                let attrString = NSMutableAttributedString(string: displayText)
                attrString.addAttribute(NSBackgroundColorAttributeName, value: searchMatchHighlightColor, range:matchedRange)
                
                self.primaryLabel.attributedText = NSAttributedString(attributedString: attrString)
            }
            else {
                self.primaryLabel.text = displayText
            }
            self.rightImageView.image = nil
        }
        else {
//            self.primaryLabel.text = "[searchableText: \(abbreviation.searchableText)]"
            self.primaryLabel.text = nil
            if let displayImage = abbreviation.displayImage {
                let image = UIImage(contentsOfFile: displayImage)!
                let scalingFactor = self.rightImageView.frame.height / image.size.height
                self.rightImageViewWidthConstraint.constant = image.size.width * scalingFactor
                self.rightImageView.image = image
            }
        }
        // highlight match if searching full text
        if inSearch && searchController!.searchBar.selectedScopeButtonIndex == MasterViewController.searchScopeIndexFulltext {
            // Done to get an NSRange instead of Swift Range. Attributed strings need NSRange.
            let longTextNS = abbreviation.longText as NSString
            let matchedRange = longTextNS.rangeOfString(searchController!.searchBar.text)
            
            let attrString = NSMutableAttributedString(string: abbreviation.longText)
            attrString.addAttribute(NSBackgroundColorAttributeName, value: searchMatchHighlightColor, range: matchedRange)
            
            self.secondaryLabel.attributedText = NSAttributedString(attributedString: attrString);
        }
        else {
            self.secondaryLabel.text = abbreviation.longText;
        }
    }
}
