//
//  AuthStatusRxMessage.swift
//  GINcose
//
//  Created by Joe Ginley on 3/9/17.
//  Copyright © 2017 GINtech Systems. All rights reserved.
//

import Foundation


struct AuthStatusRxMessage: TransmitterRxMessage {
    static let opcode: UInt8 = 0x5
    let authenticated: UInt8
    let bonded: UInt8
    
    init?(data: Data) {
        guard data.count >= 3 else {
            return nil
        }
        
        guard data[0] == type(of: self).opcode else {
            return nil
        }
        
        authenticated = data[1]
        bonded = data[2]
    }
}
