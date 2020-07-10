//
//  SnappingCollectionViewFlowLayout.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-7-10.
//  Copyright © 2020 Dimension. All rights reserved.
//

import UIKit

class SnappingCollectionViewLayout: UICollectionViewFlowLayout {
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView else {
            return super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
        }
        
        var offsetAdjustment = CGFloat.greatestFiniteMagnitude
        let horizontalOffset = proposedContentOffset.x + collectionView.contentInset.left
        
        let targetRect = CGRect(x: proposedContentOffset.x, y: 0, width: collectionView.bounds.size.width, height: collectionView.bounds.size.height)
        
        let layoutAttributesArray = super.layoutAttributesForElements(in: targetRect)
        
        layoutAttributesArray?.forEach({ (layoutAttributes) in
            let itemOffset = layoutAttributes.frame.origin.x
            if fabsf(Float(itemOffset - horizontalOffset)) < fabsf(Float(offsetAdjustment)) {
                offsetAdjustment = itemOffset - horizontalOffset
                
                if let delegate = collectionView.delegate as? UICollectionViewDelegateFlowLayout,
                let inset = delegate.collectionView?(collectionView, layout: collectionView.collectionViewLayout, insetForSectionAt: layoutAttributes.indexPath.section) {
                    offsetAdjustment -= inset.left
                }
            }
        })
        
        
        return CGPoint(x: proposedContentOffset.x + offsetAdjustment, y: proposedContentOffset.y)
    }
    
}
