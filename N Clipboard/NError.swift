//
//  NError.swift
//  N Clip Board
//
//  Created by branson on 2019/9/13.
//  Copyright © 2019 branson. All rights reserved.
//

import Cocoa

enum NError: Error {
    case ClipBoardTimerHasSetted
    case FileAlreadyBeenWatched
    case InValidActivationKey
    case EntityNotExist
    case InvalidEntityRawValue
    case EntityHaveNoData
}
