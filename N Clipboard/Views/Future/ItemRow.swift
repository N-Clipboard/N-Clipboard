//
//  ItemRow.swift
//  swiftui_lab
//
//  Created by poor branson on 2020/4/30.
//  Copyright © 2020 poor branson. All rights reserved.
//
#if USE_SWIFTUI
import SwiftUI
import RealmSwift

fileprivate let realm = try! Realm()

struct ItemRow: View {
    var item: HistoryItem
    var selectedID: Date
    var isSelected: Bool {
        item.createdAt == selectedID
    }
    var useColor: Color {
        if isSelected {
            return Color.blue
        }
        return isOnHover ? Color(NSColor(red: 0.28, green: 0.29, blue: 0.28, alpha: 1.00)) : Color.clear
    }
    var icon: NSImage? {
        item.thumbnail != nil ? NSImage(data: item.thumbnail!) : Utility.findAppIcon(by: item.bundleIdentifier ?? "")
    }
    var typeValidator: ContentValidator {
        .init(item)
    }
    @State var isOnHover: Bool = false;
    @EnvironmentObject var shared: SharedData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("\(item.updatedAt.timeAgo()) ago")
                    .font(Font.system(size: 11, weight: .medium))
                    .foregroundColor(Color(NSColor(red: 0.72, green: 0.72, blue: 0.72, alpha: 1.00)))

                Spacer()
                if isOnHover {
                    if typeValidator.isURL {
                        Button(action: {
                            if let url = URL(string: self.item.content) {
                                NSWorkspace.shared.open(url)
                            }
                        }) {
                            Image("browser")
                                .resizable()
                                .frame(maxWidth: 16, maxHeight: 16, alignment: .center)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    if typeValidator.isFileURL {
                        Button(action: {
                            guard self.item.fileURL != nil else { return }
                            self.typeValidator.select(of: self.item.fileURL!)
                        }) {
                            Image("icon_finder")
                                .resizable()
                                .frame(maxWidth: 14, maxHeight: 14, alignment: .center)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    if typeValidator.isFileURL || typeValidator.isURL {
                        Button(action: {
                            self.shared.tappedItemDate = self.item.updatedAt
                            (NSApp.delegate as! AppDelegate).showPreview()
                        }) {
                            Image("icon_preview")
                                .resizable()
                                .frame(maxWidth: 16, maxHeight: 16, alignment: .center)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                if isOnHover || item.isMarked {
                    Button(action: {
                        try! realm.write {
                            self.item.isMarked = !self.item.isMarked
                        }
                    }) {
                        Image(item.isMarked ? "mark_fill" : "mark")
                            .resizable()
                            .frame(maxWidth: 12, maxHeight: 14, alignment: .center)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }.frame(height: 20, alignment: .center)
            HStack(alignment: .top) {
                Image(nsImage: icon ?? NSImage(imageLiteralResourceName: "AppIcon"))
                    .resizable()
                    .frame(minWidth: 0, maxWidth: 48, minHeight: 0, maxHeight: 48, alignment: .center)
                Text(item.content)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 62, maxHeight: 62, alignment: .leading)
            .padding(EdgeInsets(top: -6, leading: 0, bottom: 0, trailing: 0))
            
        }
        .padding(EdgeInsets(top: 6, leading: 12, bottom: 0, trailing: 12))
        .background(useColor)
        .onHover { (isHover) in
            self.isOnHover = isHover
        }
        .onTapGesture {
            self.shared.tappedItemDate = self.item.updatedAt
        }
    }
}

struct ItemRow_Previews: PreviewProvider {
    static var item: HistoryItem {
        let item = HistoryItem(content: "/User/branson/Desktop")
        item.pasteboardType = .fileURL
        
        return item
    }
    static var previews: some View {
        ItemRow(item: ItemRow_Previews.item, selectedID: Date())
            .environmentObject(SharedData.shared)
    }
}
#endif
