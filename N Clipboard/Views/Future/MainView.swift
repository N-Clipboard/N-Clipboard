//
//  MainView.swift
//  swiftui_lab
//
//  Created by poor branson on 2020/4/30.
//  Copyright © 2020 poor branson. All rights reserved.
//
#if USE_SWIFTUI
import SwiftUI
import RealmSwift
import Quartz

fileprivate let realm = try! Realm()

struct MainView: View {
    @State var localEventHandler: Any?
    @State var pinMode: Bool = UserDefaults.standard.bool(forKey: Constants.Userdefaults.ShouldStickOnTop)
    @State var currentIndex: Int = 0
    var shared = SharedData.shared
    var selectedID: Date? {
        return list.count > 0 ? list[currentIndex].createdAt : nil
    }
    var list: Results<HistoryItem> {
        shared
            .historyList.filter(NSPredicate(format: "content LIKE[c] %@ OR title LIKE[c] %@", "*\(shared.keyword)*", "*\(shared.keyword)*"))
            .sorted(byKeyPath: "updatedAt", ascending: false)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                HStack(alignment: .top) {
                    Spacer()
                    Text(Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String)
                        .padding(EdgeInsets(top: 4, leading: 0, bottom: 0, trailing: 0))
                    Spacer()
                    Button(action: {
                        self.pinMode = !self.pinMode
                        UserDefaults.standard.set(self.pinMode, forKey: Constants.Userdefaults.ShouldStickOnTop)
                    }) {
                        Image(pinMode ? "pin_invert" : "pin")
                            .resizable()
                            .frame(maxWidth: 18, maxHeight: 18, alignment: .center)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 6))
                }
                .padding(EdgeInsets(top: 0, leading: 6, bottom: 12, trailing: 6))
                
                TextField("Search...", text: $shared.keyword)
                    .padding(EdgeInsets(top: 0, leading: 6, bottom: 6, trailing: 6))
                    .onReceive(shared.$keyword) { (output) in
                        self.currentIndex = 0
                }
            }
            .background(NCVisualEffect(material: .appearanceBased, blendingMode: .behindWindow))
            
            if list.count > 0 {
                RecordList(selectedID: selectedID, list: list)
                    .environmentObject(shared)
            } else {
                VStack(alignment: .center) {
                    Image("empty")
                        .resizable()
                        .frame(width: 120, height: 120, alignment: .center)
                        .opacity(0.6)
                    Text("Empty")
                        .opacity(0.6)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
        }
        .edgesIgnoringSafeArea([.top])
        .frame(minWidth: 320, idealWidth: 480, maxWidth: .infinity, minHeight: 580, idealHeight: 580, maxHeight: .infinity, alignment: .topLeading)
        .onReceive(shared.$tappedItemDate, perform: { (output) in
            self.currentIndex = self.list.index(matching: NSPredicate(format: "updatedAt == %@", (output as Date) as CVarArg)) ?? 0
        })
            .onAppear(perform: {
                LogService.warning("Will add local monitor")
                self.localEventHandler = NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .leftMouseDown], handler: { (event) -> NSEvent? in
                    let currentIndex = self.currentIndex
                    let didHandle = EventHandler()
                        .onFocus {
                            print("focus")
                    }.onPaste {
                        if self.list.count > 0 {
                            NSApp.deactivate()
                            ClipBoardService.shared.write(of: self.list[currentIndex])
                            try! realm.write {
                                self.list[currentIndex].updatedAt = Date()
                                self.currentIndex = 0
                            }
                        }
                    }.onDelete {
                        if self.list.count > 0 && currentIndex < self.list.count {
                            self.currentIndex = 0
                            do {
                                try self.list[currentIndex].ncDestroy()
                            } catch {
                                print(error)
                            }
                        }
                    }.onArrowUp {
                        if currentIndex > 0 {
                            self.currentIndex -= 1
                        }
                        print("arrowup")
                    }
                    .onOverview {
                        print("overview")
                    }
                    .onArrowDown {
                        print("arrow down")
                        if currentIndex < self.list.count - 1 {
                            self.currentIndex += 1
                        }
                    }.assert(event)
                        .didHandle
                    
                    return didHandle ? nil : event
                })
            })
            .onDisappear {
                print("will disappear")
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
#endif
