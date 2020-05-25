//
//  UpdaterViewController.swift
//  N Clipboard
//
//  Created by poor branson on 2020/5/23.
//  Copyright © 2020 poor-branson. All rights reserved.
//

import Cocoa
import WebKit
import Down

class UpdaterViewController: NSViewController {
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var appIcon: NSImageView!
    @IBOutlet weak var version: NSTextField!
    @IBOutlet weak var downloadOrCancelBtn: NSButton!
    
    @objc dynamic var percentage: Double = 0
    @objc dynamic var isDownloading: Bool = false
    @objc dynamic var updateDMGExisted = false;
    @objc dynamic var hasDownloadStart: Bool { percentage > 0 }
    lazy var userDownloadURL: URL = {
        FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!
    }()

    var dmg_url: URL?
    var taskOfDownload: URLSessionDownloadTask?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appIcon.image = NSImage(named: "AppIcon")
        // Do view setup here.
    }
    
    override class func keyPathsForValuesAffectingValue(forKey key: String) -> Set<String> {
        var keyPaths = Set<String>()
        if key == "hasDownloadStart" {
            keyPaths.insert("percentage")
        }
        
        return keyPaths
    }
    
    func set(with release: LatestGitHubRelease) {
        let parser = Down(markdownString: release.body)
        guard let html = try? parser.toHTML() else { return }
        let injected = Bundle.main.url(forResource: "github-markdown", withExtension: ".css")!
        let style = try! String(contentsOf: injected)
        webView.loadHTMLString("<style>body{font-family:-apple-system,BlinkMacSystemFont,Segoe UI,Helvetica,Arial,sans-serif,Apple Color Emoji,Segoe UI Emoji;font-size:12px;}\(style)</style>\(html)", baseURL: nil)
        version.stringValue = "New Version Available \(release.tag_name)"
        if let downloadURLString = release.assets.first?.browser_download_url {
            dmg_url = URL(string: downloadURLString)!
            let updateExisted = FileManager.default.fileExists(atPath: userDownloadURL.appendingPathComponent(dmg_url!.lastPathComponent, isDirectory: false).path)
            
            if updateExisted {
                updateDMGExisted = true
                downloadOrCancelBtn.title = "Open Update"
            }
        }
    }
    
    func cancelDownLoad() {
        taskOfDownload?.cancel()
        taskOfDownload = nil
        isDownloading = false
        view.window?.styleMask.insert(.closable)
        percentage = 0
        downloadOrCancelBtn.title = "Download Update"
    }
    
    @IBAction func close(_ sender: Any) {
        view.window?.close()
    }
    
    @IBAction func download(_ sender: Any) {
        guard updateDMGExisted == false else {
            NSWorkspace.shared.open(userDownloadURL.appendingPathComponent(dmg_url!.lastPathComponent, isDirectory: false))
            view.window?.close()
            return
        }
        guard taskOfDownload == nil else {
            cancelDownLoad()
            return
        }
        guard let dmg_url = dmg_url else {
            let alert = NSAlert()
            alert.messageText = "Nothing to Update"
            alert.informativeText = "You see this warning because an incorrect version has been released. Please report this warning to the developer, your data is still safe."
            alert.alertStyle = .critical
            
            alert.runModal()
            return
        }
        
        isDownloading = true
        view.window?.styleMask.remove(.closable)
        downloadOrCancelBtn.title = "Cancel"
        
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringCacheData
        
        taskOfDownload = URLSession(configuration: config, delegate: self, delegateQueue: nil).downloadTask(with: dmg_url)
        taskOfDownload?.resume()
    }
}

extension UpdaterViewController: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {

        DispatchQueue.main.async {
            self.view.window?.close()
        }

        taskOfDownload = nil
        isDownloading = false
        let destURL = userDownloadURL.appendingPathComponent(dmg_url!.lastPathComponent, isDirectory: false)
        
        do {
            try FileManager.default.moveItem(at: location, to: destURL)
            NSWorkspace.shared.open(destURL)
        } catch {
            DispatchQueue.main.async {
                warningBox(title: "Fail to Open Update", message: "You don't have permission to do this operation", style: .critical)
            }
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        percentage = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite) * 100
    }
}
