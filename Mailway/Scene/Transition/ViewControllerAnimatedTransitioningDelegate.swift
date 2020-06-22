//
//  ViewControllerAnimatedTransitioningDelegate.swift
//  Mailway
//
//  Created by Cirno MainasuK on 12/21/18.
//  Copyright © 2018 Sujitech. All rights reserved.
//

import Foundation

protocol ViewControllerAnimatedTransitioningDelegate: class {
    var wantsInteractiveStart: Bool { get }
    func animationEnded(_ transitionCompleted: Bool)
}
