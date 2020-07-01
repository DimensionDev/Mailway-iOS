//
//  DateFormatter.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-6-30.
//  Copyright © 2020 Dimension. All rights reserved.
//

import Foundation

extension ISO8601DateFormatter {
    static var fractionalSeconds: ISO8601DateFormatter {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions.insert(.withFractionalSeconds)
        return formatter
    }
}
