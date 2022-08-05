//
//  LogParseTool.swift
//  ZXKitLogger_MAC
//
//  Created by Damon on 2022/8/5.
//

import Foundation

class LogParseTool {
    private var logPath: URL

    init(path: URL) {
        self.logPath = path
    }

    func getAllLog() -> [ZXKitLoggerItem] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        //TODO: 格式化数据并解析
        if let contentData = try? Data(contentsOf: self.logPath), let content = String(data: contentData, encoding: .utf8) {
            let item = ZXKitLoggerItem()
            item.updateLogContent(type: .debug, content: content)
            return [item]
        }
        return []
    }
}
