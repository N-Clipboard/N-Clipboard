//
//  NCPopoverMenu.swift
//  N Clipboard
//
//  Created by poor branson on 2020/5/3.
//  Copyright © 2020 poor-branson. All rights reserved.
//

import SwiftUI

class NCPopoverMenu {
    private var popover: NSPopover = .init()
    private var controller: NSViewController = .init()
    private var statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    
    func initialize() {
        popover.contentViewController = controller
        controller.view = NSHostingView(rootView: NCPopoverView())
        
        popover.behavior = .transient

        if let button = statusItem.button {
            button.image = NSImage(named: "n_status")
            button.action = #selector(onShow(_:))
            button.sendAction(on: [.leftMouseUp])
            button.target = self
        }
    }
    
    @objc func onShow(_ sender: Any) {
        popover.show(relativeTo: statusItem.button!.bounds, of: statusItem.button!, preferredEdge: .maxY)
    }
}

