//
//  NavMenuListView.swift
//  ZXKitLogger_MAC
//
//  Created by Damon on 2022/7/30.
//

import SwiftUI
import CommonCrypto
#if canImport(CryptoKit)
import CryptoKit
#endif

struct NavMenuListView: View {
    @Environment(\.openURL) var openURL
    @Binding var list: [ZXKitLoggerItem]    //显示在列表的log
    @Binding var isLocal: Bool
    //本地加密配置
    @State private var privacyLogPassword = UserDefaults.standard.string(forKey: UserDefaultsKey.privacyLogPassword.rawValue) ?? ZXKitLogger.privacyLogPassword
    @State private var privacyLogIv = UserDefaults.standard.string(forKey: UserDefaultsKey.privacyLogIv.rawValue) ?? ZXKitLogger.privacyLogIv
    @State private var isEncodeBase64 = UserDefaults.standard.bool(forKey: UserDefaultsKey.isEncodeBase64.rawValue)
    //服务器配置
    @State private var domainText = UserDefaults.standard.string(forKey: UserDefaultsKey.domain.rawValue) ?? ZXKitLogger.socketDomain
    @State private var typeText =  UserDefaults.standard.string(forKey: UserDefaultsKey.socketType.rawValue) ?? ZXKitLogger.socketType
    @State private var fileList: [URL] = [] {
        willSet {
            let pathList = newValue.compactMap({ url in
                try? url.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
            })
            UserDefaults.standard.set(pathList, forKey: UserDefaultsKey.fileListHistory.rawValue)
        }
    }
    @State private var remoteList: [String] = []
    @State private  var remoteLogList: [String: [ZXKitLoggerItem]] = [:]    //远程接受到的所有log
    @State private var selectedPath: String? {
        willSet {
            if let path = newValue {
                if isLocal {
                    print(path)
                    if path.hasPrefix(".db") {
                        let tool = SQLiteTool(path: URL.init(fileURLWithPath: path))
                        list = tool.getAllLog()
                    } else {
                        let tool = LogParseTool(path: URL.init(fileURLWithPath: path))
                        list = tool.getAllLog()
                    }
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
    @State private var isPrivacyError = false
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            HStack(alignment: .center, spacing: 0) {
                Button("本地日志") {
                    self.isConnecting = false
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
                Image("icon_setting")
                    .resizable()
                    .frame(width: 20, height: 20, alignment: .center)
                    .onTapGesture {
                        //设置
                        print("点击设置")
                        isEditConfig = !isEditConfig
                    }.padding()
                if self.isLocal {
                    Image("icon_delete")
                        .resizable()
                        .frame(width: 20, height: 20, alignment: .center)
                        .onTapGesture {
                            print("delete")
                            self.fileList = []
                            self.selectedPath = nil
                        }
                } else {
                    Image("icon_refresh")
                        .resizable()
                        .frame(width: 20, height: 20, alignment: .center)
                        .onTapGesture {
                            print("刷新")
                            ZXKitLogger.socketDomain = domainText
                            ZXKitLogger.socketType = typeText
                            self._startSocketConnect()
                        }
                }
            }.frame(maxWidth: .infinity, alignment: .center)
            //中间内容布局
            if isEditConfig {
                VStack(alignment: .leading, spacing: 10) {
                    //解密配置
                    HStack(alignment: .center, spacing: 10) {
                        Text("")
                            .padding()
                            .frame(width: 5, height: 16, alignment: .center)
                            .background(.red)
                            .cornerRadius(6)
                        Text("加密日志参数配置")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }.padding(.leading, 10)
                    HStack(alignment: .center, spacing: 4) {
                        Text("Password")
                            .frame(width: 70, alignment: .center)
                        TextField("12345678901234561234567890123456", text: $privacyLogPassword)
                            .frame(height: 24)
                            .border(.gray, width: 0.5)
                            .textFieldStyle(.plain)
                        
                    }.padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
                    HStack(alignment: .center, spacing: 4) {
                        Text("Iv")
                            .frame(width: 70, alignment: .center)
                        TextField("abcdefghijklmnop", text: $privacyLogIv)
                            .frame(height: 24)
                            .border(.gray, width: 0.5)
                            .textFieldStyle(.plain)
                    }.padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
                    HStack(alignment: .center, spacing: 4) {
                        Text("Encode")
                            .frame(width: 70, alignment: .center)
                        HStack(alignment: .center, spacing: 0) {
                            Button("hex") {
                                self.isEncodeBase64 = false
                            }.background(isEncodeBase64 ? .gray : .green)
                                .foregroundColor(.white)
                                .frame(height: 40)
                            Button("base64") {
                                self.isEncodeBase64 = true
                            }.background(isEncodeBase64 ? .green : .gray)
                                .foregroundColor(.white)
                                .frame(height: 40)
                        }
                    }.padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
                    //远程配置
                    HStack(alignment: .center, spacing: 10) {
                        Text("")
                            .padding()
                            .frame(width: 5, height: 16, alignment: .center)
                            .background(.red)
                            .cornerRadius(6)
                        Text("远程日志配置")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }.padding(.leading, 10)
                    HStack(alignment: .center, spacing: 4) {
                        Text("Domain")
                            .frame(width: 70, alignment: .center)
                        TextField("local", text: $domainText)
                            .frame(height: 24)
                            .border(.gray, width: 0.5)
                            .textFieldStyle(.plain)
                        
                    }.padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
                    HStack(alignment: .center, spacing: 4) {
                        Text("Type")
                            .frame(width: 70, alignment: .center)
                        TextField("_zxkitlogger", text: $typeText)
                            .frame(height: 24)
                            .border(.gray, width: 0.5)
                            .textFieldStyle(.plain)
                    }.padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
                    //确定
                    HStack(alignment: .center, spacing: 4) {
                        Button("确定") {
                            if privacyLogIv.count != kCCKeySizeAES128 || (privacyLogPassword.count != kCCKeySizeAES128 && privacyLogPassword.count != kCCKeySizeAES192 && privacyLogPassword.count != kCCKeySizeAES256) {
                                isPrivacyError = true
                                return
                            }
                            isEditConfig = false
                            ZXKitLogger.socketDomain = domainText
                            ZXKitLogger.socketType = typeText
                            ZXKitLogger.privacyLogPassword = privacyLogPassword
                            ZXKitLogger.privacyLogIv = privacyLogIv
                            ZXKitLogger.privacyResultEncodeType = isEncodeBase64 ? .base64 : .hex
                            
                            UserDefaults.standard.set(domainText, forKey: UserDefaultsKey.domain.rawValue)
                            UserDefaults.standard.set(typeText, forKey: UserDefaultsKey.socketType.rawValue)
                            UserDefaults.standard.set(privacyLogPassword, forKey: UserDefaultsKey.privacyLogPassword.rawValue)
                            UserDefaults.standard.set(privacyLogIv, forKey: UserDefaultsKey.privacyLogIv.rawValue)
                            UserDefaults.standard.set(isEncodeBase64, forKey: UserDefaultsKey.isEncodeBase64.rawValue)
                            if !isLocal {
                                self._startSocketConnect()
                            }
                        }.foregroundColor(.white)
                            .background(.green)
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 10))
                            .frame(height: 40)
                            .alert("Password available length is \(kCCKeySizeAES128)、\(kCCKeySizeAES192)、\(kCCKeySizeAES256)。 \n Iv should be \(kCCKeySizeAES128) bytes", isPresented: $isPrivacyError) {
                                
                            }
                        Button("取消") {
                            isEditConfig = false
                            switch ZXKitLogger.privacyResultEncodeType {
                            case .base64:
                                isEncodeBase64 = true
                            default:
                                isEncodeBase64 = false
                            }
                        }.foregroundColor(.white)
                            .background(.gray)
                            .frame(height: 40)
                    }.frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            } else if isLocal {
                //本地日志
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
                }.onDrop(of: ["public.file-url"], isTargeted: $dragOver) { providers in
                    providers.first?.loadDataRepresentation(forTypeIdentifier: "public.file-url", completionHandler: { (data, error) in
                        if let data = data, let path = String(data: data, encoding: String.Encoding.utf8), let url = URL(string: path) {
                            if !url.pathExtension.hasPrefix("db") && !url.pathExtension.hasPrefix("log") {
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
                }.alert("仅支持.db和.log文件", isPresented: $showAlert) {
                    
                }.onAppear {
                    if let pathBookDataList = UserDefaults.standard.object(forKey: UserDefaultsKey.fileListHistory.rawValue) as? [Data] {
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
                //远程模式
                VStack(alignment: .trailing, spacing: 10) {
                    //服务器列表
                    List(self.remoteList, id: \.hashValue) { i in
                        NavRemoteMenuItemView(title: i, selectedPath: $selectedPath)
                            .onTapGesture {
                                selectedPath = i
                            }
                    }
                }
            }
            //底部
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
