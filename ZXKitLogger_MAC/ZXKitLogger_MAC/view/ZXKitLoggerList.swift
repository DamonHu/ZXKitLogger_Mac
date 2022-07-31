//
//  ZXKitLoggerList.swift
//  ZXKitLogger_MAC
//
//  Created by Damon on 2022/7/30.
//

import SwiftUI

struct ZXKitLoggerList: View {
    @Binding var list: [(Int, ZXKitLogType, String)]
    
    var body: some View {
        List(list, id: \.0) { item in
            ZXKitLoggerCell(item: item)
        }
    }
}

struct ZXKitLoggerList_Previews: PreviewProvider {
    static var previews: some View {
        ZXKitLoggerList(list: .constant([]))
    }
}
