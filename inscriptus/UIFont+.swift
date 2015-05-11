//
//  UIFont+.swift
//  inscriptus
//
//  Created by Daniel A. Weiner on 4/20/15.
//  Copyright (c) 2015 Daniel Weiner. All rights reserved.
//

import UIKit

extension UIFont {
    
    // Lets us adjust Dynamic Type font sizes by a scale factor
    static func preferredFontForTextStyle(style: String, scaleFactor scale: CGFloat) -> UIFont {
        let descriptor = UIFontDescriptor.preferredFontDescriptorWithTextStyle(style)
        let pointSize = descriptor.pointSize * scale
        return UIFont(descriptor: descriptor, size: pointSize)
    }
    
    // Lets us use Dynamic Type font sizes for custom fonts. Uses UIFontTextStyleBody for
    // point size calculation.
    static func preferredFontForFontName(name: String, scaleFactor scale: CGFloat) -> UIFont {
        let descriptor = UIFontDescriptor.preferredFontDescriptorWithTextStyle(UIFontTextStyleBody)
        let pointSize = descriptor.pointSize * scale
        return UIFont(name: name, size: pointSize)!
    }
}