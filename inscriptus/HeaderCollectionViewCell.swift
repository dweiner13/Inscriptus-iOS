//
//  HeaderCollectionViewCell.swift
//  
//
//  Created by Daniel A. Weiner on 4/15/15.
//
//

import UIKit

class HeaderCollectionViewCell: TextCollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline, scaleFactor: 1.2)
    }
   
    override var text: NSString {
        get {
            return self.label.text!
        }
        set {
            self.label.text = newValue as String
            var newLabelFrame = self.label.frame
            var newContentFrame = self.contentView.frame
            let textSize = TextCollectionViewCell.sizeForContentString(text, forMaxWidth: self.maxWidth, forFont: self.font)
            newLabelFrame.size = textSize
            newContentFrame.size = textSize
            self.label.frame = newLabelFrame
            self.contentView.frame = newContentFrame
            self.label.font = self.font
        }
    }
    
}
