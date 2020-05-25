//
//  LogService.swift
//  N Clipboard
//
//  Created by poor branson on 2020/5/1.
//  Copyright © 2020 poor-branson. All rights reserved.
//

import Foundation
import SwiftyBeaver

let LogService: SwiftyBeaver.Type = {
    let log = SwiftyBeaver.self
    let fileDest = FileDestination()
    let filename = Bundle.main.bundleIdentifier!
//    fileDest.logFileURL = URL
    let applicationSupportURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
    let cacheURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first

    #if DEBUG
    fileDest.logFileURL = cacheURL?.appendingPathComponent("\(filename)/N_Clipboard.log")
    #else
    fileDest.logFileURL = applicationSupportURL?.appendingPathComponent("\(filename)/N_Clipboard.log")
    #endif
    
    log.addDestination(ConsoleDestination())
    log.addDestination(fileDest)
    
    return log
}()

