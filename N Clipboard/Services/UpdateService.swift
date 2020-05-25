//
//  UpdateService.swift
//  N Clipboard
//
//  Created by poor branson on 2020/5/20.
//  Copyright © 2020 poor-branson. All rights reserved.
//

import Cocoa

struct LatestGitHubRelease: Decodable {
    var url: String
    var html_url: String
    var tag_name: String
    var assets: [Assets]
    var prerelease: Bool
    var created_at: String
    var published_at: String
    var body: String
    
    struct Assets: Decodable {
        var id: Int
        var size: Double
        var browser_download_url: String
    }
}

class NCUpdateService: NSObject, NSWindowDelegate {
    var updatePanel: NSWindow?
    let appCastURL = URL(string: "https://api.github.com/repos/N-Clipboard/N-ClipBoard/releases/latest")!;
    var task: URLSessionDataTask?
    @objc dynamic var isLoading = false
    
    private static var urlSessionConfig: URLSessionConfiguration {
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringCacheData
        
        return config
    }
    static var urlSession: URLSession { URLSession(configuration: urlSessionConfig) }
    
    @IBAction func checkForUpdate(_ sender: Any) {
        checkForUpdate()
    }
    
    func checkForUpdate() {
        guard task?.state != .running else { return }
        
        isLoading = true
        
        task = NCUpdateService.urlSession.dataTask(with: appCastURL) { data, response, error in
            self.isLoading = false

            if let error = error {
                LogService.error(error.localizedDescription)
                return
            }
            
            if let res = response as? HTTPURLResponse, res.statusCode == 200, data != nil {
                let decoder = JSONDecoder()
                let release = try? decoder.decode(LatestGitHubRelease.self, from: data!)
                
                if let latest = release, latest.tag_name != self.getCurrentVersion() {
                    DispatchQueue.main.async {
                        self.notify(release: latest)
                    }
                }
            }
        }
        
        task?.resume()
    }
    
    private func notify(release: LatestGitHubRelease) {
        if updatePanel == nil {
            updatePanel = NSWindow(contentViewController: UpdaterViewController())
            updatePanel?.styleMask.remove([.fullScreen, .resizable])
            updatePanel?.title = "N Clipboard Update"
            updatePanel?.animationBehavior = .documentWindow
            updatePanel?.delegate = self
            (updatePanel?.contentViewController as! UpdaterViewController).set(with: release)
        }
        
        updatePanel?.makeKeyAndOrderFront(self)
    }
    
    func getCurrentVersion() -> String {
        let shortVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        let bundleVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
        
        return "\(shortVersion)-build.\(bundleVersion)"
    }
    
    func windowWillClose(_ notification: Notification) {
        updatePanel = nil
    }
}
