//
//  TransmitterCommand.swift
//  GINcose
//
//  Created by Joe Ginley on 3/9/17.
//  Copyright © 2017 GINtech Systems. All rights reserved.
//

import Foundation


protocol TransmitterTxMessage {
    
    var byteSequence: [Any] { get }
    
    var data: Data { get }
    
}


extension TransmitterTxMessage {
    var data: Data {
        let data = NSMutableData()
        
        for item in byteSequence {
            switch item {
            case let i as Int8:
                var value = i
                
                data.append(&value, length: 1)
            case let i as UInt8:
                var value = i
                
                data.append(&value, length: 1)
            case let i as UInt16:
                var value = i
                
                data.append(&value, length: 2)
            case let i as UInt32:
                var value = i
                
                data.append(&value, length: 4)
            case let i as Data:
                data.append(i)
            default:
                fatalError("\(item) not supported")
            }
        }
        
        return data as Data
    }
}


protocol TransmitterRxMessage {
    
    init?(data: Data)
    
}
