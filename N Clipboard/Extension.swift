//
//  Extension.swift
//  N Clipboard
//
//  Created by poor branson on 2020/5/1.
//  Copyright © 2020 poor-branson. All rights reserved.
//

import Foundation
import Preferences

extension PreferencePaneIdentifier {
    static let general = PreferencePaneIdentifier("general")
    static let rules = PreferencePaneIdentifier("rules")
    static let snippet = PreferencePaneIdentifier("snippet")
    static let appearance = PreferencePaneIdentifier("appearance")
    static let about = PreferencePaneIdentifier("about")
}

extension Date {
    func timeAgo() -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.allowedUnits = [.year, .month, .day, .hour, .minute]
        formatter.zeroFormattingBehavior = .dropAll
        formatter.maximumUnitCount = 1
        return String(format: formatter.string(from: self, to: Date()) ?? "", locale: .current)
    }
}

extension Array {
    mutating func removeAll(indexSet: IndexSet) {
        for index in indexSet {
            self.remove(at: index)
        }
    }
}

extension Array where Element == String {
    func intersect(with others: [String]) -> [Element] {
        filter({ others.contains($0) })
    }
}

extension NSCollectionView.DecorationElementKind {
    static let ncItem = "ncItem"
}
