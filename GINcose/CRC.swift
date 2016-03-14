//
//  CRC.swift
//  GINcose
//
//  Created by Joe Ginley on 3/14/16.
//  Copyright © 2016 GINtech Systems. All rights reserved.
//

import Foundation


class CRC {
    static func calculateCRC(byte: UInt8) -> UInt16
    {
        let crc : UInt16 = 0x00;
        var x = crc >> 8 ^ UInt16(byte)
        x ^= x>>4
        return (crc << 8) ^ (UInt16(x << 12)) ^ (UInt16(x << 5)) ^ (UInt16(x))
    }
}