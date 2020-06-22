//
//  CGPoint.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-6-22.
//  Copyright © 2020 Dimension. All rights reserved.
//

import QuartzCore

extension CGPoint {
    var vector: CGVector {
        return CGVector(dx: x, dy: y)
    }
}
