//
//  UIApplication.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-7-21.
//  Copyright © 2020 Dimension. All rights reserved.
//

import UIKit

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
