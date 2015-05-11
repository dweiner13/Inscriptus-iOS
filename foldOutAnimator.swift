//
//  smallModalAnimator.swift
//  inscriptus
//
//  Created by Daniel A. Weiner on 5/7/15.
//  Copyright (c) 2015 Daniel Weiner. All rights reserved.
//

import UIKit

class foldOutAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    var presenting: Bool
    var foldOutBelowRect: CGRect
    
    init(presenting: Bool, foldOutBelowRect rect: CGRect) {
        self.presenting = presenting
        self.foldOutBelowRect = rect
    }
   
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return 0.3
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        var fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        var toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        
        // Extra margin above the presented view
        let extraTopMargin: CGFloat = 10
        
        let appFrame = UIScreen.mainScreen().applicationFrame
        let appWidth = appFrame.width
        let appHeight = appFrame.height
        
        let screenFrame = UIScreen.mainScreen().bounds
        let screenWidth = screenFrame.width
        let screenHeight = screenFrame.height
        
        var startFrame = CGRect(x: 0, y: screenHeight, width: appWidth, height: appHeight - foldOutBelowRect.height - extraTopMargin)
        
        var statusBarBackground = UIView(frame: CGRect(x: 0, y: -20, width: appWidth, height: 20))
        statusBarBackground.backgroundColor = UIColor.whiteColor()
        statusBarBackground.alpha = 0
        
        // Displays over the presenting view controller
//        var transparentDismissButton = UIButton(frame: foldOutBelowRect)
//        transparentDismissButton.alpha = 0
        
        if (self.presenting) {
            toVC.view.frame = startFrame
            
            let shadowPath = UIBezierPath(rect: toVC.view.bounds)
            var layer = toVC.view.layer
            layer.masksToBounds = false
            layer.shadowColor = UIColor.blackColor().CGColor
            layer.shadowOffset = CGSize(width: 0, height: 0)
            layer.shadowOpacity = 0.5
            layer.shadowPath = shadowPath.CGPath
            layer.shadowRadius = 5
            
            transitionContext.containerView().addSubview(toVC.view)
            transitionContext.containerView().addSubview(statusBarBackground)
            
            UIView.animateWithDuration(self.transitionDuration(transitionContext),
                delay: 0,
                options: .CurveEaseInOut,
                animations: {
                    () in
                    fromVC.view.transform = CGAffineTransformMakeTranslation(0, -self.foldOutBelowRect.minY)
                    toVC.view.transform = CGAffineTransformMakeTranslation(0, -(appHeight - self.foldOutBelowRect.height - extraTopMargin))
                    statusBarBackground.transform = CGAffineTransformMakeTranslation(0, 20)
                    statusBarBackground.alpha = 1
                }, completion: {
                    (b) in
                    transitionContext.completeTransition(true)
            })
        }
        else {
            statusBarBackground = transitionContext.containerView().subviews[1] as! UIView
            
            UIView.animateWithDuration(self.transitionDuration(transitionContext),
                delay: 0,
                options: .CurveEaseInOut,
                animations: {
                    () in
                    statusBarBackground.transform = CGAffineTransformMakeTranslation(0, 0)
                    statusBarBackground.alpha = 0
                    fromVC.view.transform = CGAffineTransformMakeTranslation(0, 0)
                    toVC.view.transform = CGAffineTransformMakeTranslation(0, 0)
                }, completion: {
                   (b) in
                    transitionContext.completeTransition(true)
            })
        }
    }
    
}
