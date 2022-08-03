//
//  ZXKitLoggerUDPSocket.swift
//  ZXKitLogger_MAC
//
//  Created by Damon on 2022/8/1.
//

import Foundation
import CocoaAsyncSocket

typealias SocketDidConnectHandler = (_ host: String, _ port: UInt16) -> ()
typealias SocketDidReceiveHandler = (_ host: String, _ port: UInt16, _ item: ZXKitLoggerItem) -> ()

class ZXKitLoggerUDPSocket: NSObject {
    static let shared = ZXKitLoggerUDPSocket()
    var socketDidReceiveHandler: SocketDidReceiveHandler?

    private var socketHost: String = "" //UDP的端口
    private var socketPort: UInt16 = 888 //UDP的端口

    private lazy var clientSocket: GCDAsyncUdpSocket = {
        let queue = DispatchQueue.init(label: "zxkitlogger_socket")
        let socket = GCDAsyncUdpSocket(delegate: self, delegateQueue: queue, socketQueue: queue)
        return socket
    }()

    func start(hostName:String, port: UInt16) {
        self.socketHost = hostName
        self.socketPort = port
        do {
            try clientSocket.bind(toPort: self.socketPort)
        } catch {
            print("socket.bind error: \(error.localizedDescription)")
        }
        do {
            try clientSocket.beginReceiving()
        } catch {
            print("socket.beginReceiving error: \(error.localizedDescription)")
        }
        //发送一条认证信息
        clientSocket.send("ZXKitLogger_auth".data(using: .utf8)!, toHost: self.socketHost, port:  self.socketPort, withTimeout: 600, tag: 1)
    }

}

extension ZXKitLoggerUDPSocket: GCDAsyncUdpSocketDelegate {
    func udpSocket(_ sock: GCDAsyncUdpSocket, didConnectToAddress address: Data) {
        print("address")
    }
    func udpSocket(_ sock: GCDAsyncUdpSocket, didNotConnect error: Error?) {
        print("didNotConnect", error)
    }
    func udpSocket(_ sock: GCDAsyncUdpSocket, didSendDataWithTag tag: Int) {
        print("didSend")
    }
    func udpSocket(_ sock: GCDAsyncUdpSocket, didNotSendDataWithTag tag: Int, dueToError error: Error?) {
        print("didNotSendDataWithTag", error)
    }
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
        print("didReceive", String(data: data, encoding: .utf8))
        //接受到需要log传输的消息，记录
        guard let receiveMsg = String(data: data, encoding: .utf8), let handler = self.socketDidReceiveHandler else {
            return
        }
        print("receiveMsg", receiveMsg)
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
        handler(self.socketHost, self.socketPort, item)
    }
}
