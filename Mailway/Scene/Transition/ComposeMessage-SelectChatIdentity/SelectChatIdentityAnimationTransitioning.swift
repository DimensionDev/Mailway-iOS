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
        case .push:     pushTransition(using: transitionContext).startAnimation()
        case .pop:      popTransition(using: transitionContext).startAnimation()
        default:        return
        }
    }
    
    private func pushTransition(using transitionContext: UIViewControllerContextTransitioning, curve: UIView.AnimationCurve = .easeInOut) -> UIViewPropertyAnimator {
        guard let navigationController = transitionContext.viewController(forKey: .from) as? UINavigationController else {
            fatalError()
        }
        
        guard let toView = transitionContext.view(forKey: .to) else {
            fatalError()
        }
        
        let containerView = transitionContext.containerView
        containerView.addSubview(toView)
        
        transitionContext.completeTransition(true)
        
        let animator = UIViewPropertyAnimator(duration: transitionDuration(using: transitionContext), curve: curve)
        return animator
    }
    
    private func popTransition(using transitionContext: UIViewControllerContextTransitioning, curve: UIView.AnimationCurve = .easeInOut) -> UIViewPropertyAnimator {
        fatalError()
    }
    
}
