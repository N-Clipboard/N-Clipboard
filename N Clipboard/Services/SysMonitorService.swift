//
//  SysMonitorService.swift
//  N Clip Board
//
//  Created by branson on 2019/11/1.
//  Copyright © 2019 branson. All rights reserved.
//

import Cocoa

class SysMonitorService: NSObject {
    private var isServiceInitialized = false
    
    private var _activatedAppBundleIdentifier: String?
    var activatedAppBundleIdentifier: String? {
        get { _activatedAppBundleIdentifier }
    }
    
    static var shared = SysMonitorService()
    
    private override init() {}
    
    func start() {
        guard !hasAnotherInstance() else {
            LogService.warning("Another N Clipboard instance already running, skip initialize SysMonitorService")
            return
        }
        if !isServiceInitialized {
            isServiceInitialized = true
            
            monitorActivatedApp()
            monitorSysStatu()
        } else {
            LogService.error("SysMonitorService tried to initialize more than once")
        }
    }
    
    func monitorActivatedApp() {
        NSWorkspace.shared.notificationCenter.addObserver(forName: NSWorkspace.didActivateApplicationNotification, object: nil, queue: nil) { (notice) in
            if let userInfo = notice.userInfo {
                guard let app = userInfo[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication else {
                    LogService.error("Fail to cast activated application into NSRunningApplication")
                    return
                }
                
                self._activatedAppBundleIdentifier = app.bundleIdentifier
                CleanupService.collect()
            }
        }
    }
    
    func monitorSysStatu() {
        NSWorkspace.shared.notificationCenter.addObserver(forName: NSWorkspace.screensDidSleepNotification, object: nil, queue: nil) { (notice) in
            CleanupService.collect()
            ClipBoardService.shared.disableNSPasteboardMonitor()
        }
        NSWorkspace.shared.notificationCenter.addObserver(forName: NSWorkspace.screensDidWakeNotification, object: nil, queue: nil) { (notice) in
            CleanupService.collect()
            ClipBoardService.shared.enableNSPasteboardMonitor()
        }
    }
}
