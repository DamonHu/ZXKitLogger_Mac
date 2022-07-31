//
//  NavMenuItemView.swift
//  ZXKitLogger_MAC
//
//  Created by Damon on 2022/7/30.
//

import SwiftUI

struct NavMenuItemView: View {
    var title: String
    var index: Int
    @Binding var selectedIndex: Int
    var singleTap: some Gesture {
          TapGesture()
              .onEnded { _ in
                  self.selectedIndex = index
              }
    }
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            Circle()
                .foregroundColor(selectedIndex == index ? .green : .gray)
                .frame(width: 10, height: 10, alignment: .leading)
            Text(title)
                .foregroundColor(selectedIndex == index ? .black : .gray)
                .lineLimit(2)
                .gesture(singleTap)
        }
        
    }
}

struct NavMenuItemView_Previews: PreviewProvider {
    static var previews: some View {
        NavMenuItemView(title: "1234", index: 1, selectedIndex: .constant(1))
    }
}
