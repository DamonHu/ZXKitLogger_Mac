//
//  ZXKitLoggerList.swift
//  ZXKitLogger_MAC
//
//  Created by Damon on 2022/7/30.
//

import SwiftUI

struct ZXKitLoggerList: View {
    @Binding var list: [ZXKitLoggerItem]
    @State private var typeText: String = ""
    @State private var searchText: String = ""
    @State private var showList: [ZXKitLoggerItem] = []
    
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            Text("搜索")
                .frame(width: 50, alignment: .center)
            TextField("输入查找内容，回车确定", text: $typeText, onCommit: {
                    self.searchText = self.typeText
                    self._filter()
                })
                .frame(height: 24)
                .border(.gray, width: 0.5)
                .textFieldStyle(.plain)
            Button("重置") {
                self.typeText = ""
                self.searchText = ""
            }.frame(height: 30)
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 20))
        }.padding(EdgeInsets(top: 5, leading: 0, bottom: 0, trailing: 0))
        if searchText.isEmpty {
            List(list, id: \.identifier) { item in
                ZXKitLoggerCell(item: item)
            }.padding(EdgeInsets(top: 5, leading: 0, bottom: 0, trailing: 0))
        } else {
            List(showList, id: \.identifier) { item in
                ZXKitLoggerCell(item: item)
            }.padding(EdgeInsets(top: 5, leading: 0, bottom: 0, trailing: 0))
        }
    }
}

private extension ZXKitLoggerList {
    func _filter() {
        if !self.searchText.isEmpty {
            self.showList = list.filter({ item in
                item.getFullContentString().contains(self.searchText)
            })
        }
    }
}

struct ZXKitLoggerList_Previews: PreviewProvider {
    static var previews: some View {
        ZXKitLoggerList(list: .constant([]))
    }
}
