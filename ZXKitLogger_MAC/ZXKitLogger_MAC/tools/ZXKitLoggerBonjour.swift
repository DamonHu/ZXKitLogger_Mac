//
//  ZXKitLoggerBonjour.swift
//  ZXKitLogger_MAC
//
//  Created by Damon on 2022/8/2.
//

import Foundation
import Network

typealias BonjourDidConnectHandler = (_ name: String, _ host: String, _ port: UInt16) -> ()

class ZXKitLoggerBonjour: NSObject {
    static let shared = ZXKitLoggerBonjour()
    var socketDidReceiveHandler: SocketDidReceiveHandler?
    var bonjourDidConnectHandler: BonjourDidConnectHandler?

    private lazy var mBrowser: NetServiceBrowser = {
        let browser = NetServiceBrowser()
        browser.delegate = self
        return browser
    }()

    //解析的service
    private var mResolveServiceList: [NetService] = []
    private var mZXKitLoggerTCPSocketManager: [ZXKitLoggerTCPSocketManager] = []
}

extension ZXKitLoggerBonjour {
    func start() {
        mBrowser.stop()
        mBrowser.schedule(in: RunLoop.current, forMode: .common)
        let type = ZXKitLogger.isTCP ? "_tcp" : "_udp"
        mBrowser.searchForServices(ofType: "\(ZXKitLogger.socketType).\(type)", inDomain: "\(ZXKitLogger.socketDomain).")
    }

    func stop() {

    }
}

extension ZXKitLoggerBonjour: NetServiceBrowserDelegate {
    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        print("didFind service: domainName= \(service.domain), type= \(service.type), name= \(service.name), onPort= \(service.port) and hostname: \(service.hostName)");
        //解析发现的service
        self.mResolveServiceList.append(service)
        service.delegate = self
        service.resolve(withTimeout: 10)
    }

    func netServiceBrowser(_ browser: NetServiceBrowser, didRemove service: NetService, moreComing: Bool) {
        print("didRemove")
    }

}

extension ZXKitLoggerBonjour: NetServiceDelegate {
    func netServiceWillPublish(_ sender: NetService) {
        print("netServiceWillPublish")
    }
    func netService(_ sender: NetService, didNotPublish errorDict: [String : NSNumber]) {
        print("didNotPublish", errorDict)
    }

    func netServiceDidResolveAddress(_ sender: NetService) {
        print("Connecting with service: domainName= \(sender.domain), type= \(sender.type), name= \(sender.name), onPort= \(sender.port) and hostname: \(sender.hostName!)");

//        let data = sender.txtRecordData()
//        let dict = NetService.dictionary(fromTXTRecord: data!)
//        let info = String.init(data: dict["node"]!, encoding: String.Encoding.utf8)
//        print("mac info = ",info);
        if let hostName = sender.hostName {
            if ZXKitLogger.isTCP {
                if !self.mZXKitLoggerTCPSocketManager.contains(where: { manager in
                    return manager.socketHost == hostName && manager.socketPort == sender.port
                }) {
                    let tcpManager = ZXKitLoggerTCPSocketManager()
                    tcpManager.socketDidReceiveHandler = self.socketDidReceiveHandler
                    tcpManager.socketDidConnectHandler = { host, port in
                        if let bonjourDidConnectHandler = self.bonjourDidConnectHandler {
                            bonjourDidConnectHandler(sender.name, hostName, port)
                        }
                    }
                    tcpManager.start(hostName: hostName, port: UInt16(sender.port))
                    self.mZXKitLoggerTCPSocketManager.append(tcpManager)
                } else {
                    if let bonjourDidConnectHandler = self.bonjourDidConnectHandler {
                        bonjourDidConnectHandler(sender.name, hostName, UInt16(sender.port))
                    }
                }
            } else {
                //TODO: 移除UDP广播
//                ZXKitLoggerUDPSocketManager.shared.socketDidReceiveHandler = self.socketDidReceiveHandler
//                ZXKitLoggerUDPSocketManager.shared.start(hostName: hostName, port: UInt16(sender.port))
            }

        }
    }
}
