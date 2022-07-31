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
        VStack(alignment: .trailing, spacing: 10) {
            Text(item.getCreateTime())
                .frame(maxWidth: .infinity, alignment: .center)
            Text(item.getFullContentString())
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(Color.white)
                .background(item.mLogItemType.color())
                .onTapGesture {
                    let pasteBoard = NSPasteboard.general
                    pasteBoard.clearContents()
                    pasteBoard.setString(item.getFullContentString(), forType: .string)
                }
        }
    }
}

struct ZXKitLoggerCell_Previews: PreviewProvider {
    static var previews: some View {
        ZXKitLoggerCell(item: ZXKitLoggerItem())
    }
}
