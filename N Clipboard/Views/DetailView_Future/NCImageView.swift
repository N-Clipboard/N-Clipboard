//
//  NCImageView.swift
//  N Clipboard
//
//  Created by poor branson on 2020/5/9.
//  Copyright © 2020 poor-branson. All rights reserved.
//

import SwiftUI

struct NCImageView: View {
    var image: NSImage?
    var size: NSSize {
        var scaleRatioH: CGFloat = 1, scaleRatioW: CGFloat = 1
        let size = image?.size ?? NSZeroSize
        if size.width > 1366 {
            scaleRatioW = size.width / 1366
        }
        if size.height > 768 {
            scaleRatioH = size.height / 768
        }
        
        let useScaleRatio = min(scaleRatioW, scaleRatioH)
        
        return NSSize(width: size.width * useScaleRatio, height: size.height * useScaleRatio)
    }
    
    var body: some View {
        VStack {
            if image != nil {
                Image(nsImage: image!)
                    .frame(width: size.width + 10, height: size.height + 10, alignment: .center)
                    .scaledToFit()
            }
        }
    }
}

struct NCImageView_Previews: PreviewProvider {
    static var previews: some View {
        NCImageView()
    }
}
