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
    var wordsCellRect: CGRect
    
    init(presenting: Bool, wordsCellRect rect: CGRect) {
        self.presenting = presenting
        self.wordsCellRect = rect
    }
   
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return 0.2
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        var fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        var toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        
        let initialModalScale: CGFloat = 1.1
        
        let appFrame = UIScreen.mainScreen().applicationFrame
        let appWidth = appFrame.width
        let appHeight = appFrame.height
        
        let edgeInsets = UIEdgeInsets(top: 40, left: 20, bottom: 20, right: 20)
        var endFrame = CGRect(x: edgeInsets.left, y: edgeInsets.top, width: appWidth - (edgeInsets.right + edgeInsets.left), height: appHeight - (edgeInsets.top + edgeInsets.bottom));
        
        var dimView = UIView(frame: fromVC.view.frame)
        dimView.backgroundColor = UIColor.blackColor()
        dimView.alpha = 0.0
        
        if (self.presenting) {
            fromVC.view.userInteractionEnabled = false;
            
            toVC.view.frame = endFrame
            
            transitionContext.containerView().addSubview(dimView)
            transitionContext.containerView().addSubview(toVC.view)
            
            toVC.view.transform = CGAffineTransformMakeScale(initialModalScale, initialModalScale)
            toVC.view.alpha = 0.5
            
            UIView.animateWithDuration(self.transitionDuration(transitionContext),
                delay: 0,
                options: .CurveEaseIn,
                animations: {
                () in
                fromVC.view.tintAdjustmentMode = UIViewTintAdjustmentMode.Dimmed
                
                dimView.alpha = 0.5
                
                toVC.view.transform = CGAffineTransformMakeScale(1, 1)
                toVC.view.alpha = 1.0
            
                toVC.view.frame = endFrame
                }, completion: {
                (b) in
                transitionContext.completeTransition(true)
            })
        }
        else {
            toVC.view.userInteractionEnabled = true
            
            endFrame.origin.y += appHeight - edgeInsets.bottom
            
            UIView.animateWithDuration(self.transitionDuration(transitionContext), animations: {
                () in
                toVC.view.tintAdjustmentMode = UIViewTintAdjustmentMode.Automatic
                fromVC.view.transform = CGAffineTransformMakeScale(initialModalScale, initialModalScale)
                fromVC.view.alpha = 0.0
                dimView.alpha = 0.0
                }, completion: {
                (b) in
                transitionContext.completeTransition(true)
            })
        }
    }
    
}
