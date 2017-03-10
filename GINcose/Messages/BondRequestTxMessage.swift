//
//  BondRequestTxMessage.swift
//  GINcose
//
//  Created by Joe Ginley on 3/9/17.
//  Copyright © 2017 GINtech Systems. All rights reserved.
//

import Foundation


struct BondRequestTxMessage: TransmitterTxMessage {
    let opcode: UInt8 = 0x7
    
    var byteSequence: [Any] {
        return [opcode]
    }
}
