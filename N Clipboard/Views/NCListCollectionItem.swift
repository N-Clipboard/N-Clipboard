//
//  NCListCollectionItem.swift
//  N Clipboard
//
//  Created by poor branson on 2020/5/14.
//  Copyright © 2020 poor-branson. All rights reserved.
//

import Cocoa
import RealmSwift

class NCListCollectionItem: NSCollectionViewItem {
    var trackingArea: NSTrackingArea?
    @objc dynamic var history: HistoryItem?
    @objc dynamic var useTextColor: NSColor?
    @objc dynamic var isOnHover: Bool = false
    @objc dynamic var isMarkVisible: Bool {
        isOnHover || (history?.isMarked ?? false)
    }
    @objc dynamic var validator = ContentValidator(nil)
    @objc dynamic var useMarkIcon: NSImage? {
        (history?.isMarked ?? false) ? NSImage(named: "mark_fill") : NSImage(named: "mark")
    }
    @objc dynamic var icon: NSImage? {
        (history?.thumbnail != nil) ? NSImage(data: history!.thumbnail!) : Utility.findAppIcon(by: history?.bundleIdentifier ?? "")
    }
    // is not kvo complaint
    override var isSelected: Bool {
        didSet {
            self.selectionChange()
        }
    }
    @IBOutlet weak var actionContainer: NSStackView!
    @IBOutlet weak var iconView: NSImageView!
    
    override func viewDidLoad() {
        self.view.wantsLayer = true
        self.addObserver(self, forKeyPath: #keyPath(history), options: [.new, .old], context: nil)
        self.addObserver(self, forKeyPath: #keyPath(isOnHover), options: [.new, .old], context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "history" {
            self.validator = ContentValidator(self.history)
            self.willChangeValue(forKey: "isMarkVisible")
            self.didChangeValue(forKey: "isMarkVisible")
            self.willChangeValue(forKey: "useMarkIcon")
            self.didChangeValue(forKey: "useMarkIcon")
            iconView.image = icon
        }
        if keyPath == "isOnHover" {
            self.willChangeValue(forKey: "isMarkVisible")
            self.didChangeValue(forKey: "isMarkVisible")
        }
    }
    
    override func viewDidLayout() {
        super.viewDidLayout()
        if let area = trackingArea {
            view.removeTrackingArea(area)
        }
        
        trackingArea = NSTrackingArea(rect: view.bounds, options: [.mouseEnteredAndExited, .activeInKeyWindow], owner: self, userInfo: nil)
        view.addTrackingArea(trackingArea!)
    }
    
    func selectionChange() {
        self.view.layer?.backgroundColor = isSelected ? NSColor.systemBlue.cgColor : CGColor.clear
        useTextColor = isSelected ? NSColor.white : nil
        updateActionTintColor()
    }
    
    func updateActionTintColor() {
        for actionView in actionContainer.subviews {
            guard let btn = actionView as? NSButton else { continue }
            btn.contentTintColor = isSelected ? NSColor.white: nil
        }
    }
    
    @IBAction func toggleMark(_ sender: Any) {
        guard history != nil else { return }
        let realm = try! Realm()
        do {
            try realm.write {
                history!.isMarked = !history!.isMarked
            }
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    @IBAction func selectURL(_ sender: Any) {
        validator.select()
    }
    
    @IBAction func openURL(_ sender: Any) {
        validator.open()
    }
    
    @IBAction func overview(_ sender: Any) {
        if validator.isImage, let item = history {
            OverviewService.shared.overview(relativeTo: view, item: item)
            return
        }
        if let delegate = NSApp.delegate as? AppDelegate {
            delegate.historyItem = history
            delegate.showOverview()
        }
    }

    override func mouseEntered(with event: NSEvent) {
        isOnHover = true
        nextResponder?.mouseEntered(with: event)
    }
    
    override func mouseExited(with event: NSEvent) {
        isOnHover = false
        nextResponder?.mouseExited(with: event)
    }
}
