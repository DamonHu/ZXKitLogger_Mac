//
//  ZXKitLoggerBonjour.swift
//  ZXKitLogger_MAC
//
//  Created by Damon on 2022/8/2.
//

import Foundation
import Network

class ZXKitLoggerBonjour: NSObject {
    static let shared = ZXKitLoggerBonjour()
    var socketDidReceiveHandler: SocketDidReceiveHandler?

    private lazy var mBrowser: NetServiceBrowser = {
        let browser = NetServiceBrowser()
        browser.delegate = self
        return browser
    }()

    //解析的service
    private var mResolveService: NetService?
}

extension ZXKitLoggerBonjour {
    func start() {
        mBrowser.stop()
        mBrowser.schedule(in: RunLoop.current, forMode: .common)
        mBrowser.searchForServices(ofType: "_zxkitlogger._tcp", inDomain: "local.")
    }

    func stop() {

    }
}

extension ZXKitLoggerBonjour: NetServiceBrowserDelegate {
    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        print("didFind service")
        //解析发现的service
        self.mResolveService = service
        self.mResolveService?.delegate = self
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

        let data = sender.txtRecordData()
        let dict = NetService.dictionary(fromTXTRecord: data!)
        let info = String.init(data: dict["node"]!, encoding: String.Encoding.utf8)
        print("mac info = ",info);
        if let hostName = sender.hostName {
            if ZXKitLogger.isTCP {
                ZXKitLoggerTCPSocket.shared.socketDidReceiveHandler = self.socketDidReceiveHandler
                ZXKitLoggerTCPSocket.shared.start(hostName: hostName, port: UInt16(sender.port))
            } else {
                ZXKitLoggerUDPSocket.shared.socketDidReceiveHandler = self.socketDidReceiveHandler
                ZXKitLoggerUDPSocket.shared.start(hostName: hostName, port: UInt16(sender.port))
            }

        }
    }
}
