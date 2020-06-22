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
    var transitionController: MainTabTransitionController? { get }
}

protocol SidebarTransitionableViewController: UIViewController {
    
}

final class MainTabTransitionController: NSObject {
    
    enum TransitionType {
        case pushToSidebar
        case popFromSidebar
    }
    
    weak var navigationController: UINavigationController?
    
    private var panGestureRecognizer = UIPanGestureRecognizer()
    private(set) var transitionType: TransitionType?
    private var interactiveTransitioning: UIViewControllerInteractiveTransitioning?
    
    var wantsInteractive = false
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        super.init()
        
        panGestureRecognizer.delegate = self
        panGestureRecognizer.maximumNumberOfTouches = 1
        panGestureRecognizer.addTarget(self, action: #selector(MainTabTransitionController.pan(_:)))
        navigationController.view.addGestureRecognizer(panGestureRecognizer)
        
        if let interactivePopGestureRecognizer = navigationController.interactivePopGestureRecognizer {
            panGestureRecognizer.require(toFail: interactivePopGestureRecognizer)
        }
    }
    
    deinit {
        os_log("%{public}s[%{public}ld], %{public}s", ((#file as NSString).lastPathComponent), #line, #function)
        panGestureRecognizer.removeTarget(nil, action: nil)
    }
    
}

extension MainTabTransitionController {
    
    @objc private func pan(_ sender: UIPanGestureRecognizer) {
        #if PREVIEW
        os_log("%{public}s[%{public}ld], %{public}s: sender: %s", ((#file as NSString).lastPathComponent), #line, #function, sender.debugDescription)
        #endif

        guard let transitionType = transitionType else { return }
        guard sender.state == .began else { return }
        
        // check transition is not on the fly
        guard interactiveTransitioning == nil else {
            return
        }
        
        switch transitionType {
        case .pushToSidebar:
            let viewController = SidebarViewController()
            wantsInteractive = true
            navigationController?.pushViewController(viewController, animated: true)
            
        case .popFromSidebar:
            wantsInteractive = true
            navigationController?.popViewController(animated: true)
            
        }
    }

}

// MARK: - UIGestureRecognizerDelegate
extension MainTabTransitionController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        #if PREVIEW
        os_log("%{public}s[%{public}ld], %{public}s: gestureRecognizer %s, otherGestureRecognizer: %s ", ((#file as NSString).lastPathComponent), #line, #function, gestureRecognizer.debugDescription, otherGestureRecognizer.debugDescription)
        #endif
        
        if navigationController?.topViewController is MainTabTransitionableViewController {
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
        os_log("%{public}s[%{public}ld], %{public}s: gestureRecognizer: %s", ((#file as NSString).lastPathComponent), #line, #function, gestureRecognizer.debugDescription)
        #endif
        
        if gestureRecognizer == navigationController?.interactivePopGestureRecognizer ||
           gestureRecognizer is UIScreenEdgePanGestureRecognizer {
            return true
        }
        
        // allow non-transitioning gesture recognizer
        guard gestureRecognizer === panGestureRecognizer else {
            return true
        }
        
        // interrupt if possiable
        if let _ = interactiveTransitioning as? SidebarAnimatedTransitioning {
            return wantsInteractive
        }
        
        // check translation direction
        let translation = panGestureRecognizer.translation(in: panGestureRecognizer.view)
        let isTranslationHorizontal = (abs(translation.x) > abs(translation.y))
        
        if isTranslationHorizontal {
            if navigationController?.topViewController is MainTabTransitionableViewController, translation.x > 0 {
                transitionType = .pushToSidebar
                return true
            }
            
            if navigationController?.topViewController is SidebarTransitionableViewController, translation.x < 0 {
                transitionType = .popFromSidebar
                return true
            }
        }
        
        transitionType = nil
        return false
    }
}

// MARK: - UINavigationControllerDelegate
extension MainTabTransitionController: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch operation {
        case .push where fromVC is MainTabTransitionableViewController && toVC is SidebarTransitionableViewController:
            return SidebarAnimatedTransitioning(operation: operation, panGestureRecognizer: panGestureRecognizer)
        case .pop where fromVC is SidebarTransitionableViewController && toVC is MainTabTransitionableViewController:
            return SidebarAnimatedTransitioning(operation: operation, panGestureRecognizer: panGestureRecognizer)
        default:
            return nil
        }
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


