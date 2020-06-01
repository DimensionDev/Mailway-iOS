//
//  NSLayoutConstraint.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-6-1.
//  Copyright © 2020 Dimension. All rights reserved.
//

import UIKit

extension NSLayoutConstraint {
    func priority(_ priority: UILayoutPriority) -> Self {
        self.priority = priority
        return self
    }
}
