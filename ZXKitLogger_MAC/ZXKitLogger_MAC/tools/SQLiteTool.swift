//
//  SQLiteTool.swift
//  ZXKitLogger_MAC
//
//  Created by Damon on 2022/7/31.
//

import Foundation
import SQLite3

class SQLiteTool {
    private var logDBPath: URL
    private var logDB: OpaquePointer?
    private var indexDB: OpaquePointer?
    
    init(path: URL) {
        self.logDBPath = path
        //开始新的数据
        self.logDB = self._openDatabase()
    }

    func getAllLog() -> [ZXKitLoggerItem] {
        let databasePath = self.logDBPath
        guard FileManager.default.fileExists(atPath: databasePath.path) else {
            //数据库文件不存在
            return []
        }
        let queryDB = self._openDatabase()
        let queryString = "SELECT * FROM hdlog;"
        var queryStatement: OpaquePointer?
        //第一步
        var logList = [ZXKitLoggerItem]()
        if sqlite3_prepare_v2(queryDB, queryString, -1, &queryStatement, nil) == SQLITE_OK {
            //第二步
            while(sqlite3_step(queryStatement) == SQLITE_ROW) {
                //第三步
                let item = ZXKitLoggerItem()
                item.id = Int(sqlite3_column_int(queryStatement, 0))
//                let logContent = sqlite3_column_text(queryStatement, 1)
                item.mLogItemType = ZXKitLogType.init(rawValue: Int(sqlite3_column_int(queryStatement, 2)))
                item.mLogDebugContent = String(cString: sqlite3_column_text(queryStatement, 4))
                //更新内容
                let contentString = String(cString: sqlite3_column_text(queryStatement, 5))
                item.updateLogContent(type: item.mLogItemType, content: contentString)
                //时间
                let time = sqlite3_column_double(queryStatement, 3)
                item.mCreateDate = Date(timeIntervalSince1970: time)
//                if let log = log {
//                    logList.append((Int(id), Int(logType), "\(String(cString: log))"))
//                }
                logList.append(item)
            }
        }
        //第四步
        sqlite3_finalize(queryStatement)
        return logList
    }
    
    func searchLog(keyword: String) -> [String] {
        return self._searchLog(keyword: keyword)
    }
    
    func deleteLog(timeStamp: Double) {
        self._deleteLog(timeStamp: timeStamp)
    }
}

private extension SQLiteTool {
    //打开数据库
    func _openDatabase() -> OpaquePointer? {
        var db: OpaquePointer?
        let dbPath = self.logDBPath
        if sqlite3_open_v2(dbPath.path, &db, SQLITE_OPEN_READWRITE|SQLITE_OPEN_CREATE|SQLITE_OPEN_FULLMUTEX, nil) == SQLITE_OK {
//            print("成功打开数据库\(dbPath.absoluteString)")
            return db
        } else {
            print("打开数据库失败")
            return nil
        }
    }
}

//MARK: - 全文搜索相关
private extension SQLiteTool {
    func _searchLog(keyword: String) -> [String] {
        let databasePath = self.logDBPath
        guard FileManager.default.fileExists(atPath: databasePath.path) else {
            //数据库文件不存在
            return [String]()
        }
        let queryDB = self.indexDB
        //TODO: 虚拟表全文查询需要分词，所以使用LIKE
//        var queryString = "SELECT * FROM logindex WHERE log MATCH '\(keyword)*'"
        var queryString = "SELECT * FROM logindex WHERE log LIKE '%\(keyword)%'"
        if keyword.isEmpty {
            queryString = "SELECT * FROM logindex"
        }
        var queryStatement: OpaquePointer?
        //第一步
        var logList = [String]()
        if sqlite3_prepare_v2(queryDB, queryString, Int32(strlen(queryString)), &queryStatement, nil) == SQLITE_OK {
            //第二步
            while(sqlite3_step(queryStatement) == SQLITE_ROW) {
                //第三步
                //虚拟表中未存储id
                let log = sqlite3_column_text(queryStatement, 0)
//                let logType = sqlite3_column_int(queryStatement, 1)
//                let time = sqlite3_column_double(queryStatement, 2)
                if let log = log {
                    logList.append("\(String(cString: log))")
                }
            }
        }
        //第四步
        sqlite3_finalize(queryStatement)
        return logList
    }
    
    func _deleteLog(timeStamp: Double) {
        print(timeStamp)
        let insertRowString = "DELETE FROM logindex WHERE time < \(timeStamp) "
        var insertStatement: OpaquePointer?
        //第一步
        let status = sqlite3_prepare_v2(self.indexDB, insertRowString, -1, &insertStatement, nil)
        if status == SQLITE_OK {
            //第三步
            if sqlite3_step(insertStatement) == SQLITE_DONE {
//                print("删除过期数据成功")
            } else {
                print("删除过期数据失败")
            }
        } else {
            print("删除时打开虚拟数据库失败")
        }
        //第四步
        sqlite3_finalize(insertStatement)
    }
}
