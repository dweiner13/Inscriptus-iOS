//
//  UIView+.swift
//  inscriptus
//
//  Created by Daniel A. Weiner on 5/15/15.
//  Copyright (c) 2015 Daniel Weiner. All rights reserved.
//

import UIKit

extension UIView {
    func animateBounce(_ totalDuration: TimeInterval, minScale: CGFloat, maxScale: CGFloat) {
        let dur = totalDuration * 0.4
        UIView.animate(withDuration: dur, animations: {
            () -> Void in
            self.transform = CGAffineTransform(scaleX: minScale, y: minScale)
        }, completion: {
            (b) -> Void in
            UIView.animate(withDuration: dur, animations: {
                self.transform = CGAffineTransform(scaleX: maxScale, y: maxScale)
            }, completion: {
                (b) -> Void in
                UIView.animate(withDuration: dur, animations: {
                    self.transform = CGAffineTransform(scaleX: 1, y: 1)
                })
            })
        })
    }
}
