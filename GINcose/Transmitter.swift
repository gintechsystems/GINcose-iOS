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
    func transmitter(_ transmitter: Transmitter, didError error: Error)
    
    func transmitter(_ transmitter: Transmitter, didRead glucose: Glucose)
    
    //func transmitter(_ transmitter: Transmitter, didRead sensor: Sensor)
    
    func transmitter(_ transmitter: Transmitter, didReadUnknownData data: Data)
}


public enum TransmitterError: Error {
    case authenticationError(String)
    case controlError(String)
}


public final class Transmitter: BluetoothManagerDelegate {
    // The ID of the transmitter to connect to
    public var ID: String
    
    // The initial activation date of the transmitter
    public private(set) var activationDate: Date?
    
    private var lastTimeMessage: TransmitterTimeRxMessage?
    
    public weak var delegate: TransmitterDelegate?
    
    private let bluetoothManager = BluetoothManager()
    
    private var operationQueue = DispatchQueue(label: "com.loudnate.xDripG5.transmitterOperationQueue")
    
    public init(ID: String) {
        self.ID = ID
        
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
    
    public var isScanning: Bool {
        if #available(iOS 9.0, *) {
            return bluetoothManager.isScanning
        }
        
        return false
    }
    
    public var stayConnected: Bool {
        get {
            return bluetoothManager.stayConnected
        }
        set {
            bluetoothManager.stayConnected = newValue
            
            if newValue {
                bluetoothManager.scanForPeripheral()
            }
        }
    }

    func bluetoothManager(_ manager: BluetoothManager, isReadyWithError error: Error?) {
        if let error = error {
            self.delegate?.transmitter(self, didError: error)
            return
        }
        
        operationQueue.async {
            do {
                try self.authenticate()
                try self.control()
            } catch let error {
                manager.disconnect()
                
                self.delegate?.transmitter(self, didError: error)
            }
        }
    }
    
    private func lastTwoCharactersOfString(_ string: String) -> String {
        return string.substring(from: string.characters.index(string.endIndex, offsetBy: -2, limitedBy: string.startIndex)!)
    }
    
    func bluetoothManager(_ manager: BluetoothManager, shouldConnectPeripheral peripheral: CBPeripheral) -> Bool {
        if let name = peripheral.name , lastTwoCharactersOfString(name) == lastTwoCharactersOfString(ID) {
            return true
        } else {
            return false
        }
    }
    
    func bluetoothManager(_ manager: BluetoothManager, didReceiveControlResponse response: Data) {
        guard response.count > 0 else { return }
        
        switch response[0] {
        case GlucoseRxMessage.opcode:
            if  let glucoseMessage = GlucoseRxMessage(data: response),
                let timeMessage = lastTimeMessage,
                let activationDate = activationDate
            {
                self.delegate?.transmitter(self, didRead: Glucose(glucoseMessage: glucoseMessage, timeMessage: timeMessage, activationDate: activationDate))
                return
            }
        case CalibrationDataRxMessage.opcode, SessionStartRxMessage.opcode, SessionStopRxMessage.opcode:
        return // Ignore these messages
        case TransmitterTimeRxMessage.opcode:
            if let timeMessage = TransmitterTimeRxMessage(data: response) {
                self.activationDate = Date(timeIntervalSinceNow: -TimeInterval(timeMessage.currentTime))
                self.lastTimeMessage = timeMessage
                return
            }
        default:
            break
        }
        
        delegate?.transmitter(self, didReadUnknownData: response)
    }
    
    private func authenticate() throws {
        if  let data = try? bluetoothManager.readValueForCharacteristicAndWait(.Authentication),
            let status = AuthStatusRxMessage(data: data), status.authenticated == 1 && status.bonded == 1
        {
            NSLog("Transmitter already authenticated.")
        } else {
            do {
                try bluetoothManager.setNotifyEnabledAndWait(true, forCharacteristicUUID: .Authentication)
            } catch let error {
                throw TransmitterError.authenticationError("Error enabling notification: \(error)")
            }
            
            let authMessage = AuthRequestTxMessage()
            let data: Data
            
            do {
                data = try bluetoothManager.writeValueAndWait(authMessage.data, forCharacteristicUUID: .Authentication, expectingFirstByte: AuthChallengeRxMessage.opcode)
            } catch let error {
                throw TransmitterError.authenticationError("Error writing transmitter challenge: \(error)")
            }
            
            guard let response = AuthChallengeRxMessage(data: data) else {
                throw TransmitterError.authenticationError("Unable to parse auth challenge: \(data)")
            }
            
            guard response.tokenHash == self.calculateHash(authMessage.singleUseToken) else {
                throw TransmitterError.authenticationError("Transmitter failed auth challenge")
            }
            
            if let challengeHash = self.calculateHash(response.challenge) {
                let data: Data
                do {
                    data = try bluetoothManager.writeValueAndWait(AuthChallengeTxMessage(challengeHash: challengeHash).data, forCharacteristicUUID: .Authentication, expectingFirstByte: AuthStatusRxMessage.opcode)
                } catch let error {
                    throw TransmitterError.authenticationError("Error writing challenge response: \(error)")
                }
                
                guard let response = AuthStatusRxMessage(data: data) else {
                    throw TransmitterError.authenticationError("Unable to parse auth status: \(data)")
                }
                
                guard response.authenticated == 1 else {
                    throw TransmitterError.authenticationError("Transmitter rejected auth challenge")
                }
                
                if response.bonded != 0x1 {
                    do {
                        _ = try bluetoothManager.writeValueAndWait(KeepAliveTxMessage(time: 25).data, forCharacteristicUUID: .Authentication)
                    } catch let error {
                        throw TransmitterError.authenticationError("Error writing keep-alive for bond: \(error)")
                    }
                    
                    let data: Data
                    do {
                        // Wait for the OS dialog to pop-up before continuing.
                        data = try bluetoothManager.writeValueAndWait(BondRequestTxMessage().data, forCharacteristicUUID: .Authentication, timeout: 15, expectingFirstByte: AuthStatusRxMessage.opcode)
                    } catch let error {
                        throw TransmitterError.authenticationError("Error writing bond request: \(error)")
                    }
                    
                    guard let response = AuthStatusRxMessage(data: data) else {
                        throw TransmitterError.authenticationError("Unable to parse auth status: \(data)")
                    }
                    
                    guard response.bonded == 0x1 else {
                        throw TransmitterError.authenticationError("Transmitter failed to bond")
                    }
                }
            }
            
            do {
                try bluetoothManager.setNotifyEnabledAndWait(false, forCharacteristicUUID: .Authentication)
            } catch let error {
                throw TransmitterError.authenticationError("Error disabling notification: \(error)")
            }
        }
    }
    
    private func control() throws {
        do {
            try bluetoothManager.setNotifyEnabledAndWait(true, forCharacteristicUUID: .Control)
        } catch let error {
            throw TransmitterError.controlError("Error enabling notification: \(error)")
        }
        
        let timeData: Data
        do {
            timeData = try bluetoothManager.writeValueAndWait(TransmitterTimeTxMessage().data, forCharacteristicUUID: .Control, expectingFirstByte: TransmitterTimeRxMessage.opcode)
        } catch let error {
            throw TransmitterError.controlError("Error writing time request: \(error)")
        }
        
        guard let timeMessage = TransmitterTimeRxMessage(data: timeData) else {
            throw TransmitterError.controlError("Unable to parse time response: \(timeData)")
        }
        
        let activationDate = Date(timeIntervalSinceNow: -TimeInterval(timeMessage.currentTime))
        
        //let sensorData: Data
        let glucoseData: Data
        do {
            //sensorData = try bluetoothManager.writeValueAndWait(SensorTxMessage().data, forCharacteristicUUID: .Control, expectingFirstByte: SensorRxMessage.opcode)
            glucoseData = try bluetoothManager.writeValueAndWait(GlucoseTxMessage().data, forCharacteristicUUID: .Control, expectingFirstByte: GlucoseRxMessage.opcode)
        } catch let error {
            throw TransmitterError.controlError("Error writing glucose request: \(error)")
        }
        
        /*guard let sensorMessage = SensorRxMessage(data: sensorData) else {
            throw TransmitterError.ControlError("Unable to parse sensor response: \(sensorData)")*/
        
        guard let glucoseMessage = GlucoseRxMessage(data: glucoseData) else {
            throw TransmitterError.controlError("Unable to parse glucose response: \(glucoseData)")
        }
        
        // Update and notify
        self.lastTimeMessage = timeMessage
        self.activationDate = activationDate
        self.delegate?.transmitter(self, didRead: Glucose(glucoseMessage: glucoseMessage, timeMessage: timeMessage, activationDate: activationDate))
        
        do {
            try bluetoothManager.setNotifyEnabledAndWait(false, forCharacteristicUUID: .Control)
            _ = try bluetoothManager.writeValueAndWait(DisconnectTxMessage().data, forCharacteristicUUID: .Control)
        } catch {
        }
    }
    
    private func listenToControl() throws {
        do {
            try bluetoothManager.setNotifyEnabledAndWait(true, forCharacteristicUUID: .Control)
        } catch let error {
            throw TransmitterError.controlError("Error enabling notification: \(error)")
        }
    }
    
    private var cryptKey: Data? {
        return "00\(ID)00\(ID)".data(using: .utf8)
    }
    
    private func calculateHash(_ data: Data) -> Data? {
        guard data.count == 8, let key = cryptKey else {
            return nil
        }
        
        var doubleData = Data(capacity: data.count * 2)
        doubleData.append(data)
        doubleData.append(data)
        
        guard let outData = try? AESCrypt.encryptData(doubleData, usingKey: key) else {
            return nil
        }
        
        return outData.subdata(in: 0..<8)
    }
}
