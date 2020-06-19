//
//  ShareService.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-6-4.
//  Copyright © 2020 Dimension. All rights reserved.
//

import UIKit

final class ShareService {
    
    // MARK: - Singleton
    public static let shared = ShareService()
    
    private init() { }
    
//    func share(chatMessage: ChatMessage, sender: UIViewController, sourceView: UIView?) {
//        let activityViewController = UIActivityViewController(activityItems: [chatMessage.message], applicationActivities: [])
//        activityViewController.completionWithItemsHandler = { activityType, completed, returnedItems, activityError in
//            // do nothing
//        }
//        
//        if let presenter = activityViewController.popoverPresentationController {
//            if let sourceView = sourceView {
//                presenter.sourceView = sourceView
//                presenter.sourceRect = sourceView.bounds
//            } else {
//                presenter.sourceView = sender.view
//                presenter.sourceRect = CGRect(origin: sender.view.center, size: .zero)
//                presenter.permittedArrowDirections = []
//            }
//        }
//        DispatchQueue.main.async {
//            sender.present(activityViewController, animated: true)
//        }
//    }
    
}
