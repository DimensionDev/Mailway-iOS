//
//  AutoFocusTextField.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-5-21.
//  Copyright © 2020 Dimension. All rights reserved.
//

import SwiftUI
import Combine

struct AutoFocusTextField: UIViewRepresentable {
    
    @Binding var text: String
    
    var didBecomeFirstResponder = false
    var placeholder = ""
    
    class Coordinator: NSObject, UITextFieldDelegate {
        var disposeBag = Set<AnyCancellable>()
        var parent: AutoFocusTextField
        
        init(_ parent: AutoFocusTextField) {
            self.parent = parent
        }
        
        func setup(_ textField: UITextField) {
            NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: textField)
                .compactMap { notification in
                    let textField = notification.object as? UITextField
                    return textField?.text
            }
            .assign(to: \.text, on: parent)
            .store(in: &disposeBag)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        context.coordinator.setup(textField)
        return textField
    }
    
    func updateUIView(_ textField: UITextField, context: Context) {
        guard !didBecomeFirstResponder else { return }
        textField.becomeFirstResponder()
    }
    
}
