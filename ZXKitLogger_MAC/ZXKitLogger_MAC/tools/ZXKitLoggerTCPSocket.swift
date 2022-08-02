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
    private var timer: Timer?

    
    private lazy var serverSocket: GCDAsyncSocket = {
        let queue = DispatchQueue.init(label: "zxkitlogger_socket")
        let socket = GCDAsyncSocket(delegate: self, delegateQueue: queue, socketQueue: queue)
        socket.isIPv4PreferredOverIPv6 = false
        return socket
    }()
}

extension ZXKitLoggerTCPSocket {
    func start(hostName:String, port: UInt16) {
        self.serverSocket.disconnect()
        do {
            try self.serverSocket.connect(toHost: hostName, onPort: port, withTimeout: 20)
        } catch {
            print("connect error", error)
        }
        self.sendHeartBeat()
    }

    func sendHeartBeat() {
        print("heart beat")
        timer?.invalidate()
        //发送心跳包
        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
            guard let self = self, let data = "h".data(using: .utf8) else {
                return
            }
            self.serverSocket.write(data, withTimeout: 20, tag: 0)
        }
    }

}

extension ZXKitLoggerTCPSocket: GCDAsyncSocketDelegate {
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        print("didConnectToHost", host, port)
    }

    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        print("socketDidDisconnect", err)
    }

    func socket(_ sock: GCDAsyncSocket, didWriteDataWithTag tag: Int) {
        print("didWriteDataWithTag")
    }

    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        print("didReceive", String(data: data, encoding: .utf8))
    }
}
