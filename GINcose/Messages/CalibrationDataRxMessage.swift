//
//  CalibrationDataRxMessage.swift
//  GINcose
//
//  Created by Joe Ginley on 3/9/17.
//  Copyright © 2017 GINtech Systems. All rights reserved.
//

import Foundation


struct CalibrationDataRxMessage: TransmitterRxMessage {
    static let opcode: UInt8 = 0x33
    
    init?(data: Data) {
        guard data.count == 19 && data.crcValid() else {
            return nil
        }
        
        guard data[0] == type(of: self).opcode else {
            return nil
        }
    }
}
