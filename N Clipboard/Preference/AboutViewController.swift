//
//  AboutViewController.swift
//  N Clipboard
//
//  Created by poor branson on 2020/5/6.
//  Copyright © 2020 poor-branson. All rights reserved.
//

import Cocoa
import Preferences
import SwiftUI

class AboutViewController: NSViewController, PreferencePane {
    var preferencePaneIdentifier: Identifier = .about
    
    var preferencePaneTitle: String = "About"
    
    var toolbarItemIcon = #imageLiteral(resourceName: "icon_about")
    
    var _view = NSHostingView(rootView: AboutView())
    
    override var view: NSView {
        get { _view }
        set { }
    }
    
    override var preferredContentSize: NSSize {
        get { NSSize(width: 480, height: 280) }
        set {}
    }
}
