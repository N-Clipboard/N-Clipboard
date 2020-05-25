//
//  PreviewService.swift
//  N Clipboard
//
//  Created by poor branson on 2020/5/8.
//  Copyright © 2020 poor-branson. All rights reserved.
//

import Quartz

struct PreviewService {
    var qlItems: [QLPreviewItem] = []

    init(_ item: HistoryItem) {
        let validator = ContentValidator(item)
        
        if validator.isFileURL {
            qlItems.append(URL(fileURLWithPath: item.content) as QLPreviewItem)
        }
        
        if validator.isURL, let url = URL(string: item.content) {
            qlItems.append(url as QLPreviewItem)
        }
    }
}
