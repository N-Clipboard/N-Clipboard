//
//  MainViewController.swift
//  N Clipboard
//
//  Created by poor branson on 2020/5/14.
//  Copyright © 2020 poor-branson. All rights reserved.
//

import Cocoa
import RealmSwift

class MainViewController: NSViewController, NSCollectionViewDataSource {
    var realm = try! Realm()
    var list: Results<HistoryItem> {
        try! Realm()
            .objects(HistoryItem.self)
            .filter(NSPredicate(format: "content LIKE[c] %@ OR title LIKE[c] %@", "*\(self.keyWord)*", "*\(self.keyWord)*"))
            .sorted(byKeyPath: "updatedAt", ascending: false)
    }
    var token: NotificationToken?
    
    @objc dynamic var keyWord = ""
    @objc dynamic var isEmptyList: Bool = true
    @IBOutlet weak var collectionView: NSCollectionView!
    @IBOutlet weak var searchField: NSSearchField!
    @IBOutlet weak var pinButton: NSButton!
    
    deinit {
        token?.invalidate()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "keyWord" {
            self.collectionView.reloadData()
            self.collectionView.selectionIndexPaths = Set([IndexPath(item: 0, section: 0)])
            self.collectionView(self.collectionView, didSelectItemsAt: Set([IndexPath(item: 0, section: 0)]))
            token?.invalidate()
            token = list.observe(self.onListUpdate(_:))
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let layout = NCListCollectionLayout()
        
        self.addObserver(self, forKeyPath: #keyPath(keyWord), options: [.new, .old], context: nil)
        pinButton.image = NSImage(named: UserDefaults.standard.bool(forKey: Constants.Userdefaults.ShouldStickOnTop) ? "pin_invert" : "pin")
        collectionView.collectionViewLayout = layout
        collectionView.register(NCListCollectionItem.self, forItemWithIdentifier: .init("nc_item"))
        if list.count > 0 {
            collectionView.selectionIndexPaths = Set([IndexPath(item: 0, section: 0)])
        }

        // Do view setup here.
        token = list.observe(self.onListUpdate(_:))
    }
    
    private func onListUpdate(_ change: RealmCollectionChange<Results<HistoryItem>>) {
        self.isEmptyList = self.list.count == 0

        switch change {
        case .update(_, let deletion, let insertion, let modification):
            let previousSelectionIndex = self.collectionView.selectionIndexPaths.first?.item ?? 0

            self.collectionView.performBatchUpdates({
                debugPrint("deletion:\(deletion), insertion: \(insertion), modif: \(modification)")
                self.collectionView.insertItems(at: Set(insertion.map { IndexPath(item: $0, section: 0) }))
                self.collectionView.deleteItems(at: Set(deletion.map { IndexPath(item: $0, section: 0) }))
                self.collectionView.reloadItems(at: Set(modification.map { IndexPath(item: $0, section: 0) }))
            }) { _ in
                self.collectionView.collectionViewLayout?.invalidateLayout()
                self.tryToSelect(index: previousSelectionIndex)
            }
        default: break
        }
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        list.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let view = collectionView.makeItem(withIdentifier: .init("nc_item"), for: indexPath)
        guard let item = view as? NCListCollectionItem else { return view }
        item.history = list[indexPath.item]
        
        return item
    }
    
    @IBAction func togglePinState(_ sender: Any) {
        let current = UserDefaults.standard.bool(forKey: Constants.Userdefaults.ShouldStickOnTop)
        pinButton.image = !current ? NSImage(named: "pin_invert") : NSImage(named: "pin")
        UserDefaults.standard.set(!current, forKey: Constants.Userdefaults.ShouldStickOnTop)
    }
    
    func tryToSelect(index: Int) {
        guard list.count > 0 else { return }
        guard collectionView.selectionIndexPaths.first == nil else { return }
        if index >= list.count {
            collectionView.selectionIndexPaths = Set([IndexPath(item: list.count - 1, section: 0)])
            return
        }
        
        if index < 0 {
            collectionView.selectionIndexPaths = Set([IndexPath(item: 0, section: 0)])
            return
        }
        
        collectionView.selectionIndexPaths = Set([IndexPath(item: index, section: 0)])
    }
    
    override func keyDown(with event: NSEvent) {
        guard event.modifierFlags.intersection(.deviceIndependentFlagsMask) == .command else { return }
        // [D] delete
        if event.keyCode == 2 {
            guard let indexPath = collectionView.selectionIndexPaths.first else { return }
            guard list.count > indexPath.item, indexPath.item >= 0 else { return }
            print("delete \(indexPath.item)")
            do {
                try realm.write {
                    realm.delete(list[indexPath.item])
                }
            } catch { fatalError(error.localizedDescription) }
        }
        
        if event.keyCode == 37 {
            searchField.becomeFirstResponder()
        }
    }
    
    func keyDownHandler(with event: NSEvent) -> NSEvent? {
        let wantedKeyCode: [UInt16] = [2, 37]
        if event.modifierFlags.intersection(.deviceIndependentFlagsMask) == .command && wantedKeyCode.contains(event.keyCode) {
            keyDown(with: event)
            return nil
        }
        
        if [125, 126].contains(event.keyCode) {
            collectionView.keyDown(with: event)
            return nil
        }
        
        if event.keyCode == 36, let index = collectionView.selectionIndexPaths.first?.item {
            NSApp.deactivate()
            ClipBoardService.shared.write(of: self.list[index])
            try! realm.write {
                list[index].updatedAt = Date()
                tryToSelect(index: 0)
            }
        }
        
        searchField.keyDown(with: event)
        
        return event
    }
}

extension MainViewController: NSCollectionViewDelegate {
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        
    }
    
    func collectionView(_ collectionView: NSCollectionView, didDeselectItemsAt indexPaths: Set<IndexPath>) {
        
    }
    
    func collectionView(_ collectionView: NSCollectionView, didEndDisplaying item: NSCollectionViewItem, forRepresentedObjectAt indexPath: IndexPath) {
        //        collectionView.collectionViewLayout?.invalidateLayout()
    }
}
