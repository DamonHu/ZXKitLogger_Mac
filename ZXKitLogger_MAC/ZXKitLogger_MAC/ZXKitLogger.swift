//
//  ZXKitLogger.swift
//  ZXKitLogger_MAC
//
//  Created by Damon on 2022/7/30.
//

import Foundation
import SwiftUI

///log的级别，对应不同的颜色
public struct ZXKitLogType : OptionSet {
    public static let debug = ZXKitLogType([])        //only show in debug output
    public static let info = ZXKitLogType(rawValue: 1)    //textColor #50d890
    public static let warn = ZXKitLogType(rawValue: 2)         //textColor #f6f49d
    public static let error = ZXKitLogType(rawValue: 4)        //textColor #ff7676
    public static let privacy = ZXKitLogType(rawValue: 8)      //textColor #42e6a4

    public let rawValue: Int
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

extension ZXKitLogType {
    func color() -> Color {
        switch self {
        case .debug:
            return Color(red: 191.0/255.0, green: 139.0/255.0, blue: 251.0/255.0)
        case .info:
            return Color(red: 80.0/255.0, green: 216.0/255.0, blue: 144.0/255.0)
        case .warn:
            return Color(red: 255.0/255.0, green: 191.0/255.0, blue: 0.0/255.0)
        case .error:
            return Color(red: 229.0/255.0, green: 43.0/255.0, blue: 80.0/255.0)
        case .privacy:
            return Color(red: 165.0/255.0, green: 42.0/255.0, blue: 42.0/255.0)
        default:
            return .black
        }
    }
}

public class ZXKitLogger {
    public static let shared = ZXKitLogger()
    /*隐私数据采用AESCBC加密
     *需要设置密码privacyLogPassword
     *初始向量privacyLogIv
     *结果编码类型可以选择base64和hex编码
     **/
    public static var privacyLogPassword = "12345678901234561234567890123456"
    public static var privacyLogIv = "abcdefghijklmnop"
    public static var privacyResultEncodeType = ZXKitUtilEncodeType.hex
}
