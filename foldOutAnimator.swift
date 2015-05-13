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
        var presenting: UIViewController = self.presenting ? transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)! : transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        var presented: UIViewController = self.presenting ? transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)! : transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        
        // Extra margin above the presented view
        let topMargin: CGFloat = 20
        
//        let appFrame = UIScreen.mainScreen().applicationFrame
//        let appWidth = appFrame.width
//        let appHeight = appFrame.height
//        
        let screenFrame = UIScreen.mainScreen().bounds
//        let screenWidth = screenFrame.width
//        let screenHeight = screenFrame.height
        
        let viewFrame = presenting.view.frame
        let viewWidth = viewFrame.width
        let viewHeight = viewFrame.height
        
        var startFrame = CGRect(x: 0, y: viewHeight, width: viewWidth, height: viewHeight - foldOutBelowRect.height - topMargin)
        
        println("screenFrame\t\t \(screenFrame)")
        println("startFrame\t\t\t \(startFrame)")
        println("viewFrame\t\t\t \(viewFrame)")
        println("foldOutBelowRect\t \(foldOutBelowRect)")
        
        var statusBarBackground = UIView(frame: CGRect(x: 0, y: -20, width: viewWidth, height: 20))
        statusBarBackground.backgroundColor = UIColor.whiteColor()
        statusBarBackground.alpha = 0
        
        if (self.presenting) {
            presented.view.frame = startFrame
            
            let shadowPath = UIBezierPath(rect: presented.view.bounds)
            var layer = presented.view.layer
            layer.masksToBounds = false
            layer.shadowColor = UIColor.blackColor().CGColor
            layer.shadowOffset = CGSize(width: 0, height: 0)
            layer.shadowOpacity = 0.5
            layer.shadowPath = shadowPath.CGPath
            layer.shadowRadius = 5
            
            transitionContext.containerView().addSubview(presented.view)
            transitionContext.containerView().addSubview(statusBarBackground)
            
            UIView.animateWithDuration(self.transitionDuration(transitionContext),
                delay: 0,
                options: .CurveEaseOut,
                animations: {
                    () in
                    presenting.view.transform = CGAffineTransformMakeTranslation(0, -(self.foldOutBelowRect.minY - topMargin))
                    presented.view.transform = CGAffineTransformMakeTranslation(0, -(viewHeight - self.foldOutBelowRect.height - topMargin))
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
                options: .CurveEaseIn,
                animations: {
                    () in
                    statusBarBackground.transform = CGAffineTransformMakeTranslation(0, 0)
                    statusBarBackground.alpha = 0
                    presented.view.transform = CGAffineTransformMakeTranslation(0, 0)
                    presenting.view.transform = CGAffineTransformMakeTranslation(0, 0)
                }, completion: {
                   (b) in
                    transitionContext.completeTransition(true)
            })
        }
    }
    
}
