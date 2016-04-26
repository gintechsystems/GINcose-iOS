//
//  CalibrationRxMessage.swift
//  GINcose
//
//  Created by Joe Ginley on 3/14/16.
//  Copyright © 2016 GINtech Systems. All rights reserved.
//

import Foundation


public struct CalibrationRxMessage: TransmitterRxMessage {
    static let opcode: UInt8 = 0x34
    public let timestamp: UInt32
    
    init?(data: NSData) {
        NSLog("\(data)")
        if data.length >= 14 {
            if data[0] == self.dynamicType.opcode {
                timestamp = data[2...5]
            }
            else {
                return nil
            }
        }
        else {
            return nil
        }
    }
}