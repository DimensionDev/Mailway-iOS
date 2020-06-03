//
//  MessageInputView.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-5-29.
//  Copyright © 2020 Dimension. All rights reserved.
//

import UIKit
import GrowingTextView

protocol MessageInputViewDelegate: class {
    func messageInputView(_ toolbar: MessageInputView, submitButtonPressed button: UIButton)
}

final class MessageInputView: UIView {
    
    static let progressViewHeight: CGFloat = 4
    
    weak var delegate: MessageInputViewDelegate?
    
    let topBorderView = UIView()
    
    let inputTextView: GrowingTextView = {
        let textView = GrowingTextView()
        
        textView.placeholder = "Message…"
        //textView.maxLength = 200
        textView.maxHeight = 200
        textView.minHeight = 34
        textView.trimWhiteSpaceWhenEndEditing = true
        // textView.placeholderColor = .textGray
        // textView.contentInset.left = 10.0
        textView.textContainer.lineFragmentPadding = 5.0
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.adjustsFontForContentSizeCategory = true
        // textView.layer.borderWidth = 1
        // textView.layer.borderColor = UIColor.textViewBorderGray.cgColor
        // textView.layer.cornerRadius = textView.minHeight * 0.5
        textView.returnKeyType = .default
        // textView.enablesReturnKeyAutomatically = true
        
        return textView
    }()
    
    let submitButton = UIButton(type: .custom)
    
    private let progressView: UIProgressView = {
        let progressView = UIProgressView(frame: .zero)
        progressView.progressViewStyle = .bar
        progressView.progressTintColor = .systemBlue
        progressView.trackTintColor = .clear
        progressView.isHidden = true
        return progressView
    }()
    
    // var progress: Float {
    //     get {
    //         return progressView.progress
    //     }
    //     set {
    //         if newValue > 0 {
    //             progressView.isHidden = false
    //             progressView.setProgress(newValue, animated: true)
    //         } else {
    //             progressView.isHidden = true
    //             progressView.setProgress(newValue, animated: false)
    //         }
    //     }
    // }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        autoresizingMask = .flexibleHeight
        backgroundColor = .white
        
        topBorderView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(topBorderView)
        NSLayoutConstraint.activate([
            topBorderView.topAnchor.constraint(equalTo: self.topAnchor),
            topBorderView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            topBorderView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            topBorderView.heightAnchor.constraint(equalToConstant: 1),
        ])
        
        progressView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(progressView)
        NSLayoutConstraint.activate([
            progressView.leadingAnchor.constraint(equalTo: leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: trailingAnchor),
            progressView.bottomAnchor.constraint(equalTo: topAnchor),
            progressView.heightAnchor.constraint(equalToConstant: MessageInputView.progressViewHeight),
        ])
        
        inputTextView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(inputTextView)
        NSLayoutConstraint.activate([
            inputTextView.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
            inputTextView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15),
            self.layoutMarginsGuide.bottomAnchor.constraint(equalTo: inputTextView.bottomAnchor, constant: 8),  // align to safe area guideline
        ])
        
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(submitButton)
        NSLayoutConstraint.activate([
            submitButton.centerYAnchor.constraint(equalTo: inputTextView.centerYAnchor),
            submitButton.leadingAnchor.constraint(equalTo: inputTextView.trailingAnchor, constant: 15),
            self.trailingAnchor.constraint(equalTo: submitButton.trailingAnchor, constant: 15),
        ])
        
        topBorderView.backgroundColor = .systemFill
        
        submitButton.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        submitButton.setTitle("Send", for: .normal)
        submitButton.setTitleColor(.black, for: .normal)
        submitButton.setTitleColor(UIColor.black.withAlphaComponent(0.5), for: .highlighted)
        submitButton.addTarget(self, action: #selector(MessageInputView.submitButtonPressed(_:)), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Ref: https://stackoverflow.com/a/46510833/3797903
    // This is needed so that the inputAccesoryView is properly sized from the auto layout constraints
    // Actual value is not important
    override var intrinsicContentSize: CGSize {
        return CGSize.zero
    }
    
    @objc func submitButtonPressed(_ sender: UIButton) {
        delegate?.messageInputView(self, submitButtonPressed: sender)
    }
    
}
