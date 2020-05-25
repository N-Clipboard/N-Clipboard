//
//  NCPopoverView.swift
//  N Clipboard
//
//  Created by poor branson on 2020/5/3.
//  Copyright © 2020 poor-branson. All rights reserved.
//

import SwiftUI
import RealmSwift

struct NCPopoverView: View {
    var itemCount: Int = 0
    var isActivate = Binding<Bool>(get: { Utility.isActivated }, set: { Utility.isActivated = $0 })
    var list = try! Realm().objects(HistoryItem.self)
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Toggle("Status", isOn: isActivate)
                    .toggleStyle(SwitchToggleStyle())
                
                Spacer()
                
                Button(action: {
                    (NSApp.delegate as? AppDelegate)?.confirmBeforeCleanClipBoard()
                }) {
                    Image("trash")
                        .resizable()
                        .frame(maxWidth: 24, maxHeight: 24, alignment: .center)
                }
                .buttonStyle(PlainButtonStyle())
                Divider()
                    .frame(height: 22)
                Button(action: {
                    (NSApp.delegate as? AppDelegate)?.showPreferencePanel()
                }) {
                    Image("settings")
                        .resizable()
                        .frame(maxWidth: 20, maxHeight: 20, alignment: .center)
                }
                .buttonStyle(PlainButtonStyle())
                Divider()
                    .frame(height: 22)
                Button(action: {
                    NSApp.terminate(self)
                }) {
                    Image("exit")
                        .resizable()
                        .frame(width: 22, height: 22, alignment: .center)
                        .colorMultiply(Color.white)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(6)
            .background(NCVisualEffect(material: .contentBackground, blendingMode: .withinWindow))
            
            HStack {
                Spacer()
                Text("Pasteboard:")
                Divider()
                Text("\(list.count)")
                    .font(Font.system(size: 22))
//                Spacer()
//                Text("Snippet")
//                Divider()
//                Text("\(itemCount)")
//                    .font(Font.system(size: 22))
                Spacer()
            }
            .padding(6)
        }
        .frame(width: 320, height: 120, alignment: .top)
    }
}

struct NCPopoverView_Previews: PreviewProvider {
    static var previews: some View {
        NCPopoverView()
    }
}
