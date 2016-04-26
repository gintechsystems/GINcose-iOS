//
//  CalibrationTxMessage.swift
//  GINcose
//
//  Created by Joe Ginley on 3/14/16.
//  Copyright © 2016 GINtech Systems. All rights reserved.
//

import Foundation


struct CalibrationTxMessage: TransmitterTxMessage {
    let opcode: UInt8 = 0x33
    
    var byteSequence: [Any] {
        return [opcode, opcode.crc16()]
    }
}