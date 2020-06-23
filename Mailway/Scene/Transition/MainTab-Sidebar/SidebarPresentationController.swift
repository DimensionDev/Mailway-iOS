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
        view.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
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
        
        guard let splitViewController = presentingViewController as? UISplitViewController,
        let primaryViewController = splitViewController.viewControllers.first else {
            assertionFailure()
            return
        }
        
        overrideTraitCollection = primaryViewController.traitCollection
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
