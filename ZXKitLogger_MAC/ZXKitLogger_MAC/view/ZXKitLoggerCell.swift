//
//  ZXKitLoggerCell.swift
//  ZXKitLogger_MAC
//
//  Created by Damon on 2022/7/30.
//

import SwiftUI

struct ZXKitLoggerCell: View {
    var item: (Int, ZXKitLogType, String)
    
    var body: some View {
        Text(item.2)
            .frame(maxWidth: .infinity)
            .foregroundColor(item.1.color())
            
    }
}

struct ZXKitLoggerCell_Previews: PreviewProvider {
    static var previews: some View {
        ZXKitLoggerCell(item: (0, ZXKitLogType.debug, ""))
    }
}
