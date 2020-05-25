//
//  SharedData.swift
//  N Clipboard
//
//  Created by poor branson on 2020/5/2.
//  Copyright © 2020 poor-branson. All rights reserved.
//

import SwiftUI
import RealmSwift

final class SharedData {
    var historyList = try! Realm().objects(HistoryItem.self)
    @Published var keyword: String = ""
    @Published var tappedItemDate: Date = Date()

    static var shared = SharedData()
}
