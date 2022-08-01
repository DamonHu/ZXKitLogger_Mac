//
//  ZXKitloggerClientSocket.swift
//  ZXKitLogger_MAC
//
//  Created by Damon on 2022/8/1.
//

import Foundation
import CocoaAsyncSocket

class ZXKitloggerClientSocket: NSObject {
    public static let shared = ZXKitloggerClientSocket()
    //TODO: 回调

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
        guard let receiveMsg = String(data: data, encoding: .utf8), receiveMsg == "ZXKITLOGGER" else {
            return
        }
//        //添加到address，重复的ip不添加
//        if self.addressList.contains(where: { data in
//            GCDAsyncUdpSocket.host(fromAddress: data) ==  GCDAsyncUdpSocket.host(fromAddress: address)
//        }) {
//            return
//        }
//        self.addressList.append(address)
    }
}
