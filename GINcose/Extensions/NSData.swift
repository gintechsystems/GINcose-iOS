//
//  NSData.swift
//  GINcose
//
//  Created by Joe Ginley on 3/9/17.
//  Copyright © 2017 GINtech Systems. All rights reserved.
//

import Foundation


public extension Data {
    @nonobjc subscript(range: Range<Int>) -> UInt16 {
        var dataArray: UInt16 = 0
        let buffer = UnsafeMutableBufferPointer(start: &dataArray, count: range.count)
        _ = self.copyBytes(to: buffer, from: range)
        
        return dataArray
    }
    
    @nonobjc subscript(range: Range<Int>) -> UInt32 {
        var dataArray: UInt32 = 0
        let buffer = UnsafeMutableBufferPointer(start: &dataArray, count: range.count)
        _ = self.copyBytes(to: buffer, from: range)
        
        return dataArray
    }
    
    subscript(range: Range<Int>) -> [UInt8] {
        var dataArray = [UInt8](repeating: 0, count: range.count)
        self.copyBytes(to: &dataArray, from: range)
        
        return dataArray
    }
}
