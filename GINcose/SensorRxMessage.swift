//
//  SensorRxMessage.swift
//  GINcose
//
//  Created by Joe Ginley on 3/14/16.
//  Copyright © 2016 GINtech Systems. All rights reserved.
//

import Foundation


public struct SensorRxMessage: TransmitterRxMessage {
    static let opcode: UInt8 = 0x2f
    public let status: UInt8
    public let timestamp: UInt32
    public let unfiltered: UInt32
    public let filtered: UInt32
    
    init?(data: NSData) {
        if data.length >= 14 {
            if data[0] == self.dynamicType.opcode {
                status = data[1]
                timestamp = data[2...5]
                unfiltered = data[6...9]
                filtered = data[10...13]
                
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
}