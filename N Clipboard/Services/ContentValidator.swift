//
//  ContentValidator.swift
//  N Clipboard
//
//  Created by poor branson on 2020/5/4.
//  Copyright © 2020 poor-branson. All rights reserved.
//

import Foundation

class ContentValidator: NSObject {
    @objc dynamic var item: HistoryItem?
    
    @objc dynamic var isURL: Bool {
        self.item?.content.range(of: #"^https?:\/\/"#, options: .regularExpression) != nil
    }
    @objc dynamic var isFileURL: Bool {
        self.item?.pasteboardType != nil ? self.item?.pasteboardType! == .fileURL : false
    }
    @objc dynamic var isImage: Bool {
        self.item?.blobID != nil
    }
    @objc dynamic var isPreviewable: Bool {
        isURL || isFileURL || isImage
    }
    
    init(_ item: HistoryItem?) {
        self.item = item
    }
    
    override class func keyPathsForValuesAffectingValue(forKey key: String) -> Set<String> {
        var keyPaths = super.keyPathsForValuesAffectingValue(forKey: key)
        if ["isURL", "isFileURL", "isPreviewable"].contains(key) {
            keyPaths.insert("item")
        }
        
        if key == "isPreviewable" {
            keyPaths.insert("isURL")
            keyPaths.insert("isFileURL")
        }
        
        return keyPaths
    }
    
    func select() {
        guard isFileURL else { return }
        NSWorkspace.shared.selectFile(item!.fileURL?.path, inFileViewerRootedAtPath: item!.fileURL!.deletingLastPathComponent().path)
    }
    
    func open() {
        guard isURL else { return }
        if let url = URL(string: item?.content ?? "") {
            NSWorkspace.shared.open(url)
        }
    }
}
