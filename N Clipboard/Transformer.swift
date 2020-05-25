//
//  Transformer.swift
//  N Clipboard
//
//  Created by poor branson on 2020/5/16.
//  Copyright © 2020 poor-branson. All rights reserved.
//

import Cocoa

fileprivate class TimeAgoTransformer: ValueTransformer {
    override class func allowsReverseTransformation() -> Bool {
        false
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let value = value as? Date else { return nil }
        
        return value.timeAgo()
    }
}

extension NSValueTransformerName {
    static let TimeAgo = NSValueTransformerName("TimeAgo")
}

func registerValueTransformer() {
    ValueTransformer.setValueTransformer(TimeAgoTransformer(), forName: .TimeAgo)
}
