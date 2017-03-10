//
//  AuthRequestTxMessage.swift
//  GINcose
//
//  Created by Joe Ginley on 3/9/17.
//  Copyright © 2017 GINtech Systems. All rights reserved.
//

import Foundation


struct AuthRequestTxMessage: TransmitterTxMessage {
    let opcode: UInt8 = 0x1
    let singleUseToken: Data
    let endByte: UInt8 = 0x2
    
    init() {
        var UUIDBytes = [UInt8](repeating: 0, count: 16)
        
        NSUUID().getBytes(&UUIDBytes)
        
        singleUseToken = Data(bytes: UUIDBytes)
    }
    
    var byteSequence: [Any] {
        return [opcode, singleUseToken, endByte]
    }
}
