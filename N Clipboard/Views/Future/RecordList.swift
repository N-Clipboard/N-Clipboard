//
//  RecordList.swift
//  swiftui_lab
//
//  Created by poor branson on 2020/4/30.
//  Copyright © 2020 poor branson. All rights reserved.
//
#if USE_SWIFTUI
import SwiftUI
import RealmSwift

struct RecordList: View {
    var selectedID: Date?
    var list: Results<HistoryItem>
    @EnvironmentObject var shared: SharedData
    
    var body: some View {
        /**
         ForEach view has to be nested in List otherwise will result in performance issue
         */
        List {
            ForEach(list) { item in
                VStack(spacing: 0) {
                    ItemRow(item: item, selectedID: self.selectedID ?? Date())
                        .environmentObject(self.shared)
                    Divider()
                }
                .padding(EdgeInsets(top: -4, leading: -8, bottom: -4, trailing: -8))
            }
        }
    }
}

struct MyList_Previews: PreviewProvider {
    static var previews: some View {
        RecordList(selectedID: SharedData.shared.historyList.first?.createdAt, list: SharedData.shared.historyList)
            .environmentObject(SharedData.shared)
    }
}
#endif
