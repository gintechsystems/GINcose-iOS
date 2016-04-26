//
//  Extensions.swift
//  GINcose
//
//  Created by Joe Ginley on 3/9/16.
//  Copyright © 2016 GINtech Systems. All rights reserved.
//

import UIKit

func CRCCCITTXModem(bytes: [UInt8], count: Int? = nil) -> UInt16 {
    let count = count ?? bytes.count
    
    var crc: UInt16 = 0
    
    for byte in bytes[0..<count] {
        crc ^= UInt16(byte) << 8
        
        for _ in 0..<8 {
            if crc & 0x8000 != 0 {
                crc = crc << 1 ^ 0x1021
            } else {
                crc = crc << 1
            }
        }
    }
    
    return crc
}

extension NSString {
    func compatibleContainsString(string: NSString) -> Bool{
        let range = self.rangeOfString(string as String)
        return range.length != 0
    }
}

extension UInt8 {
    func crc16() -> UInt16 {
        return CRCCCITTXModem([self])
    }
}

extension NSData {
    @nonobjc subscript(index: Int) -> Int8 {
        let bytes: [Int8] = self[index...index]
        
        return bytes[0]
    }
    
    @nonobjc subscript(index: Int) -> UInt8 {
        let bytes: [UInt8] = self[index...index]
        
        return bytes[0]
    }
    
    @nonobjc subscript(range: Range<Int>) -> UInt16 {
        return self[range][0]
    }
    
    @nonobjc subscript(range: Range<Int>) -> UInt32 {
        return self[range][0]
    }
    
    subscript(range: Range<Int>) -> [Int8] {
        var dataArray = [Int8](count: range.count, repeatedValue: 0)
        self.getBytes(&dataArray, range: NSRange(range))
        
        return dataArray
    }
    
    subscript(range: Range<Int>) -> [UInt8] {
        var dataArray = [UInt8](count: range.count, repeatedValue: 0)
        self.getBytes(&dataArray, range: NSRange(range))
        
        return dataArray
    }
    
    subscript(range: Range<Int>) -> [UInt16] {
        var dataArray = [UInt16](count: range.count / 2, repeatedValue: 0)
        self.getBytes(&dataArray, range: NSRange(range))
        
        return dataArray
    }
    
    subscript(range: Range<Int>) -> [UInt32] {
        var dataArray = [UInt32](count: range.count / 4, repeatedValue: 0)
        self.getBytes(&dataArray, range: NSRange(range))
        
        return dataArray
    }
    
    subscript(range: Range<Int>) -> NSData {
        return subdataWithRange(NSRange(range))
    }
    
    public convenience init?(hexadecimalString: String) {
        if let
            chars = hexadecimalString.cStringUsingEncoding(NSUTF8StringEncoding),
            mutableData = NSMutableData(capacity: chars.count / 2)
        {
            for i in 0..<chars.count / 2 {
                var num: UInt8 = 0
                var multi: UInt8 = 16
                
                for j in 0..<2 {
                    let c = chars[i * 2 + j]
                    var offset: UInt8
                    
                    switch c {
                    case 48...57:   // '0'-'9'
                        offset = 48
                    case 65...70:   // 'A'-'F'
                        offset = 65 - 10         // 10 since 'A' is 10, not 0
                    case 97...102:  // 'a'-'f'
                        offset = 97 - 10         // 10 since 'a' is 10, not 0
                    default:
                        return nil
                    }
                    
                    num += (UInt8(c) - offset) * multi
                    multi = 1
                }
                mutableData.appendBytes(&num, length: 1)
            }
            
            self.init(data: mutableData)
        } else {
            return nil
        }
    }
    
    func crc16() -> UInt16 {
        return CRCCCITTXModem(self[0..<length])
    }
    
    func crcValid() -> Bool {
        return CRCCCITTXModem(self[0..<length-2]) == self[length-2..<length]
    }
    
    public var hexadecimalString: String {
        let bytesCollection = UnsafeBufferPointer<UInt8>(start: UnsafePointer<UInt8>(bytes), count: length)
        
        let string = NSMutableString(capacity: length * 2)
        
        for byte in bytesCollection {
            string.appendFormat("%02x", byte)
        }
        
        return string as String
    }
}

extension NSUserDefaults {
    var passiveModeEnabled: Bool {
        get {
            return boolForKey("passiveModeEnabled") ?? false
        }
        set {
            setBool(newValue, forKey: "passiveModeEnabled")
        }
    }
    
    var startTimeInterval: NSTimeInterval? {
        get {
            let value = doubleForKey("startTimeInterval")
            
            return value > 0 ? value : nil
        }
        set {
            if let value = newValue {
                setDouble(value, forKey: "startTimeInterval")
            } else {
                setObject(nil, forKey: "startTimeInterval")
            }
        }
    }
    
    var stayConnected: Bool {
        get {
            return boolForKey("stayConnected") ?? true
        }
        set {
            setBool(newValue, forKey: "stayConnected")
        }
    }
    
    var transmitterID: String {
        get {
            return stringForKey("transmitterID") ?? "000000"
        }
        set {
            setObject(newValue, forKey: "transmitterID")
        }
    }
}