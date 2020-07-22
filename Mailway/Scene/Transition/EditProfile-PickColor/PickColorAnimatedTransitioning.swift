//
//  PickColorAnimatedTransitioning.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-7-22.
//  Copyright © 2020 Dimension. All rights reserved.
//

import os
import UIKit

// EditProfileTransitionableViewController <-> PickColorTransitionableViewController
final class PickColorAnimatedTransitioning: ViewControllerAnimatedTransitioning {
    
    private var animator: UIViewPropertyAnimator?
    
    deinit {
        os_log("%{public}s[%{public}ld], %{public}s", ((#file as NSString).lastPathComponent), #line, #function)
    }
    
}

extension PickColorAnimatedTransitioning {
    
    override func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        super.animateTransition(using: transitionContext)
        
        switch operation {
        case .push:     pushTransition(using: transitionContext).startAnimation()
        case .pop:      popTransition(using: transitionContext).startAnimation()
        default:        return
        }
    }
    
    private func pushTransition(using transitionContext: UIViewControllerContextTransitioning, curve: UIView.AnimationCurve = .easeInOut) -> UIViewPropertyAnimator {
        guard let navigationController = transitionContext.viewController(forKey: .from) as? UINavigationController else {
            fatalError()
        }
        
        guard let toVC = transitionContext.viewController(forKey: .to) as? PickColorViewController,
        let toView = transitionContext.view(forKey: .to) else {
            fatalError()
        }
        
        let containerView = transitionContext.containerView
        let modalFrame = navigationController.view.convert(navigationController.view.frame, to: nil)
        toView.frame = modalFrame
        containerView.addSubview(toView)
        
        let animator = UIViewPropertyAnimator(duration: transitionDuration(using: transitionContext), curve: curve)
        
        let offsetHeight = toVC.view.frame.height - toVC.sectionHeaderView.frame.minY
        toVC.sectionHeaderView.transform = CGAffineTransform(translationX: 0, y: offsetHeight)
        toVC.sectionHeaderShadowView.transform = CGAffineTransform(translationX: 0, y: offsetHeight)
        toVC.collectionView.transform = CGAffineTransform(translationX: 0, y: offsetHeight)
        
        toView.alpha = 0
        animator.addAnimations {
            toVC.sectionHeaderView.transform = .identity
            toVC.sectionHeaderShadowView.transform = .identity
            toVC.collectionView.transform = .identity
            toView.alpha = 1
        }
        
        animator.addCompletion { position in
            transitionContext.completeTransition(position == .end)
        }
        
        return animator
    }
    
    private func popTransition(using transitionContext: UIViewControllerContextTransitioning, curve: UIView.AnimationCurve = .easeInOut) -> UIViewPropertyAnimator {
        guard let fromVC = transitionContext.viewController(forKey: .from) as? PickColorViewController,
        let fromView = transitionContext.view(forKey: .from) else {
            fatalError()
        }
        
        let animator = UIViewPropertyAnimator(duration: transitionDuration(using: transitionContext), curve: curve)
        let offsetHeight = fromVC.view.frame.height - fromVC.sectionHeaderView.frame.minY
        
        animator.addAnimations {
            fromVC.sectionHeaderView.transform = CGAffineTransform(translationX: 0, y: offsetHeight)
            fromVC.sectionHeaderShadowView.transform = CGAffineTransform(translationX: 0, y: offsetHeight)
            fromVC.collectionView.transform = CGAffineTransform(translationX: 0, y: offsetHeight)
            fromView.alpha = 0
        }

        animator.addCompletion { position in
            transitionContext.completeTransition(position == .end)
            fromVC.sectionHeaderView.transform = CGAffineTransform(translationX: 0, y: offsetHeight)
            fromVC.sectionHeaderShadowView.transform = CGAffineTransform(translationX: 0, y: offsetHeight)
            fromVC.collectionView.transform = CGAffineTransform(translationX: 0, y: offsetHeight)
            fromView.alpha = 0
        }
                
        return animator
    }
    
}
