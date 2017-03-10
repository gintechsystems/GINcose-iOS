//
//  AuthChallengeRxMessage.swift
//  GINcose
//
//  Created by Joe Ginley on 3/9/17.
//  Copyright © 2017 GINtech Systems. All rights reserved.
//

import Foundation


struct AuthChallengeRxMessage: TransmitterRxMessage {
    static let opcode: UInt8 = 0x3
    let tokenHash: Data
    let challenge: Data
    
    init?(data: Data) {
        guard data.count >= 17 else {
            return nil
        }
        
        guard data[0] == type(of: self).opcode else {
            return nil
        }
        
        tokenHash = data.subdata(in: 1..<9)
        challenge = data.subdata(in: 9..<17)
    }
}
