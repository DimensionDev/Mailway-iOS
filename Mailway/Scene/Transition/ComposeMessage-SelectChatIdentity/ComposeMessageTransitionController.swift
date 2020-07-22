//
//  ComposeMessageTransitionController.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-7-20.
//  Copyright © 2020 Dimension. All rights reserved.
//

import os
import UIKit

protocol ComposeMessageTransitionableViewController: UIViewController { }
protocol SelectIdentityDropdownMenuTransitionableViewController: UIViewController { }

final class ComposeMessageTransitionController: NSObject {
    
    enum TransitionType {
        case presentSelectChatIdenityScene
        case dismissSelectChatIdenityScene
    }
    
    weak var composeMessageTransitionableViewController: ComposeMessageTransitionableViewController?
    weak var selectIdentityDropdownMenuTransitionableViewController: SelectIdentityDropdownMenuTransitionableViewController?
    
    private(set) var transitionType: TransitionType?
    
    private var presentationPanGestureRecognizer: UIPanGestureRecognizer = {
        let gestureRecognizer = UIPanGestureRecognizer()
        gestureRecognizer.maximumNumberOfTouches = 1
        return gestureRecognizer
    }()
    
    private var dismissalPanGestureRecognizer: UIPanGestureRecognizer = {
        let gestureRecognizer = UIPanGestureRecognizer()
        gestureRecognizer.maximumNumberOfTouches = 1
        return gestureRecognizer
    }()
    
    init(viewController: ComposeMessageTransitionableViewController) {
        self.composeMessageTransitionableViewController = viewController
    }
    
    deinit {
        os_log("%{public}s[%{public}ld], %{public}s", ((#file as NSString).lastPathComponent), #line, #function)
    }
    
}

// MARK: - UIViewControllerTransitioningDelegate
extension ComposeMessageTransitionController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let selectChatIdenittyTransitionableViewController = presented as? SelectIdentityDropdownMenuTransitionableViewController else {
            assertionFailure()
            return nil
        }
        
        self.selectIdentityDropdownMenuTransitionableViewController = selectChatIdenittyTransitionableViewController
        return SelectIdentityDropdownMenuAnimationTransitioning(operation: .push, presentationPanGestureRecognizer: presentationPanGestureRecognizer, dismissalPanGestureRecognizer: dismissalPanGestureRecognizer)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SelectIdentityDropdownMenuAnimationTransitioning(operation: .pop, presentationPanGestureRecognizer: presentationPanGestureRecognizer, dismissalPanGestureRecognizer: dismissalPanGestureRecognizer)
    }
    
}
