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
            HStack(alignment: .center, spacing: 10) {
                Text("")
                    .padding()
                    .frame(width: 5, height: 16, alignment: .center)
                    .background(item.mLogItemType.color())
                    .cornerRadius(6)
                Text(item.getCreateTime())
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            Text(item.getFullContentString())
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(Color.white)
                .background(item.mLogItemType.color())
                .onTapGesture {
                    let pasteBoard = NSPasteboard.general
                    pasteBoard.clearContents()
                    pasteBoard.setString(item.getFullContentString(), forType: .string)
                }
                .cornerRadius(6)
        }
    }
}

struct ZXKitLoggerCell_Previews: PreviewProvider {
    static var previews: some View {
        ZXKitLoggerCell(item: ZXKitLoggerItem())
    }
}
