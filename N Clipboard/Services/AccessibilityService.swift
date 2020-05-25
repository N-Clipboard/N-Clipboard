//
//  AccessibilityService.swift
//  N Clip Board
//
//  Created by branson on 2019/10/21.
//  Copyright © 2019 branson. All rights reserved.
//

import Cocoa

struct AccessibilityService {
    static func isServiceAccessible() -> Bool {
        guard #available(macOS 10.14, *) else { return true }
        
        let checkOptionPromptKey = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String
        let opts = [checkOptionPromptKey: true] as CFDictionary
        return AXIsProcessTrustedWithOptions(opts)
    }
    
    static func requestAccessibilityPermission() {
        let alert = NSAlert()
//        alert.alertStyle = .warning
        alert.messageText = "Accessibility permission required"
        alert.informativeText = "Paste action require this permission"
        alert.addButton(withTitle: "Grant")
        alert.addButton(withTitle: "Denial")
        if alert.runModal() == .alertFirstButtonReturn {
            openAccessibilitySettingWindow()
        }
    }
    
    @discardableResult
    static func openAccessibilitySettingWindow() -> Bool {
        guard let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") else { return false }
        return NSWorkspace.shared.open(url)
    }
    
    static func checkAccessibilityPermission() {
        if !isServiceAccessible() {
            requestAccessibilityPermission()
        }
    }
}
