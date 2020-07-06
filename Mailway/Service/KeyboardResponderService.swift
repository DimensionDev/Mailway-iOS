//
//  KeyboardResponderService.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-7-6.
//  Copyright © 2020 Dimension. All rights reserved.
//

import UIKit
import Combine

final class KeyboardResponderService {
    
    var disposeBag = Set<AnyCancellable>()
    
    // MARK: - Singleton
    public static let shared = KeyboardResponderService()
    
    // output
    let isShow = CurrentValueSubject<Bool, Never>(false)
    let state = CurrentValueSubject<KeyboardState, Never>(.none)
    let endFrame = CurrentValueSubject<CGRect, Never>(.zero)
    
    private init() {
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification, object: nil)
            .sink { notification in
                self.isShow.value = true
            }
            .store(in: &disposeBag)
        
        NotificationCenter.default.publisher(for: UIResponder.keyboardDidHideNotification, object: nil)
            .sink { notification in
                guard let endFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
                    return
                }

                guard endFrame.height == 0.0 else {
                    return
                }
                
                self.isShow.value = false
            }
            .store(in: &disposeBag)
        
        NotificationCenter.default.publisher(for: UIResponder.keyboardDidChangeFrameNotification, object: nil)
            .sink { notification in
                guard let isLocal = notification.userInfo?[UIWindow.keyboardIsLocalUserInfoKey] as? Bool,
                let endFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
                    return
                }
                
                self.endFrame.value = endFrame
                
                guard isLocal else {
                    self.state.value = .notLocal
                    return
                }
                
                // check if floating
                guard endFrame.width == UIScreen.main.bounds.width else {
                    self.state.value = .floating
                    return
                }
                
                // check if undock | split
                let dockMinY = UIScreen.main.bounds.height - endFrame.height
                if endFrame.minY < dockMinY {
                    self.state.value = .notDock
                } else {
                    self.state.value = .dock
                }
            }
            .store(in: &disposeBag)
    }

}

extension KeyboardResponderService {
    enum KeyboardState {
        case none
        case notLocal
        case notDock        // undock | split
        case floating       // iPhone size floating
        case dock
    }
}
