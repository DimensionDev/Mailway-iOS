//
//  SidebarAnimatedTransitioning.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-6-22.
//  Copyright © 2020 Dimension. All rights reserved.
//

import os
import UIKit

// MainTabTransitionableViewController <-> SidebarTransitionableViewController
final class SidebarAnimatedTransitioning: ViewControllerAnimatedTransitioning {
    
    private var animator: UIViewPropertyAnimator?
    
    deinit {
        os_log("%{public}s[%{public}ld], %{public}s", ((#file as NSString).lastPathComponent), #line, #function)
    }

}


// MARK: - UIViewControllerAnimatedTransitioning
extension SidebarAnimatedTransitioning {
    
    override func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        super.animateTransition(using: transitionContext)
        
        switch operation {
        case .push:     pushTransition(using: transitionContext).startAnimation()
        case .pop:      popTransition(using: transitionContext).startAnimation()
        default:        return
        }
    }
    
    private func pushTransition(using transitionContext: UIViewControllerContextTransitioning, curve: UIView.AnimationCurve = .easeInOut) -> UIViewPropertyAnimator {
        // fromVC is split view controller
        guard let toVC = transitionContext.viewController(forKey: .to) as? SidebarTransitionableViewController,
        let toView = transitionContext.view(forKey: .to) else {
            fatalError()
        }
        
        let toViewEndFrame = transitionContext.finalFrame(for: toVC)
        let toViewStartFrame = CGRect(x: toViewEndFrame.origin.x - toView.bounds.width,
                                      y: toViewEndFrame.origin.y,
                                      width: toViewEndFrame.width,
                                      height: toViewEndFrame.height)
        
        transitionContext.containerView.addSubview(toView)
        toView.frame = toViewStartFrame
        
        // fix custom presention container cause layout along with animation issue
        UIView.performWithoutAnimation {
            toView.setNeedsLayout()
            toView.layoutIfNeeded()
        }
                
        let animator = UIViewPropertyAnimator(duration: transitionDuration(using: transitionContext), curve: curve)
        
        animator.addAnimations {
            toView.frame = toViewEndFrame
        }
        
        animator.addCompletion { position in
            transitionContext.completeTransition(position == .end)
        }
        
        return animator
    }
    
    private func popTransition(using transitionContext: UIViewControllerContextTransitioning, curve: UIView.AnimationCurve = .easeInOut) -> UIViewPropertyAnimator {
        // toVC is split view controller
        guard transitionContext.viewController(forKey: .from) is SidebarTransitionableViewController,
        let fromView = transitionContext.view(forKey: .from) else {
            fatalError()
        }
        
        let fromViewStartFrame = fromView.frame
        let fromViewEndFrame = CGRect(x: fromViewStartFrame.origin.x - fromView.bounds.width,
                                      y: fromViewStartFrame.origin.y,
                                      width: fromView.bounds.width,
                                      height: fromView.bounds.height)
        
        
        let animator = UIViewPropertyAnimator(duration: transitionDuration(using: transitionContext), curve: curve)
        
        animator.addAnimations {
            fromView.frame = fromViewEndFrame
        }
        
        animator.addCompletion { position in
            transitionContext.completeTransition(position == .end)
        }
        
        return animator
    }
    
}


// MARK: - UIViewControllerInteractiveTransitioning
extension SidebarAnimatedTransitioning {
    
    override func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        super.startInteractiveTransition(transitionContext)
        
        switch operation {
        case .push:
            animator = pushTransition(using: transitionContext, curve: .linear)
            panGestureRecognizer.addTarget(self, action: #selector(SidebarAnimatedTransitioning.pan(_:)))
            
        case .pop:
            animator = popTransition(using: transitionContext, curve: .linear)
            panGestureRecognizer.addTarget(self, action: #selector(SidebarAnimatedTransitioning.pan(_:)))
            
        default:
            return
        }
    }
    
    @objc private func pan(_ sender: UIPanGestureRecognizer) {
        guard let animator = animator else { return }
        switch sender.state {
        case .began:
            animator.pauseAnimation()
            transitionContext.pauseInteractiveTransition()
        case .changed:
            let translation = sender.translation(in: transitionContext.containerView)
            let percent = animator.fractionComplete + (operation == .push ? 1.0 : -1.0) * translation.x / transitionContext.containerView.bounds.width
            animator.fractionComplete = percent
            
            transitionContext.updateInteractiveTransition(percent)
            sender.setTranslation(.zero, in: transitionContext.containerView)
            
        case .ended, .cancelled:
            let position = completionPosition(for: animator)
            position == .end ? transitionContext.finishInteractiveTransition() : transitionContext.cancelInteractiveTransition()
            
            animator.isReversed = position == .start
            animator.startAnimation()
            
        default:
            return
        }
    }
    
    private func completionPosition(for animator: UIViewPropertyAnimator) -> UIViewAnimatingPosition {
        let completionThreshold: CGFloat = 0.33
        let flickMagnitude: CGFloat = 1200 // pts/sec
        let velocity = panGestureRecognizer.velocity(in: transitionContext.containerView).vector
        let isFlick = (velocity.magnitude > flickMagnitude)
        let isFlickRight = isFlick && (velocity.dx > 0.0)
        let isFlickLeft = isFlick && (velocity.dx < 0.0)
        
        if (operation == .push && isFlickRight) || (operation == .pop && isFlickLeft) {
            return .end
        } else if (operation == .push && isFlickLeft) || (operation == .pop && isFlickRight) {
            return .start
        } else if animator.fractionComplete > completionThreshold {
            return .end
        } else {
            return .start
        }
    }
    
}
