//
//  SelectIdentityDropdownMenuAnimationTransitioning.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-7-20.
//  Copyright © 2020 Dimension. All rights reserved.
//

import os
import UIKit

// ComposeMessageTransitionableViewController <-> SelectIdentityDropdownMenuTransitionableViewController
final class SelectIdentityDropdownMenuAnimationTransitioning: ViewControllerAnimatedTransitioning {
    
    private var animator: UIViewPropertyAnimator?
    
    deinit {
        os_log("%{public}s[%{public}ld], %{public}s", ((#file as NSString).lastPathComponent), #line, #function)
    }
    
}

extension SelectIdentityDropdownMenuAnimationTransitioning {
    
    override func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        super.animateTransition(using: transitionContext)
        
        switch operation {
        case .push:     pushTransition(using: transitionContext, curve: .easeOut).startAnimation()
        case .pop:      popTransition(using: transitionContext, curve: .easeIn).startAnimation()
        default:        return
        }
    }
    
    private func pushTransition(using transitionContext: UIViewControllerContextTransitioning, curve: UIView.AnimationCurve = .easeInOut) -> UIViewPropertyAnimator {
        guard let navigationController = transitionContext.viewController(forKey: .from) as? UINavigationController else {
            fatalError()
        }
        
        guard let toVC = transitionContext.viewController(forKey: .to) as? SelectIdentityDropdownMenuViewController,
        let toView = transitionContext.view(forKey: .to) else {
            fatalError()
        }
        
        let containerView = transitionContext.containerView
        let modalFrame = navigationController.view.convert(navigationController.view.frame, to: nil)
        toView.frame = modalFrame
        containerView.addSubview(toView)
        
        let animator = UIViewPropertyAnimator(duration: transitionDuration(using: transitionContext), curve: curve)
        
        toVC.tableView.transform = CGAffineTransform(translationX: 0, y: -modalFrame.height)
        toView.alpha = 0
        animator.addAnimations {
            toVC.tableView.transform = .identity
            toView.alpha = 1
        }
        
        animator.addCompletion { position in
            transitionContext.completeTransition(position == .end)
        }
        
        return animator
    }
    
    private func popTransition(using transitionContext: UIViewControllerContextTransitioning, curve: UIView.AnimationCurve = .easeInOut) -> UIViewPropertyAnimator {
        guard let fromVC = transitionContext.viewController(forKey: .from) as? SelectIdentityDropdownMenuViewController,
        let fromView = transitionContext.view(forKey: .from) else {
            fatalError()
        }
        
        let animator = UIViewPropertyAnimator(duration: transitionDuration(using: transitionContext), curve: curve)
        
        animator.addAnimations {
            fromVC.tableView.transform = CGAffineTransform(translationX: 0, y: -fromView.frame.height)
            fromView.alpha = 0
        }
        
        animator.addCompletion { position in
            transitionContext.completeTransition(position == .end)
            fromVC.tableView.transform = CGAffineTransform(translationX: 0, y: -fromView.frame.height)
            fromView.alpha = 0
        }
        
        return animator
    }
    
}
