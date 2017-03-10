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
    
    init?(data: Data) {
        guard data.count >= 17 else {
            return nil
        }
        
        guard data[0] == type(of: self).opcode else {
            return nil
        }
        
        status = TransmitterStatus(rawValue: data[1])
    }
}
