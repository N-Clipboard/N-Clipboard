//
//  ExcludAppService.swift
//  N Clip Board
//
//  Created by branson on 2019/11/14.
//  Copyright © 2019 branson. All rights reserved.
//

import Cocoa

class ExcludeAppService: NSObject {
    private var excludedBundleIdentifier = [String]()
    
    static let shared = ExcludeAppService()
    
    override init() {
        super.init()
        
        refresh()
        UserDefaults.standard.addObserver(self, forKeyPath: Constants.Userdefaults.ExcludedAppDict, options: [.new], context: nil)
    }
    
    func isActivatedProcessExcluded() -> Bool {
        guard let identifier = SysMonitorService.shared.activatedAppBundleIdentifier else { return true }
        return excludedBundleIdentifier.contains(identifier)
    }
    
    func isPasteItemFromExcludedBundle(item: NSPasteboardItem) -> Bool {
        let textPresentationOfType = item.types.map({ $0.rawValue })
        let result = textPresentationOfType.intersect(with: excludedBundleIdentifier)
        
        return result.count > 0
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == Constants.Userdefaults.ExcludedAppDict {
            refresh()
        }
    }
    
    func refresh() {
        let appDict = UserDefaults.standard.dictionary(forKey: Constants.Userdefaults.ExcludedAppDict)
        
        excludedBundleIdentifier = appDict?
            .filter({ (_, isExcluded) -> Bool in
                isExcluded as! Bool
            }).map({ (bundleIdentifier, isExcluded) -> String in
                bundleIdentifier
            }) ?? []
    }
}
