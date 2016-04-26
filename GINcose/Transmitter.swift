//
//  Transmitter.swift
//  GINcose
//
//  Created by Joe Ginley on 3/9/16.
//  Copyright © 2016 GINtech Systems. All rights reserved.
//

import Foundation
import CoreBluetooth


public protocol TransmitterDelegate: class {
    
    func transmitter(transmitter: Transmitter, didReadGlucose glucose: GlucoseRxMessage)
    
    func transmitter(transmitter: Transmitter, didReadSensor sensor: SensorRxMessage)
    
    func transmitter(transmitter: Transmitter, didError error: ErrorType)
}


public enum TransmitterError: ErrorType {
    case AuthenticationError(String)
    case ControlError(String)
}


public class Transmitter: BluetoothManagerDelegate {
    
    public var ID: String
    
    public var startTimeInterval: NSTimeInterval?
    
    public weak var delegate: TransmitterDelegate?
    
    private let bluetoothManager = BluetoothManager()
    
    private var operationQueue = dispatch_queue_create("com.gintechsystems.GINcose.transmitterOperationQueue", dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_USER_INITIATED, 0))
    
    public init(ID: String, startTimeInterval: NSTimeInterval?) {
        self.ID = ID
        self.startTimeInterval = startTimeInterval
        
        bluetoothManager.delegate = self
    }
    
    public func resumeScanning() {
        if stayConnected {
            bluetoothManager.scanForPeripheral()
        }
    }
    
    public func stopScanning() {
        bluetoothManager.disconnect()
    }
    
    @available(iOS 9.0, *)
    public var isScanning: Bool {
        return bluetoothManager.isScanning
    }
    
    public var stayConnected: Bool {
        get {
            return bluetoothManager.stayConnected
        }
        set {
            bluetoothManager.stayConnected = newValue
        }
    }
    
    // MARK: - BluetoothManagerDelegate
    
    func bluetoothManager(manager: BluetoothManager, isReadyWithError error: NSError?) {
        if let error = error {
            self.delegate?.transmitter(self, didError: error)
            return
        }
        
        dispatch_async(operationQueue) {
            do {
                try self.authenticate()
                try self.control()
            } catch let error {
                manager.disconnect()
                
                self.delegate?.transmitter(self, didError: error)
            }
        }
    }
    
    private func lastTwoCharactersOfString(string: String) -> String {
        return string.substringFromIndex(string.endIndex.advancedBy(-2, limit: string.startIndex))
    }
    
    func bluetoothManager(manager: BluetoothManager, shouldConnectPeripheral peripheral: CBPeripheral) -> Bool {
        if let name = peripheral.name where lastTwoCharactersOfString(name) == lastTwoCharactersOfString(ID) {
            return true
        }
        else {
            return false
        }
    }
    
    // MARK: - Helpers
    
    private func authenticate() throws {
        if let data = try? bluetoothManager.readValueForCharacteristicAndWait(.Authentication),
            status = AuthStatusRxMessage(data: data) where status.authenticated == 1 && status.bonded == 1
        {
            NSLog("Transmitter already authenticated.")
        }
        else {
            do {
                try bluetoothManager.setNotifyEnabledAndWait(true, forCharacteristicUUID: .Authentication)
            } catch let error {
                throw TransmitterError.AuthenticationError("Error enabling notification: \(error)")
            }
            
            let authMessage = AuthRequestTxMessage()
            let data: NSData
            
            do {
                data = try bluetoothManager.writeValueAndWait(authMessage.data, forCharacteristicUUID: .Authentication, expectingFirstByte: AuthChallengeRxMessage.opcode)
            } catch let error {
                throw TransmitterError.AuthenticationError("Error writing transmitter challenge: \(error)")
            }
            
            guard let response = AuthChallengeRxMessage(data: data) else {
                throw TransmitterError.AuthenticationError("Unable to parse auth challenge: \(data)")
            }
            
            guard response.tokenHash == self.calculateHash(authMessage.singleUseToken) else {
                throw TransmitterError.AuthenticationError("Transmitter failed auth challenge")
            }
            
            if let challengeHash = self.calculateHash(response.challenge) {
                let data: NSData
                do {
                    data = try bluetoothManager.writeValueAndWait(AuthChallengeTxMessage(challengeHash: challengeHash).data, forCharacteristicUUID: .Authentication, expectingFirstByte: AuthStatusRxMessage.opcode)
                } catch let error {
                    throw TransmitterError.AuthenticationError("Error writing challenge response: \(error)")
                }
                
                guard let response = AuthStatusRxMessage(data: data) else {
                    throw TransmitterError.AuthenticationError("Unable to parse auth status: \(data)")
                }
                
                guard response.authenticated == 1 else {
                    throw TransmitterError.AuthenticationError("Transmitter rejected auth challenge")
                }
                
                if response.bonded != 0x1 {
                    do {
                        try bluetoothManager.writeValueAndWait(KeepAliveTxMessage(time: 25).data, forCharacteristicUUID: .Authentication)
                    } catch let error {
                        throw TransmitterError.AuthenticationError("Error writing keep-alive for bond: \(error)")
                    }
                    
                    let data: NSData
                    do {
                        // Wait for the OS dialog to pop-up before continuing.
                        data = try bluetoothManager.writeValueAndWait(BondRequestTxMessage().data, forCharacteristicUUID: .Authentication, timeout: 15, expectingFirstByte: AuthStatusRxMessage.opcode)
                    } catch let error {
                        throw TransmitterError.AuthenticationError("Error writing bond request: \(error)")
                    }
                    
                    guard let response = AuthStatusRxMessage(data: data) else {
                        throw TransmitterError.AuthenticationError("Unable to parse auth status: \(data)")
                    }
                    
                    guard response.bonded == 0x1 else {
                        throw TransmitterError.AuthenticationError("Transmitter failed to bond")
                    }
                }
            }
            
            do {
                try bluetoothManager.setNotifyEnabledAndWait(false, forCharacteristicUUID: .Authentication)
            } catch let error {
                throw TransmitterError.AuthenticationError("Error disabling notification: \(error)")
            }
        }
    }
    
    private func control() throws {
        do {
            try bluetoothManager.setNotifyEnabledAndWait(true, forCharacteristicUUID: .Control)
        } catch let error {
            throw TransmitterError.ControlError("Error enabling notification: \(error)")
        }
        
        if startTimeInterval == nil {
            let timeData: NSData
            do {
                timeData = try bluetoothManager.writeValueAndWait(TransmitterTimeTxMessage().data, forCharacteristicUUID: .Control, expectingFirstByte: TransmitterTimeRxMessage.opcode)
            } catch let error {
                throw TransmitterError.ControlError("Error writing time request: \(error)")
            }
            
            guard let timeMessage = TransmitterTimeRxMessage(data: timeData) else {
                throw TransmitterError.ControlError("Unable to parse time response: \(timeData)")
            }
            
            self.startTimeInterval = NSDate().timeIntervalSince1970 - NSTimeInterval(timeMessage.currentTime)
        }
        
        let glucoseData: NSData
        do {
            glucoseData = try bluetoothManager.writeValueAndWait(GlucoseTxMessage().data, forCharacteristicUUID: .Control, expectingFirstByte: GlucoseRxMessage.opcode)
        } catch let error {
            throw TransmitterError.ControlError("Error writing glucose request: \(error)")
        }
        
        guard let glucoseMessage = GlucoseRxMessage(data: glucoseData) else {
            throw TransmitterError.ControlError("Unable to parse glucose response: \(glucoseData)")
        }
        
        self.delegate?.transmitter(self, didReadGlucose: glucoseMessage)
        
        let sensorData: NSData
        do {
            sensorData = try bluetoothManager.writeValueAndWait(SensorTxMessage().data, forCharacteristicUUID: .Control, expectingFirstByte: SensorRxMessage.opcode)
        } catch let error {
            throw TransmitterError.ControlError("Error writing sensor request: \(error)")
        }
        
        guard let sensorMessage = SensorRxMessage(data: sensorData) else {
            throw TransmitterError.ControlError("Unable to parse sensor response: \(sensorData)")
        }
        
        self.delegate?.transmitter(self, didReadSensor: sensorMessage)
        
        do {
            try bluetoothManager.setNotifyEnabledAndWait(false, forCharacteristicUUID: .Control)
            try bluetoothManager.writeValueAndWait(DisconnectTxMessage().data, forCharacteristicUUID: .Control)
        } catch {
        }
    }
    
    private var cryptKey: NSData? {
        return "00\(ID)00\(ID)".dataUsingEncoding(NSUTF8StringEncoding)
    }
    
    private func calculateHash(data: NSData) -> NSData? {
        guard data.length == 8, let key = cryptKey, outData = NSMutableData(length: 16) else {
            return nil
        }
        
        let doubleData = NSMutableData(data: data)
        doubleData.appendData(data)
        
        let status = CCCrypt(
            0, // kCCEncrypt
            0, // kCCAlgorithmAES
            0x0002, // kCCOptionECBMode
            key.bytes,
            key.length,
            nil,
            doubleData.bytes,
            doubleData.length,
            outData.mutableBytes,
            outData.length,
            nil
        )
        
        if status != 0 { // kCCSuccess
            return nil
        } else {
            return outData[0..<8]
        }
    }
}