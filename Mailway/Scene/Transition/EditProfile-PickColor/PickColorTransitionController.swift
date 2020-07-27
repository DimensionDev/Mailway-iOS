//
//  PickColorTransitionController.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-7-22.
//  Copyright © 2020 Dimension. All rights reserved.
//

import os
import UIKit

protocol EditProfileTransitionableViewController: UIViewController { }
protocol PickColorTransitionableViewController: UIViewController { }

final class PickColorTransitionController: NSObject {
    
    enum TransitionType {
        case presentPickColor
        case dismissPickColor
    }
    
    weak var editProfileTransitionableViewController: EditProfileTransitionableViewController?
    weak var pickColorTransitionableViewController: PickColorTransitionableViewController?
    
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
    
    private(set) var transitionType: TransitionType?

    
    init(viewController: EditProfileTransitionableViewController) {
        self.editProfileTransitionableViewController = viewController
        super.init()
        
        viewController.transitioningDelegate = self
    }
    
    deinit {
        os_log("%{public}s[%{public}ld], %{public}s", ((#file as NSString).lastPathComponent), #line, #function)
    }
    
}

// MARK: - UIViewControllerTransitioningDelegate
extension PickColorTransitionController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let pickColorTransitionableViewController = presented as? PickColorTransitionableViewController else {
            assertionFailure()
            return nil
        }
        
        self.pickColorTransitionableViewController = pickColorTransitionableViewController
        return PickColorAnimatedTransitioning(operation: .push, presentationPanGestureRecognizer: presentationPanGestureRecognizer, dismissalPanGestureRecognizer: dismissalPanGestureRecognizer)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PickColorAnimatedTransitioning(operation: .pop, presentationPanGestureRecognizer: presentationPanGestureRecognizer, dismissalPanGestureRecognizer: dismissalPanGestureRecognizer)
    }
    
}
