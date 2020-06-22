//
//  SidebarViewController.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-6-22.
//  Copyright © 2020 Dimension. All rights reserved.
//

import UIKit

final class SidebarViewController: UIViewController, SidebarTransitionableViewController {
    
}

extension SidebarViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemRed
        // hide navigation bar
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

}

