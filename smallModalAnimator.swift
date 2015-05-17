//
//  smallModalAnimator.swift
//  inscriptus
//
//  Created by Daniel A. Weiner on 5/7/15.
//  Copyright (c) 2015 Daniel Weiner. All rights reserved.
//

import UIKit

class smallModalAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    var presenting: Bool
    
    init(presenting: Bool) {
        self.presenting = presenting
    }
   
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return 0.2
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        var presenting: UIViewController = self.presenting ? transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)! : transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        var presented: UIViewController = self.presenting ? transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)! : transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        
        let viewFrame = presenting.view.frame
        let viewWidth = viewFrame.width
        let viewHeight = viewFrame.height
        
        let presentedHeight: CGFloat = 160
        let presentedMargin: CGFloat = 20
        var startFrame = CGRect(x: presentedMargin, y: (viewHeight / 2) - (presentedHeight / 2), width: viewWidth - presentedMargin * 2, height:presentedHeight)
        
        if (self.presenting) {
            presented.view.alpha = 0
            presented.view.frame = startFrame
            presented.view.transform = CGAffineTransformMakeScale(0.85, 0.85)
            
            var dimmingView = UIView(frame: presenting.view.bounds)
            dimmingView.backgroundColor = UIColor.blackColor()
            dimmingView.alpha = 0
            
            let shadowPath = UIBezierPath(rect: presented.view.bounds)
            var layer = presented.view.layer
            layer.masksToBounds = false
            layer.shadowColor = UIColor.blackColor().CGColor
            layer.shadowOffset = CGSize(width: 0, height: 0)
            layer.shadowOpacity = 0.5
            layer.shadowPath = shadowPath.CGPath
            layer.shadowRadius = 5
            
            transitionContext.containerView().addSubview(dimmingView)
            transitionContext.containerView().addSubview(presented.view)
            
            UIView.animateWithDuration(self.transitionDuration(transitionContext),
                delay: 0,
                options: .CurveEaseOut,
                animations: {
                    () in
                    presented.view.alpha = 1
                    presented.view.transform = CGAffineTransformMakeScale(1, 1)
                    presenting.view.tintAdjustmentMode = .Dimmed
                    dimmingView.alpha = 0.2
                }, completion: {
                    (b) in
                    transitionContext.completeTransition(true)
            })
        }
        else {
            let dimmingView = transitionContext.containerView().subviews[0] as! UIView
            
            UIView.animateWithDuration(self.transitionDuration(transitionContext),
                delay: 0,
                options: .CurveEaseIn,
                animations: {
                    () in
                    presented.view.alpha = 0
                    presented.view.transform = CGAffineTransformMakeScale(0.85, 0.85)
                    presenting.view.tintAdjustmentMode = .Automatic
                    dimmingView.alpha = 0
                }, completion: {
                   (b) in
                    transitionContext.completeTransition(true)
            })
        }
    }
    
}
