//
//  ContinaerViewController.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-5-21.
//  Copyright © 2020 Dimension. All rights reserved.
//

import os
import UIKit
import SwiftUI
import Combine

final class ContainerViewModel {
    
}

final class ContainerViewController: UIViewController {
    
    var disposeBag = Set<AnyCancellable>()
    
    let context = AppContext.shared
    private(set) lazy var mainTabBarController = MainTabBarController(context: context)

}

extension ContainerViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground

        addChild(mainTabBarController)
        view.addSubview(mainTabBarController.view)
        mainTabBarController.didMove(toParent: self)
        
        mainTabBarController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mainTabBarController.view.topAnchor.constraint(equalTo: view.topAnchor),
            mainTabBarController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mainTabBarController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mainTabBarController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
                
        #if PREVIEW
        context.documentStore.setupPreview()
        #endif
    }
    
}
