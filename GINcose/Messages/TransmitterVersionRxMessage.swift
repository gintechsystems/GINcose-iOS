//
//  TransmitterVersionRxMessage.swift
//  GINcose
//
//  Created by Joe Ginley on 4/27/16.
//  Copyright © 2016 GINtech Systems. All rights reserved.
//

import Foundation


struct TransmitterVersionRxMessage: TransmitterRxMessage {
    static let opcode: UInt8 = 0x4b
    let status: TransmitterStatus
    let versionMajor: UInt8
    let versionMinor: UInt8
    let versionRevision: UInt8
    let versionBuild: UInt8
    let swNumber: UInt32
    let storageModeDays: UInt16
    let apiVersion: UInt32
    let maxRuntimeDays: UInt16
    let maxStorageModeDays: UInt16
    
    init?(data: NSData) {
        if data.length == 19 && data.crcValid() {
            if data[0] == self.dynamicType.opcode {
                status = TransmitterStatus(rawValue: data[1])
                versionMajor = data[2]
                versionMinor = data[3]
                versionRevision = data[4]
                versionBuild = data[5]
                swNumber = data[6...9]
                storageModeDays = data[10...11]
                apiVersion = data[12...15]
                maxRuntimeDays = data[16...17]
                maxStorageModeDays = data[17...18]
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
}