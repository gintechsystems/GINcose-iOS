//
//  SessionStopTxMessage.swift
//  GINcose
//
//  Created by Joe Ginley on 4/26/16.
//  Copyright © 2016 GINtech Systems. All rights reserved.
//

import Foundation


struct SessionStopTxMessage: TransmitterTxMessage {
    let opcode: UInt8 = 0x28
    let stopTime: UInt32
    
    var byteSequence: [Any] {
        return [opcode, stopTime]
    }
}
