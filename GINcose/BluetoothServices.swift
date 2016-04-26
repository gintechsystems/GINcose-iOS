//
//  BluetoothServices.swift
//  GINcose
//
//  Created by Joe Ginley on 3/9/16.
//  Copyright © 2016 GINtech Systems. All rights reserved.
//

enum TransmitterServiceUUID: String {
    case DeviceInfo = "180A"
    case Advertisement = "FEBC"
    case CGMService = "F8083532-849E-531C-C594-30F1F86A4EA5"
    case ServiceB = "F8084532-849E-531C-C594-30F1F86A4EA5"
}


enum DeviceInfoCharacteristicUUID: String {
    // Read
    // "DexcomUN"
    case ManufacturerNameString = "2A29"
}

enum CGMServiceCharacteristicUUID: String {
    // Read/Notify
    case Communication = "F8083533-849E-531C-C594-30F1F86A4EA5"
    // Write/Indicate
    case Control = "F8083534-849E-531C-C594-30F1F86A4EA5"
    // Read/Write/Indicate
    case Authentication = "F8083535-849E-531C-C594-30F1F86A4EA5"
    // Read/Write/Notify
    case ProbablyBackfill = "F8083536-849E-531C-C594-30F1F86A4EA5"
}

enum ServiceBCharacteristicUUID: String {
    // Write/Indicate
    case CharacteristicE = "F8084533-849E-531C-C594-30F1F86A4EA5"
    // Read/Write/Notify
    case CharacteristicF = "F8084534-849E-531C-C594-30F1F86A4EA5"
}
