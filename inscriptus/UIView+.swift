//
//  UIView+.swift
//  inscriptus
//
//  Created by Daniel A. Weiner on 5/15/15.
//  Copyright (c) 2015 Daniel Weiner. All rights reserved.
//

import UIKit

extension UIView {
    func animateBounce(totalDuration: NSTimeInterval, minScale: CGFloat, maxScale: CGFloat) {
        let firstDur = totalDuration * 0.2
        let dur = totalDuration * 0.4
        UIView.animateWithDuration(dur, animations: {
            () -> Void in
            self.transform = CGAffineTransformMakeScale(minScale, minScale)
        }, completion: {
            (b) -> Void in
            UIView.animateWithDuration(dur, animations: {
                self.transform = CGAffineTransformMakeScale(maxScale, maxScale)
            }, completion: {
                (b) -> Void in
                UIView.animateWithDuration(dur, animations: {
                    self.transform = CGAffineTransformMakeScale(1, 1)
                })
            })
        })
    }
}
