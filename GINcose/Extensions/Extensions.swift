//
//  Extensions.swift
//  GINcose
//
//  Created by Joe Ginley on 3/9/16.
//  Copyright © 2016 GINtech Systems. All rights reserved.
//

import Foundation


extension NSString {
    func compatibleContainsString(_ string: NSString) -> Bool{
        let range = self.range(of: string as String)
        return range.length != 0
    }
}

extension Data {
    public init?(hexadecimalString: String) {
        guard let chars = hexadecimalString.cString(using: String.Encoding.utf8) else {
            return nil
        }
        
        self.init(capacity: chars.count / 2)
        
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
            append(num)
        }
    }
    
    public var hexadecimalString: String {
        let string = NSMutableString(capacity: count * 2)
        
        for byte in self {
            string.appendFormat("%02x", byte)
        }
        
        return string as String
    }
}

extension UserDefaults {
    var passiveModeEnabled: Bool {
        get {
            return bool(forKey: "passiveModeEnabled")
        }
        set {
            set(newValue, forKey: "passiveModeEnabled")
        }
    }
    
    var stayConnected: Bool {
        get {
            return object(forKey: "stayConnected") != nil ? bool(forKey: "stayConnected") : true
        }
        set {
            set(newValue, forKey: "stayConnected")
        }
    }
    
    var transmitterID: String {
        get {
            return string(forKey: "transmitterID") ?? "000000"
        }
        set {
            set(newValue, forKey: "transmitterID")
        }
    }
}
