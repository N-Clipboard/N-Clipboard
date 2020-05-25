//
//  NCDecorationView.swift
//  N Clipboard
//
//  Created by poor branson on 2020/5/14.
//  Copyright © 2020 poor-branson. All rights reserved.
//

import Cocoa

class NCDecorationView: NSView {
    let line = NSBox()

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        line.boxType = .separator
        line.setFrameSize(NSSize(width: frameRect.size.width, height: 1))
        addSubview(line)
    }
    
    override func resize(withOldSuperviewSize oldSize: NSSize) {
        super.resize(withOldSuperviewSize: oldSize)
        line.setFrameSize(NSSize(width: frame.size.width, height: 1))
    }
}
