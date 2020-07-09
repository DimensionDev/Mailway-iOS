//
//  SidebarPresentationController.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-6-23.
//  Copyright © 2020 Dimension. All rights reserved.
//

import os
import UIKit

final class SidebarPresentationController: UIPresentationController {
    
    let dimmingView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.0, alpha: 0.2)
        return view
    }()
    
    let tapGestureRecognizer: UITapGestureRecognizer = {
        let gestureRecognizer = UITapGestureRecognizer()
        gestureRecognizer.numberOfTouchesRequired = 1
        return gestureRecognizer
    }()
    
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        
        tapGestureRecognizer.addTarget(self, action: #selector(SidebarPresentationController.tap(_:)))
        dimmingView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override var shouldPresentInFullscreen: Bool {
        return true
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let splitViewController = presentingViewController as? UISplitViewController,
        let primaryViewController = splitViewController.viewControllers.first else {
            return presentingViewController.view.bounds
        }
        
        let width = primaryViewController.view.bounds.width - 56.0    // fixed 56pt
        switch UIApplication.shared.userInterfaceLayoutDirection {
        case .rightToLeft:
            return CGRect(x: containerView!.bounds.width - width,
                          y: 0,
                          width: width,
                          height: containerView!.bounds.height)
        default:
            return CGRect(x: 0,
                          y: 0,
                          width: width,
                          height: containerView!.bounds.height)     // use container view height by pass layout delay
        }
    }
    
    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        
        dimmingView.frame = containerView!.bounds
        dimmingView.alpha = 0.0
        containerView!.insertSubview(dimmingView, at: 0)
        
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { context in
            self.dimmingView.alpha = 1.0
        }, completion: nil)
    }
    
    override func presentationTransitionDidEnd(_ completed: Bool) {
        super.presentationTransitionDidEnd(completed)
        
        // remove dimming view when abort
        if !completed {
            dimmingView.removeFromSuperview()
        }
    }
    
    override func dismissalTransitionWillBegin() {
        super.dismissalTransitionWillBegin()
        
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { context in
            self.dimmingView.alpha = 0.0
        }, completion: { context in
            if !context.isCancelled {
                self.dimmingView.removeFromSuperview()
            }
        })
    }
    
    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        
        dimmingView.frame = containerView!.bounds
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { context in
            self.presentedView?.frame = self.frameOfPresentedViewInContainerView
        }, completion: nil)
                
        guard let splitViewController = presentingViewController as? UISplitViewController,
        let primaryViewController = splitViewController.viewControllers.first else {
            assertionFailure()
            return
        }
        
        // elevate interface level
        overrideTraitCollection = UITraitCollection(traitsFrom: [
            primaryViewController.traitCollection,
            UITraitCollection(userInterfaceLevel: .elevated),
        ])
    }

}

extension SidebarPresentationController {
    @objc private func tap(_ sender: UITapGestureRecognizer) {
        guard sender === tapGestureRecognizer, sender.state == .ended else {
            return
        }
        
        presentedViewController.dismiss(animated: true, completion: nil)
    }
}
