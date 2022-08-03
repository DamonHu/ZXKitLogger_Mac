//
//  ZXKitLoggerList.swift
//  ZXKitLogger_MAC
//
//  Created by Damon on 2022/7/30.
//

import SwiftUI

struct ZXKitLoggerList: View {
    @Binding var list: [ZXKitLoggerItem]

    var body: some View {
        List(list, id: \.identifier) { item in
            ZXKitLoggerCell(item: item)
        }.padding(EdgeInsets(top: 30, leading: 0, bottom: 30, trailing: 0))
    }
}

struct ZXKitLoggerList_Previews: PreviewProvider {
    static var previews: some View {
        ZXKitLoggerList(list: .constant([]))
    }
}
