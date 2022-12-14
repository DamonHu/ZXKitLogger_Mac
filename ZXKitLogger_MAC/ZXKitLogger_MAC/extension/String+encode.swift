//
//  String+zx.swift
//  ZXKitUtil
//
//  Created by Damon on 2020/7/3.
//  Copyright © 2020 Damon. All rights reserved.
//

import Foundation
#if canImport(CryptoKit)
import CryptoKit
#endif

public extension String {
    ///截取字符串
    func subString(rang: NSRange) -> String {
        var string = String()
        var subRange = rang
        if rang.location < 0 {
            subRange = NSRange(location: 0, length: rang.length)
        }
        if self.count < subRange.location + subRange.length {
            //直接返回完整的
            subRange = NSRange(location: subRange.location, length: self.count - subRange.location)
        }
        let startIndex = self.index(self.startIndex,offsetBy: subRange.location)
        let endIndex = self.index(self.startIndex,offsetBy: (subRange.location + subRange.length))
        let subString = self[startIndex..<endIndex]
        string = String(subString)
        return string
    }
    
    ///unicode转中文
    func unicodeDecode() -> String {
        let tempStr1 = self.replacingOccurrences(of: "\\u", with: "\\U")
        let tempStr2 = tempStr1.replacingOccurrences(of: "\"", with: "\\\"")
        let tempStr3 = "\"".appending(tempStr2).appending("\"")
        let tempData = tempStr3.data(using: String.Encoding.utf8)
        var returnStr:String = ""
        do {
            returnStr = try PropertyListSerialization.propertyList(from: tempData!, options: [.mutableContainers], format: nil) as! String
        } catch {
            print("unicodeDecode转义失败\(error)")
            return self
        }
        return returnStr.replacingOccurrences(of: "\\r\\n", with: "\n")
    }
    
    ///字符串转unicode
    func unicodeEncode() -> String? {
        return self.encodeString(from: .system(.nonLossyASCII), to: .system(.utf8))
    }

    /// 字符串转格式
    /// - Parameters:
    ///   - originType: 字符串原来的编码格式
    ///   - encodeType: 即将转换的编码格式
    /// - Returns: 转换成功的新字符串
    func encodeString(from originType: ZXKitUtilEncodeType = .system(.utf8), to encodeType: ZXKitUtilEncodeType) -> String? {
        let data = Data.data(from: self, encodeType: originType)
        return data?.encodeString(encodeType: encodeType)
    }
    
    /*
     AES加密
     model: CBC
     padding: PKCS7Padding
     AES block Size: 128
     **/
    func aesCBCEncrypt(password: String, ivString: String = "abcdefghijklmnop", encodeType: ZXKitUtilEncodeType = .base64) -> String? {
        let data = self.data(using:String.Encoding.utf8)
        return data?.aesCBCEncrypt(password: password, ivString: ivString, encodeType: encodeType)
    }
    
    ///aes CBC解密
    func aesCBCDecrypt(password: String, ivString: String = "abcdefghijklmnop", encodeType: ZXKitUtilEncodeType = .base64) -> String? {
        let data = Data.data(from: self, encodeType: encodeType)
        return data?.aesCBCDecrypt(password: password, ivString: ivString)
    }

    //MARK: 加密
    func hashString(hashType: ZXKitUtilHashType, lowercase: Bool = true) -> String? {
        let data = self.data(using: String.Encoding.utf8)
        return data?.hashString(hashType: hashType, lowercase: lowercase)
    }


    @available(*, deprecated, message: "Use hashString(hashType: ZXKitUtilHashType, lowercase: Bool) instead")
    func encryptString(encryType: ZXKitUtilHashType, lowercase: Bool = true) -> String? {
        return self.hashString(hashType: encryType, lowercase: lowercase)
    }
}

#if canImport(CryptoKit)
public extension String {
    /*
     AES加密
     model: GCM
     **/
    func aesGCMEncrypt(password: String, encodeType: ZXKitUtilEncodeType = .base64, nonce: AES.GCM.Nonce? = AES.GCM.Nonce()) -> String? {
        let data = self.data(using:String.Encoding.utf8)
        return data?.aesGCMEncrypt(password: password, encodeType: encodeType, nonce: nonce)
    }

    /*
     AES加密
     model: GCM
     **/
    func aesGCMEncrypt(key: SymmetricKey, encodeType: ZXKitUtilEncodeType = .base64, nonce: AES.GCM.Nonce? = AES.GCM.Nonce()) -> String? {
        let data = self.data(using:String.Encoding.utf8)
        return data?.aesGCMEncrypt(key: key, encodeType: encodeType, nonce: nonce)
    }

    /*
     AES解密
     model: GCM
     **/
    func aesGCMDecrypt(password: String, encodeType: ZXKitUtilEncodeType = .base64) -> String? {
        let data = Data.data(from: self, encodeType: encodeType)
        return data?.aesGCMDecrypt(password: password)
    }

    /*
     AES解密
     model: GCM
     **/
    func aesGCMDecrypt(key: SymmetricKey, encodeType: ZXKitUtilEncodeType = .base64) -> String? {
        let data = Data.data(from: self, encodeType: encodeType)
        return data?.aesGCMDecrypt(key: key)
    }

    ///HMAC计算
    func hmac(hashType: ZXKitUtilHashType, password: String, encodeType: ZXKitUtilEncodeType = .base64) -> String? {
        let data = self.data(using:String.Encoding.utf8)
        return data?.hmac(hashType: hashType, password: password, encodeType: encodeType)
    }

    ///HMAC计算
    func hmac(hashType: ZXKitUtilHashType, key: SymmetricKey, encodeType: ZXKitUtilEncodeType = .base64) -> String? {
        let data = self.data(using:String.Encoding.utf8)
        return data?.hmac(hashType: hashType, key: key, encodeType: encodeType)
    }
}
#endif
