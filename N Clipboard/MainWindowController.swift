//
//  WindowController.swift
//  N Clipboard
//
//  Created by poor branson on 2020/5/4.
//  Copyright © 2020 poor-branson. All rights reserved.
//

import Cocoa

class MainWindowController: NSWindowController, NSWindowDelegate {
    func windowDidResignKey(_ notification: Notification) {
        guard !Utility.isOnQLPreview else { return }
        if UserDefaults.standard.bool(forKey: Constants.Userdefaults.ShouldStickOnTop) == false {
            window?.close()
        }
    }
}
