//
//  BizcardScannerViewController.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-7-22.
//  Copyright © 2020 Dimension. All rights reserved.
//

import os
import UIKit
import AVKit
import Combine

protocol BizcardScannerViewControllerDelegate: class {
    func bizcardScannerViewController(_ viewController: BizcardScannerViewController, didScanQRCode code: String)
}

final class BizcardScannerViewController: UIViewController, NeedsDependency {
    
    weak var context: AppContext! { willSet { precondition(!isViewLoaded) } }
    weak var coordinator: SceneCoordinator! { willSet { precondition(!isViewLoaded) } }
    
    var disposeBag = Set<AnyCancellable>()
    
    lazy var scanQRViewController = ScanQRViewController()
    lazy var scannerShapeView = ScannerShapeView()

    weak var delegate: BizcardScannerViewControllerDelegate?
}


extension BizcardScannerViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(BizcardScannerViewController.cancelBarButtonItemPressed(_:)))
        
        scanQRViewController.delegate = self
        
        addChild(scanQRViewController)
        view.addSubview(scanQRViewController.view)
        scanQRViewController.didMove(toParent: self)
        
        scanQRViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scanQRViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            scanQRViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scanQRViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scanQRViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        scannerShapeView.translatesAutoresizingMaskIntoConstraints = false
        scanQRViewController.view.addSubview(scannerShapeView)
        NSLayoutConstraint.activate([
            scannerShapeView.topAnchor.constraint(equalTo: scanQRViewController.view.topAnchor),
            scannerShapeView.leadingAnchor.constraint(equalTo: scanQRViewController.view.leadingAnchor),
            scannerShapeView.trailingAnchor.constraint(equalTo: scanQRViewController.view.trailingAnchor),
            scannerShapeView.bottomAnchor.constraint(equalTo: scanQRViewController.view.bottomAnchor),
        ])
        scannerShapeView.backgroundColor = .clear
        scannerShapeView.isUserInteractionEnabled = false
    }
    
}

extension BizcardScannerViewController {
    @objc private func cancelBarButtonItemPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - ScanQRViewControllerDelegate
extension BizcardScannerViewController: ScanQRViewControllerDelegate {
    func scanQRViewController(_ viewController: ScanQRViewController, didOutput readableObjects: [AVMetadataMachineReadableCodeObject], from connection: AVCaptureConnection) {
        os_log("%{public}s[%{public}ld], %{public}s: readableObjects: %s", ((#file as NSString).lastPathComponent), #line, #function, readableObjects.debugDescription)
        
        guard let rawCode = readableObjects.first,
        let code = viewController.previewView.videoPreviewLayer.transformedMetadataObject(for: rawCode) as? AVMetadataMachineReadableCodeObject else {
            scannerShapeView.set(corners: [])
            return
        }
        
        let corners = code.corners.map { point in
            return viewController.previewView.convert(point, to: scannerShapeView)
        }
        scannerShapeView.set(corners: corners)
        
        let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
        feedbackGenerator.impactOccurred()
        
        viewController.captureSession.stopRunning()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) { [weak self] in
            guard let `self` = self else { return }
            self.dismiss(animated: true, completion: {
                self.delegate?.bizcardScannerViewController(self, didScanQRCode: code.stringValue ?? "")
            })
        }
    }
}
