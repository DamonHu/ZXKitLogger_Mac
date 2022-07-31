//
//  ContentView.swift
//  ZXKitLogger_MAC
//
//  Created by Damon on 2022/7/30.
//

import SwiftUI

struct ContentView: View {
    
    
    @State var logList: [ZXKitLoggerItem] = [ZXKitLoggerItem(), ZXKitLoggerItem(), ZXKitLoggerItem(), ZXKitLoggerItem(), ZXKitLoggerItem()]
    var body: some View {
        NavigationView {
            NavMenuListView()
            ZXKitLoggerList(list: [ZXKitLoggerItem(), ZXKitLoggerItem(), ZXKitLoggerItem(), ZXKitLoggerItem(), ZXKitLoggerItem(), ZXKitLoggerItem(), ZXKitLoggerItem(), ZXKitLoggerItem(), ZXKitLoggerItem(), ZXKitLoggerItem(), ZXKitLoggerItem(), ZXKitLoggerItem()])
        }.navigationTitle("ZXKitLogger")
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
