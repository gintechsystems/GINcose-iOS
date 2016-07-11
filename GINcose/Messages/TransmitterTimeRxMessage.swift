//
//  TransmitterTimeRxMessage.swift
//  xDrip5
//
//  Created by Nathan Racklyeft on 11/23/15.
//  Copyright © 2015 Nathan Racklyeft. All rights reserved.
//

import Foundation


struct TransmitterTimeRxMessage: TransmitterRxMessage {
    static let opcode: UInt8 = 0x25
    let status: TransmitterStatus
    let transmitterTime: UInt32
    let sessionStartTime: UInt32
    let isSession: UInt8
    
    init?(data: NSData) {
        NSLog("\(data.length)")
        if data.length == 16 && data.crcValid() {
            if data[0] == self.dynamicType.opcode {
                status = TransmitterStatus(rawValue: data[1])
                transmitterTime = data[2...5]
                sessionStartTime = data[6...9]
                isSession = data[10]
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
}