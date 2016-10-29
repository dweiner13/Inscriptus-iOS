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
   
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.2
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let presenting: UIViewController = self.presenting ? transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)! : transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        let presented: UIViewController = self.presenting ? transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)! : transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        
        let viewFrame = presenting.view.frame
        let viewWidth = viewFrame.width
        let viewHeight = viewFrame.height
        
        let presentedHeight: CGFloat = 160
        let presentedMargin: CGFloat = 20
        let startFrame = CGRect(x: presentedMargin, y: (viewHeight / 2) - (presentedHeight / 2), width: viewWidth - presentedMargin * 2, height:presentedHeight)
        
        if (self.presenting) {
            presented.view.alpha = 0
            presented.view.frame = startFrame
            presented.view.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
            
            let dimmingView = UIView(frame: presenting.view.bounds)
            dimmingView.backgroundColor = UIColor.black
            dimmingView.alpha = 0
            
            let recognizer = UITapGestureRecognizer(target: presented, action: "tappedOutsideModal:")
            dimmingView.addGestureRecognizer(recognizer)
            
            let shadowPath = UIBezierPath(rect: presented.view.bounds)
            let layer = presented.view.layer
            layer.masksToBounds = false
            layer.shadowColor = UIColor.black.cgColor
            layer.shadowOffset = CGSize(width: 0, height: 0)
            layer.shadowOpacity = 0.5
            layer.shadowPath = shadowPath.cgPath
            layer.shadowRadius = 5
            
            transitionContext.containerView.addSubview(dimmingView)
            transitionContext.containerView.addSubview(presented.view)
            
            UIView.animate(withDuration: self.transitionDuration(using: transitionContext),
                delay: 0,
                options: .curveEaseOut,
                animations: {
                    () in
                    presented.view.alpha = 1
                    presented.view.transform = CGAffineTransform(scaleX: 1, y: 1)
                    presenting.view.tintAdjustmentMode = .dimmed
                    dimmingView.alpha = 0.2
                }, completion: {
                    (b) in
                    transitionContext.completeTransition(true)
            })
        }
        else {
            let dimmingView = transitionContext.containerView.subviews[0] 
            
            UIView.animate(withDuration: self.transitionDuration(using: transitionContext),
                delay: 0,
                options: .curveEaseIn,
                animations: {
                    () in
                    presented.view.alpha = 0
                    presented.view.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
                    presenting.view.tintAdjustmentMode = .automatic
                    dimmingView.alpha = 0
                }, completion: {
                   (b) in
                    transitionContext.completeTransition(true)
            })
        }
    }
    
}
