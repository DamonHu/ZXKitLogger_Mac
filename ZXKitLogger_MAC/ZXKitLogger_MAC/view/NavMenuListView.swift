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
    @State private var fileList: [URL] = []
    @State private var selectedPath: String? {
        willSet {
            if let path = newValue {
                let tool = SQLiteTool(path: URL.init(fileURLWithPath: path))
                list = tool.getAllLog()
            }
        }
    }
    @State private var dragOver = false
    @State private var showAlert = false
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Image("delete")
                .resizable()
                .frame(width: 20, height: 20, alignment: .center)
                .onTapGesture {
                    print("delete")
                    self.selectedPath = nil
                    self.fileList = []
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
    }
}

struct NavMenuListView_Previews: PreviewProvider {
    static var previews: some View {
        NavMenuListView(list: .constant([]))
    }
}
