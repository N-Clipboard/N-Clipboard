//
//  ClipBoardHelper.swift
//  N Clip Board
//
//  Created by branson on 2019/9/13.
//  Copyright © 2019 branson. All rights reserved.
//

import Cocoa
import RealmSwift
import BlobStorage

class ClipBoardService: NSObject {
    private var timer: Timer?
    private var realm = try! Realm()
    fileprivate var changeCount = NSPasteboard.general.changeCount

    // MARK: Singleton shared instance
    @objc static let shared = ClipBoardService()
    
    private func saveUserCopiedItemIntoStore() {
        // MARK: detect whether paste updated or not
        guard changeCount != NSPasteboard.general.changeCount else { return }
        changeCount = NSPasteboard.general.changeCount
        
        guard !ExcludeAppService.shared.isActivatedProcessExcluded() else { return }
        guard let items = NSPasteboard.general.pasteboardItems else { return }
        
        for item in items {
            guard !ExcludeAppService.shared.isPasteItemFromExcludedBundle(item: item) else { continue }
            guard item.types.contains(where: { Constants.supportedPasteboardType.contains($0) }) else { continue }

            do {
                let entity = HistoryItem()
                entity.bundleIdentifier = SysMonitorService.shared.activatedAppBundleIdentifier

                if item.types.contains(.png) {
                    let filename = UUID().uuidString
                    let data = item.data(forType: .png)!
                    try Utility.bs.save(item: BlobContent(name: filename), data: data)
                    entity.blobID = filename
                    entity.content = description(data: data, forType: .png)
                    entity.pasteboardType = .png
                    entity.thumbnail = Utility.genThumbnail(imageData: data)
                } else if item.types.contains(.color) {
                    //                        entity.rawTypeValue = NSPasteboard.PasteboardType.color.rawValue
                    //                        entity.content = item.data(forType: .color)
                } else if item.types.contains(.fileURL) {
                    if let data = item.data(forType: .fileURL) {
                        let url = URL(dataRepresentation: data, relativeTo: nil)
                        entity.content = url?.path ?? ""
                        entity.pasteboardType = .fileURL
                    } else {
                        throw NError.EntityHaveNoData
                    }
                } else {
                    let content = item.string(forType: .string) ?? ""
                    entity.content = content
                    entity.pasteboardType = .string
                }
                try realm.write { realm.add(entity) }
            }
            catch {
                LogService.error(error.localizedDescription)
            }
        }
    }
    
    private func description(data: Data, forType type: NSPasteboard.PasteboardType) -> String {
        if type == .png {
            let formatter = ByteCountFormatter()
            formatter.allowedUnits = .useKB
            formatter.countStyle = .file
            let image = NSImage(data: data)!
            return "\(image.size.width) x \(image.size.height)\n\(formatter.string(fromByteCount: Int64(data.count)))"
        }
        
        return "[Unknown Content]"
    }
    
    func write(of item: HistoryItem) {
        AccessibilityService.checkAccessibilityPermission()

        disableNSPasteboardMonitor()
        NSPasteboard.general.prepareForNewContents(with: [])
        changeCount += 1

        NSPasteboard.general.writeObjects([item])
        enableNSPasteboardMonitor()
        paste()
    }
    
    func enableNSPasteboardMonitor() {
        guard !hasAnotherInstance() else { return }
        guard timer == nil || timer?.isValid == false else { return }
        var pollingInterval = UserDefaults.standard.double(forKey: Constants.Userdefaults.PollingInterval)
        changeCount = NSPasteboard.general.changeCount
        
        if !(0.2...1).contains(pollingInterval) {
            UserDefaults.standard.set(0.4, forKey: Constants.Userdefaults.PollingInterval)
            pollingInterval = 0.4
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: pollingInterval, repeats: true) { timer in
            self.saveUserCopiedItemIntoStore()
        }
        LogService.info("ClipboardService enabled")
    }
    
    @discardableResult
    func disableNSPasteboardMonitor() -> Bool {
        guard let t = timer else { return false }
        guard t.isValid else { return true }
        
        t.invalidate()
        LogService.info("ClipboardService disabled")
        return true
    }
    
    // reload timer
    func reloadMonitor() {
        disableNSPasteboardMonitor()
        enableNSPasteboardMonitor()
    }
    
    func clearRecord() throws {
        
    }
    
    // MARK: paste
    func paste() {
        let keyCodeOfV: CGKeyCode = 9
        DispatchQueue.main.async {
            let source = CGEventSource(stateID: .combinedSessionState)
            // Disable local keyboard events while pasting
            source?.setLocalEventsFilterDuringSuppressionState([.permitLocalMouseEvents, .permitSystemDefinedEvents], state: .eventSuppressionStateSuppressionInterval)
            // Press Command + V
            let keyVDown = CGEvent(keyboardEventSource: source, virtualKey: keyCodeOfV, keyDown: true)
            keyVDown?.flags = .maskCommand
            // Release Command + V
            let keyVUp = CGEvent(keyboardEventSource: source, virtualKey: keyCodeOfV, keyDown: false)
            keyVUp?.flags = .maskCommand
            // Post Paste Command
            keyVDown?.post(tap: .cgAnnotatedSessionEventTap)
            keyVUp?.post(tap: .cgAnnotatedSessionEventTap)
        }
    }
}
