//
//  ZXKitLoggerCell.swift
//  ZXKitLogger_MAC
//
//  Created by Damon on 2022/7/30.
//

import SwiftUI

struct ZXKitLoggerCell: View {
    var item: ZXKitLoggerItem
    
    var body: some View {
        Text(item.getFullContentString())
            .frame(maxWidth: 400)
            .foregroundColor(.red)
    }
}

struct ZXKitLoggerCell_Previews: PreviewProvider {
    static var previews: some View {
        ZXKitLoggerCell(item: ZXKitLoggerItem())
    }
}
