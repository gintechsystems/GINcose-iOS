//
//  Glucose.swift
//  GINcose
//
//  Created by Joe Ginley on 3/9/17.
//  Copyright © 2017 GINtech Systems. All rights reserved.
//

import Foundation
import HealthKit


public struct Glucose {
    public let glucoseMessage: GlucoseRxMessage
    let timeMessage: TransmitterTimeRxMessage
    
    init(glucoseMessage: GlucoseRxMessage, timeMessage: TransmitterTimeRxMessage, activationDate: Date) {
        self.glucoseMessage = glucoseMessage
        self.timeMessage = timeMessage
        
        status = TransmitterStatus(rawValue: glucoseMessage.status)
        state = CalibrationState(rawValue: glucoseMessage.state)
        sessionStartDate = activationDate.addingTimeInterval(TimeInterval(timeMessage.sessionStartTime))
        readDate = activationDate.addingTimeInterval(TimeInterval(glucoseMessage.timestamp))
    }
    
    public let status: TransmitterStatus
    public let sessionStartDate: Date
    
    public let state: CalibrationState
    public let readDate: Date
    
    public var isDisplayOnly: Bool {
        return glucoseMessage.glucoseIsDisplayOnly
    }
    
    // This allows us to display our glucose as mL to the user, we can add this feature later.
    /*public var glucose: HKQuantity? {
        guard state.hasReliableGlucose else {
            return nil
        }
        
        let unit = HKUnit.milligramsPerDeciliter()
        
        return HKQuantity(unit: unit, doubleValue: Double(glucoseMessage.glucose))
    }*/
    
    public var glucose: Int {
        return Int(glucoseMessage.glucose)
    }
    
    public var trend: Int {
        return Int(glucoseMessage.trend)
    }
}


extension Glucose: Equatable { }


public func ==(lhs: Glucose, rhs: Glucose) -> Bool {
    return lhs.glucoseMessage == rhs.glucoseMessage && lhs.timeMessage == rhs.timeMessage
}
