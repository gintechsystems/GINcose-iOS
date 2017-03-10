//
//  NSData+CRC.swift
//  GINcose
//
//  Created by Joe Ginley on 3/9/17.
//  Copyright © 2017 GINtech Systems. All rights reserved.
//

import Foundation


private func CRCCCITTXModem(_ bytes: Data) -> UInt16 {
    var crc: UInt16 = 0
    
    for byte in bytes {
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


extension UInt8 {
    func crc16() -> UInt16 {
        return CRCCCITTXModem(Data(bytes: [self]))
    }
}


extension Data {
    func crc16() -> UInt16 {
        return CRCCCITTXModem(self)
    }
    
    func crcValid() -> Bool {
        return CRCCCITTXModem(subdata(in: 0..<count-2)) == self[count-2..<count]
    }
}
