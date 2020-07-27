//
//  AVCaptureVideoOrientation.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-7-22.
//  Copyright © 2020 Dimension. All rights reserved.
//

import UIKit
import AVKit

extension AVCaptureVideoOrientation {
    var uiInterfaceOrientation: UIInterfaceOrientation {
        get {
            switch self {
            case .landscapeLeft:        return .landscapeLeft
            case .landscapeRight:       return .landscapeRight
            case .portrait:             return .portrait
            case .portraitUpsideDown:   return .portraitUpsideDown
            @unknown default:           return .portrait
            }
        }
    }
    
    init(orientation: UIInterfaceOrientation) {
        switch orientation {
        case .landscapeRight:       self = .landscapeRight
        case .landscapeLeft:        self = .landscapeLeft
        case .portrait:             self = .portrait
        case .portraitUpsideDown:   self = .portraitUpsideDown
        default:                    self = .portrait
        }
    }
}
