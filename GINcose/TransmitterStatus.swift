//
//  TransmitterStatus.swift
//  GINcose
//
//  Created by Joe Ginley on 3/28/16.
//  Copyright © 2016 GINtech Systems. All rights reserved.
//

import Foundation


public enum TransmitterStatus {
    case OK
    case LowBattery
    case Unknown(UInt8)
    
    init(rawValue: UInt8) {
        switch rawValue {
        case 0:
            self = .OK
        case 0x81:
            self = LowBattery
        default:
            self = Unknown(rawValue)
        }
    }
}


extension TransmitterStatus: Equatable { }

public func ==(lhs: TransmitterStatus, rhs: TransmitterStatus) -> Bool {
    switch (lhs, rhs) {
    case (.OK, .OK), (.LowBattery, .LowBattery):
        return true
    case (.Unknown(let left), .Unknown(let right)) where left == right:
        return true
    default:
        return false
    }
}