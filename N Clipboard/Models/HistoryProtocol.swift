//
//  HistoryProtocol.swift
//  N Clipboard
//
//  Created by poor branson on 2020/5/1.
//  Copyright © 2020 poor-branson. All rights reserved.
//
import RealmSwift

protocol HistoryProtocol {
    // store as text to do query conveniently
    var content: String { get set }
    var createdAt: Date { get set }
    var updatedAt: Date { get set }
    // 1 for clip item
    // 2 for snippets
    var entityType: Int { get set }
    // item source,
    var bundleIdentifier: String? { get set }
    var title: String { get set }
    var blobSize: Int { get set }
}
