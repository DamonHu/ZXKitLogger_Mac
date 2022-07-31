//
//  ZXKitLoggerList.swift
//  ZXKitLogger_MAC
//
//  Created by Damon on 2022/7/30.
//

import SwiftUI

struct ZXKitLoggerList: View {
    var list: [ZXKitLoggerItem]
    
    var body: some View {
        List(list, id: \.identifier) { item in
            ZXKitLoggerCell(item: item)
        }
    }
}

struct ZXKitLoggerList_Previews: PreviewProvider {
    static var previews: some View {
        ZXKitLoggerList(list: [ZXKitLoggerItem(), ZXKitLoggerItem(), ZXKitLoggerItem(), ZXKitLoggerItem()])
    }
}
