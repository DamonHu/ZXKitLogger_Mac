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
            let contentList = content.split(separator: "\n")

            var titleIndexList = [Int]()
            for i in 0..<contentList.count {
                let item = contentList[i]
                //判断时间
                if self.isTitle(log: String(item)) {
                    titleIndexList.append(i)
                }
            }

            //数据
            var logList = [ZXKitLoggerItem]()
            for i in 0..<titleIndexList.count {
                let titleIndex = titleIndexList[i]
                //组装数据
                let title = String(contentList[titleIndex])
                let item = ZXKitLoggerItem()
                //时间
                let timeString = title.subString(rang: NSRange(location: 0, length: 23))
                item.mCreateDate = dateFormatter.date(from: timeString)!
                //类型
                if title.contains("✅✅") {
                    item.mLogItemType = .info
                } else if title.contains("⚠️⚠️") {
                    item.mLogItemType = .warn
                } else if title.contains("❌❌") {
                    item.mLogItemType = .error
                } else if title.contains("⛔️⛔️") {
                    item.mLogItemType = .privacy
                } else if title.contains("💜💜") {
                    item.mLogItemType = .debug
                }
                //debugContent
                item.mLogDebugContent = title.subString(rang: NSRange(location: 42, length: title.count - 42))
                //content
                if i == titleIndexList.count-1 {
                    //最后一个数组
                    let contentLog = contentList[titleIndex + 1..<contentList.endIndex].joined(separator: "\n")
                    item.updateLogContent(type: item.mLogItemType, content: contentLog)
                } else {
                    let contentLog = contentList[titleIndex + 1..<titleIndexList[i + 1]].joined(separator: "\n")
                    item.updateLogContent(type: item.mLogItemType, content: contentLog)
                }

                logList.append(item)
            }
            return logList
        }
        return []
    }
}

private extension LogParseTool {
    func isTitle(log: String) -> Bool {
        //长度解析
        guard log.count > 42 else {
            return false
        }
        //时间判断
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        let timeString = log.subString(rang: NSRange(location: 0, length: 23))
        if dateFormatter.date(from: timeString) == nil {
            return false
        }
        //类型解析
        let regex = "---- [ ✅⚠️❌⛔️💜]"
        let result = RegularExpression(regex: regex, validateString: log)
        if result.isEmpty {
            return false
        }
        //关键词匹配
        return log.contains("File:") && log.contains("Line:")
    }

    /// 正则匹配
    /// - Parameters:
    ///   - regex: 匹配规则
    ///   - validateString: 匹配对test象
    /// - Returns: 返回结果
    func RegularExpression (regex:String,validateString:String) -> [String]{
        do {
            let regex: NSRegularExpression = try NSRegularExpression(pattern: regex, options: [])
            let matches = regex.matches(in: validateString, options: [], range: NSMakeRange(0, validateString.count))

            var data:[String] = Array()
            for item in matches {
                let string = (validateString as NSString).substring(with: item.range)
                data.append(string)
            }

            return data
        }
        catch {
            return []
        }
    }
}
