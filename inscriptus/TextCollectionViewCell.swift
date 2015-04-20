//
//  TextCollectionViewCell.swift
//  inscriptus
//
//  Created by Daniel A. Weiner on 4/1/15.
//  Copyright (c) 2015 Daniel Weiner. All rights reserved.
//

import UIKit

class TextCollectionViewCell: UICollectionViewCell {
    
    var label: UILabel!
    var maxWidth: CGFloat!
    
    var font: UIFont
    
    var text: NSString {
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
        }
    }
    
    override init(frame: CGRect) {
        self.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody, scaleFactor: 1.1)
        
        super.init(frame: frame)
        
        self.label = UILabel(frame: self.contentView.bounds)
        self.label.opaque = false
        self.label.backgroundColor = nil;
        
        self.label.textColor = UIColor.blackColor()
        
        self.label.textAlignment = .Center
        self.label.font = self.font
        
        self.contentView.addSubview(self.label)
        
        var selectedBackground = UIView(frame: self.contentView.bounds)
        selectedBackground.backgroundColor = UIColor.redColor()
        self.selectedBackgroundView = selectedBackground
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    static func sizeForContentString(string: NSString, forMaxWidth maxWidth: CGFloat, forFont font: UIFont) -> CGSize {
        println(font)
        
        let maxSize = CGSize(width: maxWidth, height: 1000);
        
        let opts: NSStringDrawingOptions = .UsesLineFragmentOrigin | .UsesFontLeading
        let style = NSMutableParagraphStyle();
        let attributes = [
            NSFontAttributeName: font,
            NSParagraphStyleAttributeName: style
        ]
        let rect = string.boundingRectWithSize(maxSize,
                                      options: opts,
                                   attributes: attributes,
                                      context: nil)
        return rect.size
    }
    
}
