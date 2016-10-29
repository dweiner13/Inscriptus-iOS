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
    static func preferredFontForTextStyle(_ style: String, scaleFactor scale: CGFloat) -> UIFont {
        let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: UIFontTextStyle(rawValue: style))
        let pointSize = descriptor.pointSize * scale
        return UIFont(descriptor: descriptor, size: pointSize)
    }
    
    // Lets us use Dynamic Type font sizes for custom fonts. Uses UIFontTextStyleBody for
    // point size calculation.
    static func preferredFontForFontName(_ name: String, scaleFactor scale: CGFloat) -> UIFont {
        let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: UIFontTextStyle.body)
        let pointSize = descriptor.pointSize * scale
        return UIFont(name: name, size: pointSize)!
    }
}
