//
//  Utility.swift
//  N Clip Board
//
//  Created by nuc_mac on 2019/10/11.
//  Copyright © 2019 branson. All rights reserved.
//

import Cocoa
import BlobStorage

final class Utility {
    static var bs = try! BlobStorage(bundleName: Bundle.main.bundleIdentifier!)!
    static var isOnQLPreview = false
    static private var _isActivated = true
    static var isActivated: Bool {
        get { _isActivated }
        set {
            _isActivated = newValue;
            if newValue {
                ClipBoardService.shared.enableNSPasteboardMonitor()
            } else {
                ClipBoardService.shared.disableNSPasteboardMonitor()
            }
        }
    }
    static func registerUserDefaults() {
        var preferenceDict = Dictionary<String, Any>.init()

        preferenceDict[Constants.Userdefaults.LaunchOnStartUp] = false
        preferenceDict[Constants.Userdefaults.ShowCleanUpMenuItem] = false
        preferenceDict[Constants.Userdefaults.KeepClipBoardItemUntil] = 30
        preferenceDict[Constants.Userdefaults.PollingInterval] = 0.4
        preferenceDict[Constants.Userdefaults.ShowPollingIntervalLabel] = false
        preferenceDict[Constants.Userdefaults.ExcludedAppDict] = [String: Bool]()
        // default using command+shift+v
        preferenceDict[Constants.Userdefaults.ActivationHotKeyDict] = Constants.defaultActivationHotKey
        preferenceDict[Constants.Userdefaults.ShouldStickOnTop] = false
        
        UserDefaults.standard.register(defaults: preferenceDict)
    }

    // referenced from https://stackoverflow.com/questions/26971240/how-do-i-run-an-terminal-command-in-a-swift-script-e-g-xcodebuild
    @discardableResult
    static func shell(_ args: String...) -> Int32 {
        let task = Process()
        task.launchPath = "/usr/bin/env"
        task.arguments = args
        task.launch()
        task.waitUntilExit()
        return task.terminationStatus
    }
    
    static func findAppIcon(by bundleIdentifier: String) -> NSImage? {
        guard let bundlePath = NSWorkspace.shared.absolutePathForApplication(withBundleIdentifier: bundleIdentifier) else { return nil }
        
        return NSWorkspace.shared.icon(forFile: bundlePath)
    }
    
    static func getAppLocalizedName(by bundleIdentifier: String) -> String? {
        guard let bundlePath = NSWorkspace.shared.absolutePathForApplication(withBundleIdentifier: bundleIdentifier) else {
            LogService.warning("Fail to find bundle \(bundleIdentifier)")
            return nil
        }
        
        return FileManager.default.displayName(atPath: bundlePath)
    }
    
    static func hexColor(color: NSColor) -> String {
        let red = Int(round(color.redComponent * 0xff))
        let blue = Int(round(color.blueComponent * 0xff))
        let green = Int(round(color.greenComponent * 0xff))
        
        return String(format: "#%02X%02X%02X", red, green, blue)
    }
    
    static func getBlobFileName() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        return formatter.string(from: Date())
    }
    
    static func genThumbnail(imageData: Data) -> Data? {
        let options = [
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceThumbnailMaxPixelSize: 120
        ] as CFDictionary
        
        guard let source = CGImageSourceCreateWithData(imageData as CFData, nil) else { return nil }
        guard let imageRef = CGImageSourceCreateThumbnailAtIndex(source, 0, options) else { return nil }
        return NSImage(cgImage: imageRef, size: NSSize()).tiffRepresentation
    }
}

func warningBox(title: String, message: String, style: NSAlert.Style = .warning) {
    let alert = NSAlert()
    alert.alertStyle = style
    alert.messageText = title
    alert.informativeText = message
    
    alert.runModal()
}

func hasAnotherInstance() -> Bool {
    let runningInstance = NSRunningApplication.runningApplications(withBundleIdentifier: Bundle.main.bundleIdentifier!)
    
    return runningInstance.count > 1
}
