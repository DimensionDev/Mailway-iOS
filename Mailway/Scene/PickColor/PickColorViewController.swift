//
//  PickColorViewController.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-7-21.
//  Copyright © 2020 Dimension. All rights reserved.
//

import os
import UIKit
import SwiftUI
import Combine

protocol PickColorViewControllerDelegate: class {
    func pickColorViewController(_ viewController: PickColorViewController, didPickColor color: UIColor)
}

final class PickColorViewModel: NSObject {
    
    // input
    let colors: [UIColor]
    let initialSelectColor: UIColor
    
    // output
    let selectedIndexPath: CurrentValueSubject<IndexPath, Never>
    
    
    init(colors: [UIColor], initialSelectColor: UIColor) {
        self.colors = colors
        self.initialSelectColor = initialSelectColor
        
        let index = colors.firstIndex(where: { $0 == initialSelectColor }) ?? 0
        self.selectedIndexPath = CurrentValueSubject(IndexPath(item: index, section: 0))
        
        super.init()
    }
    
}

// MARK: - UICollectionViewDataSource
extension PickColorViewModel: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: PickColorItemCollectionViewCell.self), for: indexPath) as! PickColorItemCollectionViewCell
        
        let color = colors[indexPath.item]
        cell.colorWallView.backgroundColor = color
        cell.colorWallHighlightBorderView.layer.borderColor = color.cgColor
        
        self.selectedIndexPath
            .sink(receiveValue: { selectedIndexPath in
                cell.colorWallHighlightBorderView.isHidden = selectedIndexPath != indexPath
            })
            .store(in: &cell.disposeBag)
        
        return cell
    }
    
    
}

final class PickColorViewController: UIViewController, NeedsDependency, PickColorTransitionableViewController {
    
    private(set) var transitionController: MainTabTransitionController!
    
    weak var context: AppContext! { willSet { precondition(!isViewLoaded) } }
    weak var coordinator: SceneCoordinator! { willSet { precondition(!isViewLoaded) } }
    
    var viewModel: PickColorViewModel!
    weak var delegate: PickColorViewControllerDelegate?
    
    var disposeBag = Set<AnyCancellable>()
    var observations = Set<NSKeyValueObservation>()
    
    let safeAreaPaddingView = UIView()
    
    let collectionViewLayout: UICollectionViewLayout = {
        let count: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 10 : 5
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0 / count),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .fractionalWidth(1.0 / count))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                       subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12)
        return UICollectionViewCompositionalLayout(section: section)
    }()
    private(set) lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: collectionViewLayout)
        collectionView.register(PickColorItemCollectionViewCell.self, forCellWithReuseIdentifier: String(describing: PickColorItemCollectionViewCell.self))
        collectionView.isScrollEnabled = false
        collectionView.backgroundColor = .systemBackground
        return collectionView
    }()
    var collectionViewHeightLayoutConstraint: NSLayoutConstraint!
    
    let sectionHeaderView = UIView()
    let sectionHeaderShadowView = UIView()
    
    lazy var closeButton: UIButton = {
        let button = UIButton()
        button.setImage(Asset.Editing.close.image.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = .label
        button.addTarget(self, action: #selector(PickColorViewController.closeButtonPressed(_:)), for: .touchUpInside)
        return button
    }()
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.text = L10n.PickColor.title
        return label
    }()
    
    let dismissTapGestureRecognizer: UITapGestureRecognizer = {
        let tapGestureRecognizer = UITapGestureRecognizer()
        tapGestureRecognizer.numberOfTapsRequired = 1
        tapGestureRecognizer.numberOfTouchesRequired = 1
        tapGestureRecognizer.cancelsTouchesInView = false
        return tapGestureRecognizer
    }()
    
}

extension PickColorViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            view.layer.masksToBounds = true
            view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            view.layer.cornerRadius = 12
        }
        
        safeAreaPaddingView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(safeAreaPaddingView)
        NSLayoutConstraint.activate([
            view.bottomAnchor.constraint(equalTo: safeAreaPaddingView.bottomAnchor),
            view.layoutMarginsGuide.bottomAnchor.constraint(equalTo: safeAreaPaddingView.topAnchor),
            safeAreaPaddingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            safeAreaPaddingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        collectionViewHeightLayoutConstraint = collectionView.heightAnchor.constraint(greaterThanOrEqualToConstant: view.bounds.height).priority(.defaultHigh)
        NSLayoutConstraint.activate([
            safeAreaPaddingView.topAnchor.constraint(equalTo: collectionView.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionViewHeightLayoutConstraint,
        ])
        
        sectionHeaderView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(sectionHeaderView)
        NSLayoutConstraint.activate([
            sectionHeaderView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sectionHeaderView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: sectionHeaderView.bottomAnchor),
            sectionHeaderView.heightAnchor.constraint(equalToConstant: 56).priority(.defaultHigh),
        ])
        
        sectionHeaderShadowView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(sectionHeaderShadowView)
        NSLayoutConstraint.activate([
            sectionHeaderShadowView.topAnchor.constraint(equalTo: sectionHeaderView.topAnchor),
            sectionHeaderShadowView.leadingAnchor.constraint(equalTo: sectionHeaderView.leadingAnchor),
            sectionHeaderShadowView.trailingAnchor.constraint(equalTo: sectionHeaderView.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: sectionHeaderShadowView.bottomAnchor),
        ])
        view.sendSubviewToBack(sectionHeaderShadowView)
        
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        sectionHeaderView.addSubview(closeButton)
        NSLayoutConstraint.activate([
            closeButton.centerYAnchor.constraint(equalTo: sectionHeaderView.centerYAnchor),
            closeButton.leadingAnchor.constraint(equalTo: sectionHeaderView.layoutMarginsGuide.leadingAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 24),
            closeButton.heightAnchor.constraint(equalToConstant: 24),
        ])
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        sectionHeaderView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: sectionHeaderView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: sectionHeaderView.centerYAnchor),
        ])
        
        safeAreaPaddingView.backgroundColor = .systemBackground
        collectionView.backgroundColor = .systemBackground
        sectionHeaderView.backgroundColor = .systemBackground
        
        collectionView.delegate = self
        collectionView.dataSource = viewModel
        collectionView.reloadData()
        
        collectionView.observe(\.contentSize, options: [.initial, .new]) { [weak self] collectionView, change in
            guard let `self` = self else { return }
            guard self.collectionView.contentSize != .zero else { return }
            self.collectionViewHeightLayoutConstraint.constant = self.collectionView.contentSize.height
        }.store(in: &observations)
        
        view.addGestureRecognizer(dismissTapGestureRecognizer)
        dismissTapGestureRecognizer.addTarget(self, action: #selector(PickColorViewController.tapHandler(_:)))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        sectionHeaderView.layer.masksToBounds = true
        sectionHeaderView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        sectionHeaderView.layer.cornerRadius = 12
        sectionHeaderShadowView.layer.setupShadow(roundedRect: sectionHeaderShadowView.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 12, height: 12))
    }
    
}

extension PickColorViewController {
    
    @objc private func closeButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func tapHandler(_ sender: UITapGestureRecognizer) {
        guard sender === dismissTapGestureRecognizer else { return }
        
        let location = sender.location(in: view)
        guard location.y < sectionHeaderView.frame.minY else {
            return
        }
        
        dismiss(animated: true, completion: nil)
    }
    
}

// MARK: - UICollectionViewDelegate
extension PickColorViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        os_log("%{public}s[%{public}ld], %{public}s: %s", ((#file as NSString).lastPathComponent), #line, #function, indexPath.debugDescription)
        
        viewModel.selectedIndexPath.value = indexPath
        delegate?.pickColorViewController(self, didPickColor: viewModel.colors[indexPath.item])
        dismiss(animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? PickColorItemCollectionViewCell else {
            return
        }
        
        cell.colorWallView.alpha = 0.8
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? PickColorItemCollectionViewCell else {
            return
        }
        
        cell.colorWallView.alpha = 1.0
    }
    
}

#if DEBUG
struct PickColorViewController_Previews: PreviewProvider {
    static var previews: some View {
        UIViewControllerPreview {
            PickColorViewController()
        }
    }
}
#endif

