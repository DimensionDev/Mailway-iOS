//
//  ViewControllerAnimatedTransitioning.swift
//  Mailway
//
//  Created by Cirno MainasuK on 12/21/18.
//  Copyright © 2018 Sujitech. All rights reserved.
//

import os
import UIKit

class ViewControllerAnimatedTransitioning: NSObject {

    let operation: UINavigationController.Operation
    let presentationPanGestureRecognizer: UIPanGestureRecognizer
    let dismissalPanGestureRecognizer: UIPanGestureRecognizer

    var transitionContext: UIViewControllerContextTransitioning!
    var isInteractive: Bool { return transitionContext.isInteractive }

    weak var delegate: ViewControllerAnimatedTransitioningDelegate?

    init(operation: UINavigationController.Operation, presentationPanGestureRecognizer: UIPanGestureRecognizer, dismissalPanGestureRecognizer: UIPanGestureRecognizer) {
        assert(operation != .none)
        self.operation = operation
        self.presentationPanGestureRecognizer = presentationPanGestureRecognizer
        self.dismissalPanGestureRecognizer = dismissalPanGestureRecognizer
        super.init()
    }

    deinit {
        os_log("%{public}s[%{public}ld], %{public}s", ((#file as NSString).lastPathComponent), #line, #function)
    }

}

// MARK: - UIViewControllerAnimatedTransitioning
extension ViewControllerAnimatedTransitioning: UIViewControllerAnimatedTransitioning {

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
    }

    func animationEnded(_ transitionCompleted: Bool) {
        delegate?.animationEnded(transitionCompleted)
    }

}

// MARK: - UIViewControllerInteractiveTransitioning
extension ViewControllerAnimatedTransitioning: UIViewControllerInteractiveTransitioning {

    func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
    }

    var wantsInteractiveStart: Bool {
        return delegate?.wantsInteractiveStart ?? false
    }

}
