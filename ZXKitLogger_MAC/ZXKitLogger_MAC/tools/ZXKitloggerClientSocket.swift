//
//  ZXKitloggerClientSocket.swift
//  ZXKitLogger_MAC
//
//  Created by Damon on 2022/8/1.
//

import Foundation
import CocoaAsyncSocket

typealias SocketDidReceiveHandler = (_ item: ZXKitLoggerItem) -> ()

class ZXKitloggerClientSocket: NSObject {
    static let shared = ZXKitloggerClientSocket()
    var socketDidReceiveHandler: SocketDidReceiveHandler?
    
    private lazy var clientSocket: GCDAsyncUdpSocket = {
        let queue = DispatchQueue.init(label: "zxkitlogger_socket")
        let socket = GCDAsyncUdpSocket(delegate: self, delegateQueue: queue, socketQueue: queue)
        return socket
    }()

    func startSocket() {
        do {
            try clientSocket.bind(toPort: ZXKitLogger.socketPort)
        } catch {
            print("socket.bind error: \(error.localizedDescription)")
        }
        do {
            try clientSocket.beginReceiving()
        } catch {
            print("socket.beginReceiving error: \(error.localizedDescription)")
        }
        //发送一条认证信息
        clientSocket.send("ZXKitLogger_auth".data(using: .utf8)!, toHost:  ZXKitLogger.socketHost, port:  ZXKitLogger.socketPort, withTimeout: 600, tag: 1)
    }

}

extension ZXKitloggerClientSocket: GCDAsyncUdpSocketDelegate {
    func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
        //接受到需要log传输的消息，记录
        guard let receiveMsg = String(data: data, encoding: .utf8), let handler = self.socketDidReceiveHandler else {
            return
        }
        var msgList = receiveMsg.split(separator: "|")
        guard msgList.count >= 4, let itemType = Int(msgList.first!)  else {
            return
        }
        let item = ZXKitLoggerItem()
        item.mLogItemType = ZXKitLogType(rawValue: itemType)
        item.mLogDebugContent = String(msgList[1])
        item.mCreateDate = Date(timeIntervalSince1970: TimeInterval(msgList[2]) ?? 0)
        msgList.removeFirst(3)
        item.updateLogContent(type: item.mLogItemType, content: msgList.joined(separator: "|"))
        handler(item)
    }
}
