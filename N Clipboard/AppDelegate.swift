//
//  AppDelegate.swift
//  N Clipboard
//
//  Created by poor branson on 2020/5/1.
//  Copyright © 2020 poor-branson. All rights reserved.
//

import Cocoa
import RealmSwift
import HotKey
import Preferences
import Quartz

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    @IBOutlet var window: NSWindow!

    var historyItem: HistoryItem?
    var eventHandler: Any?
    var hk: HotKey?
    var menu = NCPopoverMenu()
    lazy var preferenceWindowController = PreferencesWindowController(preferencePanes: [
        GeneralViewController(),
        RulesViewController(),
        AboutViewController()
    ])

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        Realm.Configuration.defaultConfiguration = useRLMConfig
        registerValueTransformer()

        window.setFrameAutosaveName("Main Window")
        window.collectionBehavior = [.fullScreenAuxiliary, .canJoinAllSpaces]
        window.contentViewController = MainViewController()
        window.level = .floating

        
        Utility.registerUserDefaults()
        SysMonitorService.shared.start()
        menu.initialize()
        ClipBoardService.shared.enableNSPasteboardMonitor()
        NCUpdateService().checkForUpdate()
        preferenceWindowController.window?.standardWindowButton(.miniaturizeButton)?.isEnabled = true
        preferenceWindowController.window?.styleMask.insert(.miniaturizable)
        
        do {
            try setActivationHotKey()
        } catch {
            LogService.error(error.localizedDescription)
        }
        
        eventHandler = NSEvent.addLocalMonitorForEvents(matching: .keyDown, handler: { (event) -> NSEvent? in
            (self.window.contentViewController as? MainViewController)?.keyDownHandler(with: event)
        })
    }
    
    deinit {
        if let eh = eventHandler {
            NSEvent.removeMonitor(eh)
        }
    }
    
    func setActivationHotKey() throws {
        guard let activationKey = UserDefaults.standard.dictionary(forKey: Constants.Userdefaults.ActivationHotKeyDict) else {
            throw NError.InValidActivationKey
        }
        
        guard let modifier = activationKey["modifier"] as? UInt, let keyCode = activationKey["keyCode"] as? UInt32 else {
            throw NError.InValidActivationKey
        }

        guard let key = Key(carbonKeyCode: keyCode) else {
            LogService.error("Fail to setActivationHotKey, passed keyCode is: \(keyCode)")
            throw NError.InValidActivationKey
        }
        
        hk = HotKey(key: key, modifiers: NSEvent.ModifierFlags(rawValue: modifier))
        hk?.keyDownHandler = {
            self.window.makeKeyAndOrderFront(self)
        }
    }
    
    @IBAction func showPreferencePanel(_ sender: Any = self) {
        preferenceWindowController.show(preferencePane: .general)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func confirmBeforeCleanClipBoard() {
        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.messageText = NSLocalizedString("CleanUpMessage", comment: "")
        alert.informativeText = NSLocalizedString("CleanUpHint", comment: "")
        alert.addButton(withTitle: NSLocalizedString("CleanUpConfirmationOfNo", comment: ""))
        alert.addButton(withTitle: NSLocalizedString("CleanUpConfirmationOfYes", comment: ""))
        let result = alert.runModal()
        if result == .alertSecondButtonReturn {
            clearAllContent()
        }
    }
    
    func clearAllContent() {
        let realm = try! Realm()
        let result = realm.objects(HistoryItem.self)
        
        if result.count > 0 {
            realm.delete(result)
        }
    }
    
    @IBAction func beforeCleanUp(_ sender: Any) {
        confirmBeforeCleanClipBoard()
    }
}

extension AppDelegate: QLPreviewPanelDelegate, QLPreviewPanelDataSource {
    func showOverview() {
        if let shared = QLPreviewPanel.shared(), historyItem != nil {
            Utility.isOnQLPreview = true
            shared.makeKeyAndOrderFront(self)
        }
    }

    func numberOfPreviewItems(in panel: QLPreviewPanel!) -> Int {
        1
    }
    
    func previewPanel(_ panel: QLPreviewPanel!, previewItemAt index: Int) -> QLPreviewItem! {
//        guard let indexPath = collectionView.selectionIndexPaths.first else { return nil }
//        if let item = collectionView.dataSource?.collectionView(collectionView, itemForRepresentedObjectAt: indexPath) as? NCListCollectionItem {
        return PreviewService(historyItem!).qlItems[index]
//        }
//
//        return nil
    }
    
    override func acceptsPreviewPanelControl(_ panel: QLPreviewPanel!) -> Bool {
        true
    }
    
    override func beginPreviewPanelControl(_ panel: QLPreviewPanel!) {
        panel.delegate = self
        panel.dataSource = self
    }
    
    override func endPreviewPanelControl(_ panel: QLPreviewPanel!) {
        historyItem = nil
        Utility.isOnQLPreview = false
        panel.delegate = nil
        panel.dataSource = nil
    }
}

