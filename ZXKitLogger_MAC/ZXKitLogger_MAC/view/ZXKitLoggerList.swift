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
        List(list, id: \.id) { item in
            ZXKitLoggerCell(item: item)
        }.offset(y: 30)
    }
}

struct ZXKitLoggerList_Previews: PreviewProvider {
    static var previews: some View {
        ZXKitLoggerList(list: .constant([]))
    }
}
