//
//  NCListCollectionLayout.swift
//  N Clipboard
//
//  Created by poor branson on 2020/5/14.
//  Copyright © 2020 poor-branson. All rights reserved.
//

import Cocoa

class NCListCollectionLayout: NSCollectionViewLayout {
    var itemHeight: CGFloat = 68
    var verticalSpacing: CGFloat = 0
    var containerPadding: NSEdgeInsets = NSEdgeInsetsZero
    
    override func prepare() {
        super.prepare()
        self.register(NCDecorationView.self, forDecorationViewOfKind: .ncItem)
    }

    override var collectionViewContentSize: NSSize {
        let count = collectionView?.numberOfItems(inSection: 0) ?? 0
        guard count > 0 else { return NSZeroSize }
        
        var size = collectionView?.superview?.bounds.size
        size?.height = CGFloat(count) * (itemHeight + verticalSpacing) - verticalSpacing + containerPadding.top + containerPadding.bottom
        
        return size ?? NSZeroSize
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> NSCollectionViewLayoutAttributes? {
        let count = collectionView?.numberOfItems(inSection: 0) ?? 0
        guard count > 0 else { return nil }
        let frame = NSMakeRect(containerPadding.left, containerPadding.top + (itemHeight + verticalSpacing) * CGFloat(indexPath.item), collectionViewContentSize.width - containerPadding.left - containerPadding.right, itemHeight)
        let attr = NSCollectionViewLayoutAttributes(forItemWith: indexPath)
        attr.frame = frame
        
        return attr
    }
    override func layoutAttributesForDecorationView(ofKind elementKind: NSCollectionView.DecorationElementKind, at indexPath: IndexPath) -> NSCollectionViewLayoutAttributes? {
        if let itemFrame = layoutAttributesForItem(at: indexPath)?.frame {
            var frame = itemFrame
            let attr = NSCollectionViewLayoutAttributes(forDecorationViewOfKind: .ncItem, with: indexPath)
            frame.origin.y = frame.size.height * CGFloat(indexPath.item + 1)
            frame.size.height = 1
            attr.frame = frame
            
            return attr
        }
        
        return nil
    }
    // assume a list only have one section
    override func layoutAttributesForElements(in rect: NSRect) -> [NSCollectionViewLayoutAttributes] {
        let count = collectionView?.numberOfItems(inSection: 0) ?? 0
        var attrs = [NSCollectionViewLayoutAttributes]()
        
        guard count > 0 else { return attrs }
        
        for index in 0 ..< count {
            let indexPath = IndexPath(item: index, section: 0)

            if let attr = layoutAttributesForItem(at: indexPath) {
                attrs.append(attr)
            }
            if let attr = layoutAttributesForDecorationView(ofKind: .ncItem, at: indexPath) {
                attrs.append(attr)
            }
        }
        
        return attrs
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: NSRect) -> Bool {
        true
    }
}
