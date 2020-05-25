//
//  OverviewService.swift
//  N Clipboard
//
//  Created by poor branson on 2020/5/9.
//  Copyright © 2020 poor-branson. All rights reserved.
//
import SwiftUI

class OverviewService {
    var popover = NSPopover()
    var popoverController = NSViewController()
    
    static var shared = OverviewService()
    
    init() {
        popover.contentViewController = popoverController
        popover.behavior = .transient
    }
    
    func overview(relativeTo view: NSView, item: HistoryItem) {
        switch item.pasteboardType! {
        case .png:
            guard let blobID = item.blobID else { return }
            guard let data = Utility.bs.fetch(filename: blobID) else { return }
            popoverController.view = NSHostingView(rootView: NCImageView(image: NSImage(data: data)))
        case .color:
            return
        default:
            popoverController.view = NSHostingView(rootView: NCTextView(content: item.content))
        }
        popover.show(relativeTo: view.bounds, of: view, preferredEdge: .minY)
    }
}
