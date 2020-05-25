//
//  AppearanceViewController.swift
//  N Clip Board
//
//  Created by branson on 2019/9/15.
//  Copyright © 2019 branson. All rights reserved.
//

import Cocoa
import Preferences

class ExcludedApp: NSObject {
    @objc dynamic var name: String
    @objc dynamic var icon: NSImage?
    @objc dynamic var isExcluded: Bool
    @objc dynamic var bundleIdentifier: String
    
    init(name: String, icon: NSImage?, isExcluded: Bool, _ bundleIdentifier: String) {
        self.name = name
        self.icon = icon
        self.isExcluded = isExcluded
        self.bundleIdentifier = bundleIdentifier
    }
}

class RulesViewController: NSViewController, PreferencePane {
    var preferencePaneIdentifier: Identifier = .rules
    var preferencePaneTitle: String = "Rules"
    var toolbarItemIcon: NSImage = #imageLiteral(resourceName: "toolbar_rules")
    override var preferredContentSize: NSSize {
        get { NSSize(width: 540, height: 340) }
        set {}
    }
    
    var lastRemovedIndexSet: IndexSet?
    
    @objc dynamic var excludedAppList = [ExcludedApp]()
    @objc dynamic var selectionIndexes = IndexSet()
    @objc dynamic var hasSelection: Bool {
        get { selectionIndexes.count > 0 }
    }
    
    @IBOutlet weak var appTable: NSTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        if let appDict = UserDefaults.standard.dictionary(forKey: Constants.Userdefaults.ExcludedAppDict) as? [String: Bool] {
            excludedAppList = appDict.map { (identifier, isExcluded) -> ExcludedApp in
                let appName = Utility.getAppLocalizedName(by: identifier) ?? "Unknown"
                let appIcon = Utility.findAppIcon(by: identifier)
                
                return ExcludedApp(name: appName, icon: appIcon, isExcluded: isExcluded, identifier)
            }
        }
    }
    
    override class func keyPathsForValuesAffectingValue(forKey key: String) -> Set<String> {
        switch key {
        case "hasSelection":
            return ["selectionIndexes"]
        default:
            return []
        }
    }
    
    override func viewWillDisappear() {
        let newAppDict = excludedAppList.reduce([String: Bool]()) { (result, app) -> [String: Bool] in
            
            return [app.bundleIdentifier: app.isExcluded]
        }
        
        UserDefaults.standard.set(newAppDict, forKey: Constants.Userdefaults.ExcludedAppDict)
    }
    
    func isBundleInExcludedList(identifier: String) -> Bool {
        excludedAppList.contains { $0.bundleIdentifier == identifier }
    }
    
    @IBAction func addExcludedApp(_ sender: NSButton) {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.allowsMultipleSelection = true
        panel.directoryURL = URL(fileURLWithPath: "/Applications", isDirectory: true)
        panel.beginSheetModal(for: view.window!) { (result) in
            for url in panel.urls {
                let bundle = Bundle(url: url)
                guard let identifier = bundle?.bundleIdentifier else {
                    warningBox(title: "Error", message: "Not an App")
                    return
                }
                guard self.isBundleInExcludedList(identifier: identifier) == false else { return }
                let name = Utility.getAppLocalizedName(by: identifier) ?? "Unknown"
                let icon = Utility.findAppIcon(by: identifier)
                
                self.excludedAppList.append(.init(name: name, icon: icon, isExcluded: true, identifier))
            }
        }
    }
    
    @IBAction func removeApp(_ sender: NSButton) {
        lastRemovedIndexSet = selectionIndexes
        appTable.removeRows(at: selectionIndexes, withAnimation: .slideDown)
    }
}

extension RulesViewController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, didRemove rowView: NSTableRowView, forRow row: Int) {
        guard let indexSet = lastRemovedIndexSet else { return }
        // ... apple says only -1 stands for forever invalid
        if row == -1 {
            excludedAppList.removeAll(indexSet: indexSet)
        }
    }
}
