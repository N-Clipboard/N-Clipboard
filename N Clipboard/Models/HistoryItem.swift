//
//  RecordableItem.swift
//  N Clipboard
//
//  Created by poor branson on 2020/5/1.
//  Copyright © 2020 poor-branson. All rights reserved.
//

import RealmSwift
import BlobStorage

class HistoryItem: Object, HistoryProtocol, Identifiable {
    // store as text to query conveniently
    @objc dynamic var content: String = ""
    @objc dynamic var createdAt: Date = Date()
    @objc dynamic var updatedAt: Date = Date()
    // 1 for clip item
    //    2 for snippets
    @objc dynamic var entityType: Int = 1
    // clip item source,
    @objc dynamic var bundleIdentifier: String?
    @objc dynamic var title: String = ""
    @objc dynamic var blobSize: Int = 0
    @objc dynamic var isMarked: Bool = false
    @objc dynamic var blobID: String?
    @objc dynamic var thumbnail: Data?
    @objc private dynamic var pasteboardTypeIndex: String?
    var pasteboardType: NSPasteboard.PasteboardType? {
        get {
            pasteboardTypeIndex != nil ? NSPasteboard.PasteboardType(pasteboardTypeIndex!) : nil
        }
        set {
            pasteboardTypeIndex = newValue?.rawValue
        }
    }
    var fileURL: URL? {
        if let t = pasteboardType, t == .fileURL {
            return URL(fileURLWithPath: content)
        }
        
        return nil
    }
    
    typealias ID = Date
    
    var id: Date { createdAt }
    
    convenience init(content: String) {
        self.init()
        self.content = content
    }
}

extension HistoryItem: NSPasteboardWriting {
    func writableTypes(for pasteboard: NSPasteboard) -> [NSPasteboard.PasteboardType] {
        if let pType = pasteboardType, pType == .png {
            return [.png]
        }
        return [.string]
    }
    
    func pasteboardPropertyList(forType type: NSPasteboard.PasteboardType) -> Any? {
//        if type == .string && contentType == NSPasteboard.PasteboardType.color.rawValue {
//            guard let color = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(content!) as? NSColor else { return nil }
//            return Utility.hexColor(color: color)
//        }
        switch type {
        case .png:
            return Utility.bs.fetch(filename: blobID!)
        default:
            break
        }
        return content
    }
    
    func writingOptions(forType type: NSPasteboard.PasteboardType, pasteboard: NSPasteboard) -> NSPasteboard.WritingOptions {
        return []
    }
}

extension HistoryItem {
    func ncDestroy() throws {
        if let blobID = blobID {
            try Utility.bs.remove(item: BlobContent(name: blobID))
        }
        let realm = try Realm()
        try realm.write {
            realm.delete(self)
        }
    }
}
