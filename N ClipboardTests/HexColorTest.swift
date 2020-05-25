//
//  HexColorTest.swift
//  N ClipboardTests
//
//  Created by poor branson on 2020/5/20.
//  Copyright © 2020 poor-branson. All rights reserved.
//

import XCTest
import SwiftHEXColors

class HexColorTest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testInvalidColor() throws {
        let color = NSColor(hexString: "#ffs")
        XCTAssert(color == nil)
    }

}
