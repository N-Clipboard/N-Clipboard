//
//  About.swift
//  N Clipboard
//
//  Created by poor branson on 2020/5/6.
//  Copyright © 2020 poor-branson. All rights reserved.
//

import SwiftUI

struct AboutView: View {
    var version: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unknown"
    }
    var bundleVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "Unknown"
    }

    var body: some View {
        VStack {
            Image(nsImage: NSImage(imageLiteralResourceName: "AppIcon"))
                .resizable()
                .frame(width: 128, height: 128, alignment: .center)
            Text("N Clipboard")
                .fontWeight(.bold)
                .padding(.bottom, 12)

            Text("Version \(version) (build - \(bundleVersion))")
                .font(Font.system(size: 10))
            Text("About Project")
                .underline()
                .onTapGesture {
                    NSWorkspace.shared.open(URL(string: "https://github.com/N-Clipboard/N-Clipboard")!)
            }
        }
        .frame(width: 420, height: 260, alignment: .center)
    }
}

struct About_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
