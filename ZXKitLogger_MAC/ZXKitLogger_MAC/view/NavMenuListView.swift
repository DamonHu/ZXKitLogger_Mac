//
//  NavMenuListView.swift
//  ZXKitLogger_MAC
//
//  Created by Damon on 2022/7/30.
//

import SwiftUI

struct NavMenuListView: View {
    @Environment(\.openURL) var openURL
    @Binding var list: [ZXKitLoggerItem]
    @Binding var isLocal: Bool
    @State var domainText = ZXKitLogger.socketDomain
    @State var typeText = ZXKitLogger.socketType
    @State private var fileList: [URL] = []
    @State private var remoteList: [String] = []
    @State private var selectedPath: String? {
        willSet {
            if let path = newValue {
                let tool = SQLiteTool(path: URL.init(fileURLWithPath: path))
                list = tool.getAllLog()
            } else {
                list = []
            }
        }
    }
    @State private var dragOver = false
    @State private var showAlert = false
    
    var body: some View {
        if isLocal {
            VStack(alignment: .center, spacing: 10) {
                HStack(alignment: .center, spacing: 0) {
                    Button("本地日志") {
                        self.isLocal = true
                        self.selectedPath = nil
                    }.background(isLocal ? .green : .gray)
                        .foregroundColor(.white)
                        .frame(height: 40)
                    Button("远程日志") {
                        self.selectedPath = nil
                        self.isLocal = false
                    }.background(isLocal ? .gray : .green)
                        .foregroundColor(.white)
                        .frame(height: 40)
                }.frame(maxWidth: .infinity, alignment: .center)
                if !self.fileList.isEmpty {
                    Image("delete")
                        .resizable()
                        .frame(width: 20, height: 20, alignment: .center)
                        .onTapGesture {
                            print("delete")
                            self.selectedPath = nil
                        }
                }
                VStack(alignment: .trailing, spacing: 10) {
                    List(self.fileList, id: \.path) { i in
                        NavMenuItemView(url: i, selectedPath: $selectedPath)
                            .onTapGesture {
                                selectedPath = i.path
                            }
                    }
                    if self.fileList.isEmpty {
                        List {
                            Text("drag file to here")
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                }
                Image("82921884")
                    .resizable()
                    .frame(width: 50, height: 50, alignment: .center)
                    .offset(y: -40)
                Button("GitHub") {
                    openURL(URL(string: "https://github.com/DamonHu/ZXKitLogger_Mac")!)
                }.offset(y: -30)
            }.onDrop(of: ["public.file-url"], isTargeted: $dragOver) { providers in
                providers.first?.loadDataRepresentation(forTypeIdentifier: "public.file-url", completionHandler: { (data, error) in
                    
                    if let data = data, let path = String(data: data, encoding: String.Encoding.utf8), let url = URL(string: path) {
                        if !url.pathExtension.hasPrefix("db") && !url.pathExtension.hasPrefix("json") {
                            showAlert = true
                            return
                        }
                        selectedPath = url.path
                        if !self.fileList.contains(url) {
                            self.fileList.insert(url, at: 0)
                        }
                    }
                })
                return true
            }.alert("仅支持.db和.json文件", isPresented: $showAlert) {
                
            }
        } else {
            VStack(alignment: .center, spacing: 10) {
                HStack(alignment: .center, spacing: 0) {
                    Button("本地日志") {
                        self.isLocal = true
                        self.selectedPath = nil
                    }.background(isLocal ? .green : .gray)
                        .foregroundColor(.white)
                        .frame(height: 40)
                    Button("远程日志") {
                        self.isLocal = false
                        self.selectedPath = nil
                    }.background(isLocal ? .gray : .green)
                        .foregroundColor(.white)
                        .frame(height: 40)
                }.frame(maxWidth: .infinity, alignment: .center)
                VStack(alignment: .trailing, spacing: 10) {
                    HStack(alignment: .center, spacing: 4) {
                        Text("domain")
                            .frame(width: 50, alignment: .center)
                        TextField("local", text: $domainText)
                            .frame(height: 30)
                            .border(.gray, width: 0.5)
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 10))
                        
                    }
                    HStack(alignment: .center, spacing: 4) {
                        Text("type")
                            .frame(width: 50, alignment: .center)
                        TextField("_zxkitlogger", text: $typeText)
                            .frame(height: 30)
                            .border(.gray, width: 0.5)
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 10))
                    }
                    HStack(alignment: .center, spacing: 4) {
                        Button("连接") {
                            //                                                    ZXKitLogger.socketHost = domainText
                            //                                                    ZXKitLogger.socketPort = UInt16(typeText) ?? 888
                            //                                                    ZXKitloggerClientSocket.shared.socketDidReceiveHandler = { item in
                            //                                                        self.list.insert(item, at: 0)
                            //                                                    }
                            ZXKitLogger.socketDomain = domainText
                            ZXKitLogger.socketType = typeText
                            ZXKitLoggerBonjour.shared.socketDidReceiveHandler = { item in
                                print("insert item", item.mLogItemType)
                                self.list.insert(item, at: 0)
                                print(self.list)
                            }
                            ZXKitLoggerBonjour.shared.start()
                            ZXKitLoggerBonjour.shared.start()
                        }.background(.green)
                            .foregroundColor(.white)
                            .frame(height: 40)
                    }
                    List(self.remoteList, id: \.hashValue) { i in
                        NavRemoteMenuItemView(title: i, selectedPath: $selectedPath)
                            .onTapGesture {
                                selectedPath = i
                            }
                    }
                    if self.fileList.isEmpty {
                        List {
                            Button("刷新") {
                                ZXKitLoggerBonjour.shared.socketDidReceiveHandler = { item in
                                    print("insert item", item.mLogItemType)
                                    self.list.insert(item, at: 0)
                                    print(self.list)
                                }
                                ZXKitLoggerBonjour.shared.start()
                            }.frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                }
                Image("82921884")
                    .resizable()
                    .frame(width: 50, height: 50, alignment: .center)
                    .offset(y: -40)
                Button("GitHub") {
                    openURL(URL(string: "https://github.com/DamonHu/ZXKitLogger_Mac")!)
                }.offset(y: -30)
            }
        }
    }
}

struct NavMenuListView_Previews: PreviewProvider {
    static var previews: some View {
        NavMenuListView(list: .constant([]), isLocal: .constant(true))
    }
}
