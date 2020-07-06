//
//  ComposeMessageViewController.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-7-6.
//  Copyright © 2020 Dimension. All rights reserved.
//

import UIKit
import Combine

final class ComposeMessageViewModel {
    
    var disposeBag = Set<AnyCancellable>()
    
}

final class ComposeMessageViewController: UIViewController, NeedsDependency {
    
    var disposeBag = Set<AnyCancellable>()
    weak var context: AppContext! { willSet { precondition(!isViewLoaded) } }
    weak var coordinator: SceneCoordinator! { willSet { precondition(!isViewLoaded) } }
    
    var viewModel: ComposeMessageViewModel!
    
    private lazy var closeBarButtonItem: UIBarButtonItem = {
        let item = UIBarButtonItem()
        item.image = Asset.NavigationBar.close.image
        item.tintColor = Asset.Color.Tint.barButtonItem.color
        item.target = self
        item.action = #selector(ComposeMessageViewController.closeBarButtonItemPressed(_:))
        return item
    }()
    
    private lazy var composeBarButtonItem: UIBarButtonItem = {
        let item = UIBarButtonItem()
        item.image = Asset.Communication.paperplane.image
        //item.tintColor = Asset.Color.Tint.barButtonItem.color
        item.target = self
        item.action = #selector(ComposeMessageViewController.composeBarButtonItemPressed(_:))
        return item
    }()
    
    let messageTextView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 17)
        return textView
    }()
    
}

extension ComposeMessageViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        view.backgroundColor = .systemBackground
        navigationItem.leftBarButtonItem = closeBarButtonItem
        navigationItem.rightBarButtonItem = composeBarButtonItem
        
        messageTextView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(messageTextView)
        NSLayoutConstraint.activate([
            messageTextView.topAnchor.constraint(equalTo: view.topAnchor),
            messageTextView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            view.layoutMarginsGuide.trailingAnchor.constraint(equalTo: messageTextView.trailingAnchor),
            messageTextView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        // handle keyboard overlap
        Publishers.CombineLatest3(
            KeyboardResponderService.shared.isShow.eraseToAnyPublisher(),
            KeyboardResponderService.shared.state.eraseToAnyPublisher(),
            KeyboardResponderService.shared.endFrame.eraseToAnyPublisher()
        )
        .sink(receiveValue: { isShow, state, endFrame in
            guard isShow, state == .dock else {
                self.messageTextView.contentInset.bottom = 0.0
                self.messageTextView.verticalScrollIndicatorInsets.bottom = 0.0
                return
            }
            
            // isShow AND dock state
            let textViewFrame = self.view.convert(self.messageTextView.frame, to: nil)
            let padding = textViewFrame.maxY - endFrame.minY
            guard padding > 0 else {
                self.messageTextView.contentInset.bottom = 0.0
                self.messageTextView.verticalScrollIndicatorInsets.bottom = 0.0
                return
            }
            
            self.messageTextView.contentInset.bottom = padding
            self.messageTextView.verticalScrollIndicatorInsets.bottom = padding
        })
        .store(in: &disposeBag)
    }
    
}

extension ComposeMessageViewController {
    
    @objc private func closeBarButtonItemPressed(_ sender: UIBarButtonItem) {
        
    }
    
    @objc private func composeBarButtonItemPressed(_ sender: UIBarButtonItem) {
        
    }
    
}
