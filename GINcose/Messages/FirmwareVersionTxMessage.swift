//
//  FirmwareVersionTxMessage.swift
//  GINcose
//
//  Created by Joe Ginley on 4/26/16.
//  Copyright © 2016 GINtech Systems. All rights reserved.
//

import Foundation


struct FirmwareVersionTxMessage :TransmitterTxMessage {
    let opcode: UInt8 = 0x20
    
    var byteSequence: [Any] {
        return [opcode, opcode.crc16()]
    }
}