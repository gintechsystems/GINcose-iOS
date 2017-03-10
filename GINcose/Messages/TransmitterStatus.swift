//
//  TransmitterStatus.swift
//  GINcose
//
//  Created by Joe Ginley on 3/28/16.
//  Copyright © 2016 GINtech Systems. All rights reserved.
//

import Foundation


public enum TransmitterStatus {
    public typealias RawValue = UInt8
    
    case ok
    case lowBattery
    case unknown(RawValue)
    
    init(rawValue: RawValue) {
        switch rawValue {
        case 0:
            self = .ok
        case 0x81:
            self = .lowBattery
        default:
            self = .unknown(rawValue)
        }
    }
}


extension TransmitterStatus: Equatable { }

public func ==(lhs: TransmitterStatus, rhs: TransmitterStatus) -> Bool {
    switch (lhs, rhs) {
    case (.ok, .ok), (.lowBattery, .lowBattery):
        return true
    case (.unknown(let left), .unknown(let right)) where left == right:
        return true
    default:
        return false
    }
}
