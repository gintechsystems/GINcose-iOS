//
//  KeepAliveTxMessage.swift
//  GINcose
//
//  Created by Joe Ginley on 3/9/17.
//  Copyright © 2017 GINtech Systems. All rights reserved.
//

import Foundation


struct KeepAliveTxMessage: TransmitterTxMessage {
    let opcode: UInt8 = 0x6
    let time: UInt8

    var byteSequence: [Any] {
        return [opcode, time]
    }
}
