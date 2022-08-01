//
//  ContentView.swift
//  ZXKitLogger_MAC
//
//  Created by Damon on 2022/7/30.
//

import SwiftUI

struct ContentView: View {
    @State private var list: [ZXKitLoggerItem] = []
    @State private var isLocal = true
    
    var body: some View {
        NavigationView {
            NavMenuListView(list: $list, isLocal: $isLocal)
            ZXKitLoggerList(list: $list)
        }.navigationTitle("ZXKitLogger")
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
