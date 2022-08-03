//
//  NavMenuListView.swift
//  ZXKitLogger_MAC
//
//  Created by Damon on 2022/7/30.
//

import SwiftUI

struct NavMenuListView: View {
    @Environment(\.openURL) var openURL
    @Binding var list: [ZXKitLoggerItem]    //显示在列表的log
    @Binding var isLocal: Bool
    @State private var domainText = ZXKitLogger.socketDomain
    @State private var typeText = ZXKitLogger.socketType
    @State private var fileList: [URL] = [] {
        willSet {
            let pathList = newValue.compactMap({ url in
                try? url.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
            })
            UserDefaults.standard.set(pathList, forKey: "zxkitlogger_mac_file_path_list")
        }
    }
    @State private var remoteList: [String] = []
    @State private  var remoteLogList: [String: [ZXKitLoggerItem]] = [:]    //远程接受到的所有log
    @State private var selectedPath: String? {
        willSet {
            if let path = newValue {
                if isLocal {
                    print(path)
                    let tool = SQLiteTool(path: URL.init(fileURLWithPath: path))
                    list = tool.getAllLog()
                } else {
                    list = remoteLogList[path] ?? []
                }
            } else {
                list = []
            }
        }
    }
    @State private var dragOver = false
    @State private var showAlert = false
    @State private var isEditConfig = false  //是否编辑修改
    @State private var isConnecting = false  //是否在连接远程服务器
    
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
                            self.fileList = []
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
                Image("icon_login_cicada")
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
                
            }.onAppear {
                if let pathBookDataList = UserDefaults.standard.object(forKey: "zxkitlogger_mac_file_path_list") as? [Data] {
                    self.fileList = pathBookDataList.compactMap({ data in
                        var isStale = false
                        let url = try? URL(resolvingBookmarkData: data, options: [.withSecurityScope, .withoutUI], relativeTo: nil, bookmarkDataIsStale: &isStale)
                        if !isStale, url?.startAccessingSecurityScopedResource() == true {
                            return url
                        }
                        return nil
                    })
                }
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
                    if isEditConfig {
                        HStack(alignment: .center, spacing: 4) {
                            Text("domain")
                                .frame(width: 50, alignment: .center)
                            TextField("local", text: $domainText)
                                .frame(height: 24)
                                .border(.gray, width: 0.5)
                                .textFieldStyle(.plain)
                                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 10))

                        }
                        HStack(alignment: .center, spacing: 4) {
                            Text("type")
                                .frame(width: 50, alignment: .center)
                            TextField("_zxkitlogger", text: $typeText)
                                .frame(height: 24)
                                .border(.gray, width: 0.5)
                                .textFieldStyle(.plain)
                                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 10))
                        }
                    }
                    HStack(alignment: .center, spacing: 4) {
                        if isEditConfig {
                            Button("确定") {
                                isEditConfig = false
                                ZXKitLogger.socketDomain = domainText
                                ZXKitLogger.socketType = typeText

                                self._startSocketConnect()
                            }.foregroundColor(.white)
                                .background(.green)
                                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 10))
                                .frame(height: 40)
                            Button("取消") {
                                isEditConfig = false
                            }.foregroundColor(.white)
                                .background(.gray)
                                .frame(height: 40)
                        } else {
                            Button("修改socket参数") {
                                isEditConfig = true
                            }.padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 10))
                                .frame(height: 40)
                            Button("刷新") {
                                self._startSocketConnect()
                            }.frame(height: 40)
                        }
                    }.frame(maxWidth: .infinity)
                    //服务器列表
                    List(self.remoteList, id: \.hashValue) { i in
                        NavRemoteMenuItemView(title: i, selectedPath: $selectedPath)
                            .onTapGesture {
                                selectedPath = i
                            }
                    }
                }
                if isConnecting {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .offset(y: -40)
                } else {
                    Image("icon_login_cicada")
                        .resizable()
                        .frame(width: 50, height: 50, alignment: .center)
                        .offset(y: -40)
                }
                Button("GitHub") {
                    openURL(URL(string: "https://github.com/DamonHu/ZXKitLogger_Mac")!)
                }.offset(y: -30)
            }
        }
    }
}

private extension NavMenuListView {
    func _startSocketConnect() {
        self.isConnecting = true
        ZXKitLoggerBonjour.shared.bonjourDidConnectHandler = { name, host, port in
            self.isConnecting = false
            let title = "\(name) - \(host): \(port)"
            if !remoteList.contains(title) {
                remoteList.append(title)
            }
            self.selectedPath = title
        }
        ZXKitLoggerBonjour.shared.socketDidReceiveHandler = { host, port, item in
            //插入全局
            if let selectedPath = self.selectedPath {
                var list = remoteLogList[selectedPath] ?? []
                list.insert(item, at: 0)
                remoteLogList[selectedPath] = list
                if selectedPath.contains("\(host): \(port)") {
                    self.list.insert(item, at: 0)
                }
            }
        }
        ZXKitLoggerBonjour.shared.start()
    }
}

struct NavMenuListView_Previews: PreviewProvider {
    static var previews: some View {
        NavMenuListView(list: .constant([]), isLocal: .constant(true))
    }
}
