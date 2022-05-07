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
   
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let presenting: UIViewController = self.presenting ? transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)! : transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        let presented: UIViewController = self.presenting ? transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)! : transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        
        // Extra margin above the presented view
        let topMargin: CGFloat = 20
        
        let viewFrame = presenting.view.frame
        let viewWidth = viewFrame.width
        let viewHeight = viewFrame.height
        
        let startFrame = CGRect(x: 0, y: viewHeight, width: viewWidth, height: viewHeight - foldOutBelowRect.height - topMargin)
        
        var statusBarBackground = UIView(frame: CGRect(x: 0, y: -20, width: viewWidth, height: 20))
        statusBarBackground.backgroundColor = UIColor.white
        statusBarBackground.alpha = 0
        
        if (self.presenting) {
            presented.view.frame = startFrame
            
            let shadowPath = UIBezierPath(rect: presented.view.bounds)
            let layer = presented.view.layer
            layer.masksToBounds = false
            layer.shadowColor = UIColor.black.cgColor
            layer.shadowOffset = CGSize(width: 0, height: 0)
            layer.shadowOpacity = 0.5
            layer.shadowPath = shadowPath.cgPath
            layer.shadowRadius = 5
            
            // Recognizes a tap on the presenting view to dismiss the presented view
            let tapView = UIView(frame: presenting.view.bounds)
            tapView.backgroundColor = UIColor.clear
            tapView.addGestureRecognizer(UITapGestureRecognizer(target: presented, action: "tappedOutsideModal:"))
            let swipeRec = UISwipeGestureRecognizer(target: presented, action: "tappedOutsideModal:")
            swipeRec.direction = UISwipeGestureRecognizer.Direction.down
            tapView.addGestureRecognizer(swipeRec)
            
            transitionContext.containerView.addSubview(tapView)
            transitionContext.containerView.addSubview(presented.view)
            transitionContext.containerView.addSubview(statusBarBackground)
            
            UIView.animate(withDuration: self.transitionDuration(using: transitionContext),
                delay: 0,
                options: .curveEaseOut,
                animations: {
                    () in
                    presenting.view.transform = CGAffineTransform(translationX: 0, y: -(self.foldOutBelowRect.minY - topMargin))
                    presented.view.transform = CGAffineTransform(translationX: 0, y: -(viewHeight - self.foldOutBelowRect.height - topMargin))
                    statusBarBackground.transform = CGAffineTransform(translationX: 0, y: 20)
                    statusBarBackground.alpha = 1
                }, completion: {
                    (b) in
                    transitionContext.completeTransition(true)
            })
        }
        else {
            statusBarBackground = transitionContext.containerView.subviews[2] 
            
            UIView.animate(withDuration: self.transitionDuration(using: transitionContext),
                delay: 0,
                options: .curveEaseIn,
                animations: {
                    () in
                    statusBarBackground.transform = CGAffineTransform(translationX: 0, y: 0)
                    statusBarBackground.alpha = 0
                    presented.view.transform = CGAffineTransform(translationX: 0, y: 0)
                    presenting.view.transform = CGAffineTransform(translationX: 0, y: 0)
                }, completion: {
                   (b) in
                    transitionContext.completeTransition(true)
            })
        }
    }
    
}
