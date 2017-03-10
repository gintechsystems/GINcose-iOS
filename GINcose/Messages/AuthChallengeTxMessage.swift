//
//  AuthChallengeTxMessage.swift
//  GINcose
//
//  Created by Joe Ginley on 3/9/17.
//  Copyright © 2017 GINtech Systems. All rights reserved.
//

import Foundation


struct AuthChallengeTxMessage: TransmitterTxMessage {
    let opcode: UInt8 = 0x4
    let challengeHash: Data
    
    var byteSequence: [Any] {
        return [opcode, challengeHash]
    }
}
