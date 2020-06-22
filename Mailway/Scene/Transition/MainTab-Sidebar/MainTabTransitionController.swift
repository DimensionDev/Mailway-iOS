//
//  MainTabTransitionController.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-6-22.
//  Copyright © 2020 Dimension. All rights reserved.
//

import os
import UIKit

protocol MainTabTransitionableViewController: UIViewController {
    var transitionController: MainTabTransitionController! { get }
}

protocol SidebarTransitionableViewController: UIViewController {
    
}

final class MainTabTransitionController: UIPercentDrivenInteractiveTransition {
    
    enum TransitionType {
        case presentationSidebar
        case dismissSidebar
    }
    
//    var interactionInProgress = false
//    private var shouldCompleteTransition = false
    
    weak var viewController: UIViewController?
    
    private var panGestureRecognizer = UIPanGestureRecognizer()
//    private(set) var transitionType: TransitionType?
//    private var interactiveTransitioning: UIViewControllerInteractiveTransitioning?
    
//    var wantsInteractive = false
    
    init(viewController: UIViewController) {
        self.viewController = viewController
        super.init()
        
        viewController.transitioningDelegate = self
        
//        panGestureRecognizer.delegate = self
//        panGestureRecognizer.maximumNumberOfTouches = 1
//        panGestureRecognizer.addTarget(self, action: #selector(MainTabTransitionController.pan(_:)))
//        viewController.view.addGestureRecognizer(panGestureRecognizer)
        
//        if let interactivePopGestureRecognizer = viewController.navigationController?.interactivePopGestureRecognizer {
//            panGestureRecognizer.require(toFail: interactivePopGestureRecognizer)
//        }
    }
    
    deinit {
        os_log("%{public}s[%{public}ld], %{public}s", ((#file as NSString).lastPathComponent), #line, #function)
//        panGestureRecognizer.removeTarget(nil, action: nil)
    }
    
}

// MARK: - UIViewControllerTransitioningDelegate
extension MainTabTransitionController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SidebarAnimatedTransitioning(operation: .push, panGestureRecognizer: panGestureRecognizer)
    }
    
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return nil
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return nil
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return nil
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return SidebarPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
}

final class SidebarPresentationController: UIPresentationController {
    let dimmingView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
        return view
    }()
    
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let splitViewController = presentingViewController as? UISplitViewController,
        let primaryViewController = splitViewController.viewControllers.first else {
            return presentingViewController.view.bounds
        }
        
        return CGRect(x: 0,
                      y: 0,
                      width: primaryViewController.view.bounds.width - 40,      // fixed 40pt margin
                      height: primaryViewController.view.bounds.height)
    }
    
    override func presentationTransitionWillBegin() {
        dimmingView.frame = containerView!.bounds
        dimmingView.alpha = 0.0
        containerView!.insertSubview(dimmingView, at: 0)
        
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { context in
            self.dimmingView.alpha = 1.0
        }, completion: nil)
    }
    
    override func dismissalTransitionWillBegin() {
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { context in
            self.dimmingView.alpha = 0.0
        }, completion: { context in
            self.dimmingView.removeFromSuperview()
        })
    }
    
    override func containerViewWillLayoutSubviews() {
        dimmingView.frame = containerView!.bounds
        presentedView?.frame = frameOfPresentedViewInContainerView
    }
}

//extension MainTabTransitionController {
//
//    @objc private func pan(_ sender: UIPanGestureRecognizer) {
//        #if PREVIEW
//        os_log("%{public}s[%{public}ld], %{public}s: sender: %s", ((#file as NSString).lastPathComponent), #line, #function, sender.debugDescription)
//        #endif
//
//        let translation = sender.translation(in: sender.view)
//        let progress = min(max(translation.x / sender.view!.bounds.width, 0.0), 1.0)
//
//        switch sender.state {
//        case <#pattern#>:
//            <#code#>
//        default:
//            <#code#>
//        }
//
//
//        guard let transitionType = transitionType else { return }
//        guard sender.state == .began else { return }
//
//        // check transition is not on the fly
//        guard interactiveTransitioning == nil else {
//            return
//        }
//
//        switch transitionType {
//        case .pushToSidebar:
//            let viewController = SidebarViewController()
//            wantsInteractive = true
////            navigationController?.pushViewController(viewController, animated: true)
//
//        case .popFromSidebar:
//            wantsInteractive = true
////            navigationController?.popViewController(animated: true)
//
//        }
//    }
//
//}

// MARK: - UIGestureRecognizerDelegate
//extension MainTabTransitionController: UIGestureRecognizerDelegate {
//
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        #if PREVIEW
//        os_log("%{public}s[%{public}ld], %{public}s: gestureRecognizer %s, otherGestureRecognizer: %s ", ((#file as NSString).lastPathComponent), #line, #function, gestureRecognizer.debugDescription, otherGestureRecognizer.debugDescription)
//        #endif
//
//        if navigationController?.topViewController is MainTabTransitionableViewController {
//            if gestureRecognizer is UIPanGestureRecognizer, otherGestureRecognizer.view is UITableView {
//                return true
//            } else if otherGestureRecognizer is UIPanGestureRecognizer, gestureRecognizer.view is UITableView {
//                return true
//            }
//        }
//
//        if gestureRecognizer is UIPanGestureRecognizer, otherGestureRecognizer is UIPanGestureRecognizer {
//            return false
//        }
//
//        return true
//    }
//
//    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
//        #if PREVIEW
//        os_log("%{public}s[%{public}ld], %{public}s: gestureRecognizer: %s", ((#file as NSString).lastPathComponent), #line, #function, gestureRecognizer.debugDescription)
//        #endif
//
//        if gestureRecognizer == navigationController?.interactivePopGestureRecognizer ||
//           gestureRecognizer is UIScreenEdgePanGestureRecognizer {
//            return true
//        }
//
//        // allow non-transitioning gesture recognizer
//        guard gestureRecognizer === panGestureRecognizer else {
//            return true
//        }
//
//        // interrupt if possiable
//        if let _ = interactiveTransitioning as? SidebarAnimatedTransitioning {
//            return wantsInteractive
//        }
//
//        // check translation direction
//        let translation = panGestureRecognizer.translation(in: panGestureRecognizer.view)
//        let isTranslationHorizontal = (abs(translation.x) > abs(translation.y))
//
//        if isTranslationHorizontal {
//            if navigationController?.topViewController is MainTabTransitionableViewController, translation.x > 0 {
//                transitionType = .pushToSidebar
//                return true
//            }
//
//            if navigationController?.topViewController is SidebarTransitionableViewController, translation.x < 0 {
//                transitionType = .popFromSidebar
//                return true
//            }
//        }
//
//        transitionType = nil
//        return false
//    }
//}

//// MARK: - UINavigationControllerDelegate
//extension MainTabTransitionController: UINavigationControllerDelegate {
//    
//    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        switch operation {
//        case .push where fromVC is MainTabTransitionableViewController && toVC is SidebarTransitionableViewController:
//            return SidebarAnimatedTransitioning(operation: operation, panGestureRecognizer: panGestureRecognizer)
//        case .pop where fromVC is SidebarTransitionableViewController && toVC is MainTabTransitionableViewController:
//            return SidebarAnimatedTransitioning(operation: operation, panGestureRecognizer: panGestureRecognizer)
//        default:
//            return nil
//        }
//    }
//    
//}
//
//// MARK: - ViewControllerAnimatedTransitioningDelegate
//extension MainTabTransitionController: ViewControllerAnimatedTransitioningDelegate {
//    
//    var wantsInteractiveStart: Bool {
//        return wantsInteractive
//    }
//    
//    
//    func animationEnded(_ transitionCompleted: Bool) {
//        os_log("%{public}s[%{public}ld], %{public}s: %s", ((#file as NSString).lastPathComponent), #line, #function, transitionCompleted.description)
//
//        interactiveTransitioning = nil
//        wantsInteractive = false
//        transitionType = nil
//    }
//    
//}
//
//
