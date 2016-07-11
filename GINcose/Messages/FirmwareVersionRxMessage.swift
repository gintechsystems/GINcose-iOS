//
//  FirmwareVersionRxMessage.swift
//  GINcose
//
//  Created by Joe Ginley on 4/26/16.
//  Copyright © 2016 GINtech Systems. All rights reserved.
//

import Foundation


struct FirmwareVersionRxMessage: TransmitterRxMessage {
    static let opcode: UInt8 = 0x21
    let status: TransmitterStatus
    
    init?(data: NSData) {
        if data.length >= 17 {
            if data[0] == self.dynamicType.opcode {
                status = TransmitterStatus(rawValue: data[1])
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