//
//  NavRemoteMenuItemView.swift
//  ZXKitLogger_MAC
//
//  Created by Damon on 2022/8/2.
//

import SwiftUI

struct NavRemoteMenuItemView: View {
    var title: String
    @Binding var selectedPath: String?

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            Circle()
                .foregroundColor(selectedPath == title ? .green : .gray)
                .frame(width: 10, height: 10, alignment: .leading)
            Text(title)
                .foregroundColor(selectedPath == title ? .black : .gray)
                .lineLimit(2)
        }

    }
}

struct NavRemoteMenuItemView_Previews: PreviewProvider {
    static var previews: some View {
        NavRemoteMenuItemView(title:"", selectedPath: .constant(""))
    }
}
