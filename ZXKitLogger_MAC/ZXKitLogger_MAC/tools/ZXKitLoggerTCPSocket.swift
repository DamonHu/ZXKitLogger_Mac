//
//  ZXKitLoggerTCPSocket.swift
//  ZXKitLogger
//
//  Created by Damon on 2022/8/2.
//  Copyright © 2022 Damon. All rights reserved.
//

import Foundation
import CocoaAsyncSocket

class ZXKitLoggerTCPSocket: NSObject {
    public static let shared = ZXKitLoggerTCPSocket()
    var socketDidReceiveHandler: SocketDidReceiveHandler?
    var socketDidConnectHandler: SocketDidConnectHandler?
    private var timer: Timer?

    
//    private lazy var serverSocket: GCDAsyncSocket = {
//        let queue = DispatchQueue.init(label: "zxkitlogger_socket")
//        let socket = GCDAsyncSocket(delegate: self, delegateQueue: queue, socketQueue: queue)
//        socket.isIPv4PreferredOverIPv6 = false
//        return socket
//    }()
    
    private var acceptSocketList: [GCDAsyncSocket] = []
    private var connectSocketList: [GCDAsyncSocket] = []
}

extension ZXKitLoggerTCPSocket {
    func start(hostName:String, port: UInt16) {
        let queue = DispatchQueue.init(label: "zxkitlogger_socket")
        let socket = GCDAsyncSocket(delegate: self, delegateQueue: queue, socketQueue: queue)
        socket.isIPv4PreferredOverIPv6 = false
        do {
            try socket.connect(toHost: hostName, onPort: port, withTimeout: 20)
        } catch {
            print("connect error", error)
        }
        connectSocketList.append(socket)
        self.sendHeartBeat(socket: socket)
    }

    func sendHeartBeat(socket: GCDAsyncSocket) {
        print("heart beat")
        timer?.invalidate()
        //发送心跳包
        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
            guard let data = "h".data(using: .utf8) else {
                return
            }
            socket.write(data, withTimeout: 20, tag: 0)
            socket.readData(withTimeout: -1, tag: 0)
        }
    }

}

extension ZXKitLoggerTCPSocket: GCDAsyncSocketDelegate {
    func socket(_ sock: GCDAsyncSocket, didAcceptNewSocket newSocket: GCDAsyncSocket) {
        print("didAcceptNewSocket")
        acceptSocketList.append(newSocket)
        newSocket.readData(withTimeout: -1, tag: 0)
    }
    
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        print("didConnectToHost", host, port)
        if let socketDidConnectHandler = socketDidConnectHandler {
            socketDidConnectHandler(host, port)
        }
    }

    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        print("socketDidDisconnect", err)
    }

    func socket(_ sock: GCDAsyncSocket, didWriteDataWithTag tag: Int) {
        print("didWriteDataWithTag")
    }

    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        print("didReceive", String(data: data, encoding: .utf8))
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
        print("sock.connectedHost, sock.connectedPort")
        if let host = sock.connectedHost {
            handler(host, sock.connectedPort, item)
        }

        sock.readData(withTimeout: -1, tag: tag)
    }
}
