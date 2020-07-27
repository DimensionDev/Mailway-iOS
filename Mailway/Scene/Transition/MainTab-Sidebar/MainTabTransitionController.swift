//
//  MainTabTransitionController.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-6-22.
//  Copyright © 2020 Dimension. All rights reserved.
//

import os
import UIKit

protocol MainTabTransitionableViewController: UIViewController & NeedsDependency {
    var transitionController: MainTabTransitionController! { get }
}

protocol SidebarTransitionableViewController: UIViewController {
    
}

final class MainTabTransitionController: NSObject {
    
    enum TransitionType {
        case presentSidebar
        case dismissSidebar
    }
    
//    var interactionInProgress = false
//    private var shouldCompleteTransition = false
    
    weak var viewController: MainTabTransitionableViewController?
    weak var sidebarViewController: SidebarTransitionableViewController?
    
    private var screenEdgePanGestureRecognizer: UIScreenEdgePanGestureRecognizer = {
        let gestureRecognizer = UIScreenEdgePanGestureRecognizer()
        gestureRecognizer.maximumNumberOfTouches = 1
        gestureRecognizer.edges = UIApplication.shared.userInterfaceLayoutDirection == .leftToRight ? .left : .right
        return gestureRecognizer
    }()
    
    private var panGestureRecognizer: UIPanGestureRecognizer = {
        let gestureRecognizer = UIPanGestureRecognizer()
        gestureRecognizer.maximumNumberOfTouches = 1
        return gestureRecognizer
    }()
    
    private(set) var transitionType: TransitionType?
    private var interactiveTransitioning: UIViewControllerInteractiveTransitioning?
    
    var wantsInteractive = false
    
    init(viewController: MainTabTransitionableViewController) {
        self.viewController = viewController
        super.init()
        
        viewController.transitioningDelegate = self
        
        // add to main tab view controller
        screenEdgePanGestureRecognizer.delegate = self
        screenEdgePanGestureRecognizer.addTarget(self, action: #selector(MainTabTransitionController.edgePan(_:)))
        viewController.view.addGestureRecognizer(screenEdgePanGestureRecognizer)
        if let interactivePopGestureRecognizer = viewController.navigationController?.interactivePopGestureRecognizer {
            screenEdgePanGestureRecognizer.require(toFail: interactivePopGestureRecognizer)
        }
        
        // for sidebar view controller
        panGestureRecognizer.delegate = self
        panGestureRecognizer.addTarget(self, action: #selector(MainTabTransitionController.pan(_:)))

    }
    
    deinit {
        os_log("%{public}s[%{public}ld], %{public}s", ((#file as NSString).lastPathComponent), #line, #function)
//        panGestureRecognizer.removeTarget(nil, action: nil)
    }
    
}

// MARK: - UIViewControllerTransitioningDelegate
extension MainTabTransitionController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let sidebarViewController = presented as? SidebarTransitionableViewController else {
            assertionFailure()
            return nil
        }

        self.sidebarViewController = sidebarViewController
        self.sidebarViewController?.view.addGestureRecognizer(panGestureRecognizer)
        return SidebarAnimatedTransitioning(operation: .push, presentationPanGestureRecognizer: screenEdgePanGestureRecognizer, dismissalPanGestureRecognizer: panGestureRecognizer)
    }
    
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        guard wantsInteractive else {
            return nil
        }
        
        if let transition = animator as? SidebarAnimatedTransitioning {
            transition.delegate = self
            interactiveTransitioning = transition
            return transition
        }
        
        return nil
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SidebarAnimatedTransitioning(operation: .pop, presentationPanGestureRecognizer: screenEdgePanGestureRecognizer, dismissalPanGestureRecognizer: panGestureRecognizer)
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        guard wantsInteractive else {
            return nil
        }
        
        if let transition = animator as? SidebarAnimatedTransitioning {
            transition.delegate = self
            interactiveTransitioning = transition
            return transition
        }
        
        return nil
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return SidebarPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
}

extension MainTabTransitionController {

    @objc private func edgePan(_ sender: UIPanGestureRecognizer) {
        #if PREVIEW
        // os_log("%{public}s[%{public}ld], %{public}s: sender: %s", ((#file as NSString).lastPathComponent), #line, #function, sender.debugDescription)
        #endif
        
        guard let transitionType = transitionType else { return }
        guard sender.state == .began else { return }

        // check transition is not on the fly
        guard interactiveTransitioning == nil else {
            return
        }

        switch transitionType {
        case .presentSidebar:
            wantsInteractive = true
            viewController?.coordinator.present(scene: .sidebar, from: viewController, transition: .custom(transitioningDelegate: self))

        case .dismissSidebar:
            assertionFailure()
            break
        }
    }
    
    @objc private func pan(_ sender: UIPanGestureRecognizer) {
        #if PREVIEW
        // os_log("%{public}s[%{public}ld], %{public}s: sender: %s", ((#file as NSString).lastPathComponent), #line, #function, sender.debugDescription)
        #endif
        
        guard let transitionType = transitionType else { return }
        guard sender.state == .began else { return }
        
        // check transition is not on the fly
        guard interactiveTransitioning == nil else {
            return
        }
        
        switch transitionType {
        case .presentSidebar:
            assertionFailure()
            break
        case .dismissSidebar:
            wantsInteractive = true
            sidebarViewController?.dismiss(animated: true, completion: nil)
        }
    }

}

// MARK: - UIGestureRecognizerDelegate
extension MainTabTransitionController: UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        #if PREVIEW
        // os_log("%{public}s[%{public}ld], %{public}s: gestureRecognizer %s, otherGestureRecognizer: %s ", ((#file as NSString).lastPathComponent), #line, #function, gestureRecognizer.debugDescription, otherGestureRecognizer.debugDescription)
        #endif

        if viewController?.navigationController?.topViewController is MainTabTransitionableViewController {
            if gestureRecognizer is UIPanGestureRecognizer, otherGestureRecognizer.view is UITableView {
                return true
            } else if otherGestureRecognizer is UIPanGestureRecognizer, gestureRecognizer.view is UITableView {
                return true
            }
        }

        if gestureRecognizer is UIPanGestureRecognizer, otherGestureRecognizer is UIPanGestureRecognizer {
            return false
        }

        return true
    }

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        #if PREVIEW
        // os_log("%{public}s[%{public}ld], %{public}s: gestureRecognizer: %s", ((#file as NSString).lastPathComponent), #line, #function, gestureRecognizer.debugDescription)
        #endif
        
        // allow non-transitioning gesture recognizer if needs
        guard gestureRecognizer === screenEdgePanGestureRecognizer || gestureRecognizer === panGestureRecognizer else {
            return true
        }
        
        // accept interrupt interactive
        if let _ = interactiveTransitioning as? SidebarAnimatedTransitioning {
            return wantsInteractive
        }
        
        if gestureRecognizer === screenEdgePanGestureRecognizer, viewController != nil {
            transitionType = .presentSidebar
            return true
        }
        
        if gestureRecognizer === panGestureRecognizer, sidebarViewController != nil {
            transitionType = .dismissSidebar
            return true
        }
        
        transitionType = nil
        return false
    }
    
}

// MARK: - ViewControllerAnimatedTransitioningDelegate
extension MainTabTransitionController: ViewControllerAnimatedTransitioningDelegate {
    
    var wantsInteractiveStart: Bool {
        return wantsInteractive
    }
    
    func animationEnded(_ transitionCompleted: Bool) {
        os_log("%{public}s[%{public}ld], %{public}s: %s", ((#file as NSString).lastPathComponent), #line, #function, transitionCompleted.description)

        interactiveTransitioning = nil
        wantsInteractive = false
        transitionType = nil
    }
    
}
