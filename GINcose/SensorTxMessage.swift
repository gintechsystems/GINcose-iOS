//
//  SensorTxMessage.swift
//  GINcose
//
//  Created by Joe Ginley on 3/14/16.
//  Copyright © 2016 GINtech Systems. All rights reserved.
//

import Foundation


struct SensorTxMessage: TransmitterTxMessage {
    let opcode: UInt8 = 0x2e
    let crc: UInt16 = CRC.calculateCRC(0x2e)
    
    var byteSequence: [Any] {
        return [opcode, crc]
    }
}