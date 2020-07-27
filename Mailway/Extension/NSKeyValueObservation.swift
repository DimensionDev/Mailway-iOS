//
//  NSKeyValueObservation.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-7-20.
//  Copyright © 2020 Dimension. All rights reserved.
//

import Foundation

extension NSKeyValueObservation {
    
    func store(in set: inout Set<NSKeyValueObservation>) {
        set.insert(self)
    }
    
}
