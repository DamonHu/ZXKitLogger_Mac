//
//  NavMenuListView.swift
//  ZXKitLogger_MAC
//
//  Created by Damon on 2022/7/30.
//

import SwiftUI

struct NavMenuListView: View {
    @Environment(\.openURL) var openURL
    var titleList: [String]?
    @Binding var selectedIndex: Int
    @State private var dragOver = false
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            VStack(alignment: .trailing, spacing: 10) {
                if let titleList = titleList {
                    List(0..<titleList.count) { i in
                        NavMenuItemView(title: titleList[i], index: i, selectedIndex: $selectedIndex)
                    }
                } else {
                    Text("drag ZXKitLogger File")
                }
            }
            Image("82921884")
                .resizable()
                .frame(width: 50, height: 50, alignment: .center)
                .offset(y: -40)
            Button("GitHub") {
                print("mmmm")
                openURL(URL(string: ""))
            }.offset(y: -30)
            
        }.onDrop(of: ["public.file-url"], isTargeted: $dragOver) { providers in
            providers.first?.loadDataRepresentation(forTypeIdentifier: "public.file-url", completionHandler: { (data, error) in
                
                if let data = data, let path = NSString(data: data, encoding: 4), let url = URL(string: path as String) {
                    print(url)
//                    let image = NSImage(contentsOf: url)
//
//                    DispatchQueue.main.async {
//
//                        self.image = image
//
//                    }
                    
                }
                
            })
            return true
        }
    }
}

struct NavMenuListView_Previews: PreviewProvider {
    static var previews: some View {
        NavMenuListView(titleList: ["11111", "22222", "3333"], selectedIndex: .constant(0))
    }
}
