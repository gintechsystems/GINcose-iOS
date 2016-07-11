//
//  TransmitterVersionTxMessage.swift
//  GINcose
//
//  Created by Joe Ginley on 4/26/16.
//  Copyright © 2016 GINtech Systems. All rights reserved.
//

import Foundation

struct TransmitterVersionTxMessage: TransmitterTxMessage {
    let opcode: UInt8 = 0x4a
    
    var byteSequence: [Any] {
        return [opcode, opcode.crc16()]
    }
}