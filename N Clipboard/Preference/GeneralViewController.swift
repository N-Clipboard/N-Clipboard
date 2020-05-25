//
//  GeneralViewController.swift
//  N Clip Board
//
//  Created by branson on 2019/9/15.
//  Copyright © 2019 branson. All rights reserved.
//

import Cocoa
import MASShortcut
import Preferences

class GeneralViewController: NSViewController, PreferencePane {
    var preferencePaneIdentifier: PreferencePaneIdentifier = .general
    var toolbarItemIcon: NSImage = NSImage(named: NSImage.Name("NSPreferencesGeneral"))!
    var preferencePaneTitle: String = "General"
    
    @IBOutlet weak var keepItemView: NSStackView!
    @IBOutlet weak var masShortcutView: MASShortcutView!

    override var preferredContentSize: NSSize {
        get { NSSize(width: 480, height: 280) }
        set {}
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let storedShortCutValue = UserDefaults.standard.dictionary(forKey: Constants.Userdefaults.ActivationHotKeyDict) as? [String: Int] {
            
            let modifierRawValue = storedShortCutValue["modifier"]!
            let keyCode = storedShortCutValue["keyCode"]!
            masShortcutView.shortcutValue = MASShortcut(keyCode: keyCode, modifierFlags: .init(rawValue: UInt(modifierRawValue)))
        }
        masShortcutView.style = .texturedRect
        masShortcutView.shortcutValueChange = { sender in
            var useModifier: Int, useKeyCode: Int
            
            if let shortcut = sender?.shortcutValue {
                useModifier = Int(shortcut.modifierFlags.rawValue)
                useKeyCode = shortcut.keyCode
            } else {
                useModifier = Constants.defaultActivationHotKey["modifier"] as! Int
                useKeyCode = Constants.defaultActivationHotKey["keyCode"] as! Int
            }
            
            let shortcutValue: [String: Int] = ["modifier": useModifier, "keyCode": useKeyCode]
            UserDefaults.standard.set(shortcutValue, forKey: Constants.Userdefaults.ActivationHotKeyDict)

            let appDelegate = NSApp.delegate as! AppDelegate
            
            do {
                try appDelegate.setActivationHotKey()
            } catch {
                UserDefaults.standard.set(Constants.defaultActivationHotKey, forKey: Constants.Userdefaults.ActivationHotKeyDict)
            }
        }
    }
    
    @IBAction func clipBoardExpireDateChange(_ sender: NSPopUpButton) {
//        print(sender.selectedItem?.tag)
    }
    
    @IBAction func toggleLaunchAtStartUp(_ sender: NSButton) {
        switch sender.state {
        case .on:
            LoginService.enable()
        default:
            LoginService.disable()
        }
    }

}
