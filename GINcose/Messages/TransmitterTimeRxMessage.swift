//
//  TransmitterTimeRxMessage.swift
//  GINcose
//
//  Created by Joe Ginley on 3/9/17.
//  Copyright © 2017 GINtech Systems. All rights reserved.
//

import Foundation


struct TransmitterTimeRxMessage: TransmitterRxMessage {
    static let opcode: UInt8 = 0x25
    let status: UInt8
    let currentTime: UInt32
    let sessionStartTime: UInt32
    
    init?(data: Data) {
        guard data.count == 16 && data.crcValid() else {
            return nil
        }
        
        guard data[0] == type(of: self).opcode else {
            return nil
        }
        
        status = data[1]
        currentTime = data[2..<6]
        sessionStartTime = data[6..<10]
    }
}

extension TransmitterTimeRxMessage: Equatable { }

func ==(lhs: TransmitterTimeRxMessage, rhs: TransmitterTimeRxMessage) -> Bool {
    return lhs.currentTime == rhs.currentTime
}
