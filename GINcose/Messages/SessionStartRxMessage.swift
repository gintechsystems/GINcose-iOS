//
//  SessionStartRxMessage.swift
//  GINcose
//
//  Created by Joe Ginley on 3/9/17.
//  Copyright © 2017 GINtech Systems. All rights reserved.
//

import Foundation


struct SessionStartRxMessage {
    static let opcode: UInt8 = 0x27
    let status: UInt8
    let received: UInt8
    
    let requestedStartTime: UInt32
    let sessionStartTime: UInt32
    
    let transmitterTime: UInt32
    
    init?(data: Data) {
        guard data.count == 17 && data.crcValid() else {
            return nil
        }
        
        guard data[0] == type(of: self).opcode else {
            return nil
        }
        
        status = data[1]
        received = data[2]
        requestedStartTime = data[3..<7]
        sessionStartTime = data[7..<11]
        transmitterTime = data[11..<15]
    }
}
