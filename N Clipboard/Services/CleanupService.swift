//
//  CleanupService.swift
//  N Clipboard
//
//  Created by poor branson on 2020/5/6.
//  Copyright © 2020 poor-branson. All rights reserved.
//

import Foundation
import RealmSwift

struct CleanupService {
    private static var lastCollectionDate = Date(timeIntervalSince1970: 0)
    private static let duration: TimeInterval = 60 * 60 * 5
    
    static func collect() {
        guard lastCollectionDate.timeIntervalSinceNow * -1 > duration else { return }
        lastCollectionDate = Date()
        
        let expireDuration = UserDefaults.standard.integer(forKey: Constants.Userdefaults.KeepClipBoardItemUntil)
        let expiredDate = Date(timeIntervalSinceNow: TimeInterval(-1 * 60 * 60 * 24 * expireDuration))
        
        do {
            let realm = try Realm()
            let list = realm.objects(HistoryItem.self)
            
            try realm.write {
                realm.delete(list.filter(NSPredicate(format: "updatedAt < %@", expiredDate as CVarArg)))
            }
        } catch {
            LogService.error("Fail to execute clean up operation")
        }
    }
}
