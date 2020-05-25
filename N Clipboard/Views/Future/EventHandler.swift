//
//  EventHandler.swift
//  N Clipboard
//
//  Created by poor branson on 2020/5/3.
//  Copyright © 2020 poor-branson. All rights reserved.
//

import Foundation

class EventHandler {
    var arrowUp: (() -> Void)?
    var arrowDown: (() -> Void)?
    var paste: (() -> Void)?
    var delete: (() -> Void)?
    var focus: (() -> Void)?
    var click: (() -> Void)?
    var overview: (() -> Void)?
    
    var didHandle: Bool = false
    
    func onArrowUp(_ perform: @escaping () -> Void) -> EventHandler {
        self.arrowUp = perform
        return self
    }
    
    func onArrowDown(_ perform: @escaping () -> Void) -> EventHandler {
        self.arrowDown = perform
        return self
    }
    
    func onPaste(_ perform: @escaping () -> Void) -> EventHandler {
        self.paste = perform
        return self
    }
    
    func onDelete(_ perform: @escaping () -> Void) -> EventHandler {
        self.delete = perform
        return self
    }
    
    func onFocus(_ perform: @escaping () -> Void) -> EventHandler {
        self.focus = perform
        return self
    }
    
    func onClick(_ perform: @escaping () -> Void) -> EventHandler {
        self.click = perform
        return self
    }
    
    func onOverview(_ perform: @escaping () -> Void) -> EventHandler {
        self.overview = perform
        return self
    }
    
    func assert(_ event: NSEvent) -> EventHandler {
        if event.type == .leftMouseDown {
            self.click?()
            self.didHandle = self.click != nil
        }
        
        if event.type == .keyDown {
            // with command modifier
            if event.modifierFlags.intersection(.deviceIndependentFlagsMask) == .command {
                // [L]
                if event.keyCode == 37 {
                    self.focus?()
                    self.didHandle = self.focus != nil
                }
                
                // [D]
                if event.keyCode == 2 {
                    self.delete?()
                    self.didHandle = self.delete != nil
                }
            }
            
            // with command + shift modifier
            if event.modifierFlags.intersection(.deviceIndependentFlagsMask) == [.command, .shift] {
                // [P]
                if event.keyCode == 35 {
                    self.overview?()
                    self.didHandle = self.overview != nil
                }
            }
            
            // just [enter]
            if event.keyCode == 36 {
                self.paste?()
                self.didHandle = self.paste != nil
            }
            
            // keydown
            if event.keyCode == 125 {
                self.arrowDown?()
                self.didHandle = self.arrowDown != nil
            }
            
            if event.keyCode == 126 {
                self.arrowUp?()
                self.didHandle = self.arrowUp != nil
            }
        }
        
        return self
    }
}
