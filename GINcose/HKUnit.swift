//
//  HKUnit.swift
//  GINcose
//
//  Created by Joe Ginley on 3/9/17.
//  Copyright © 2017 GINtech Systems. All rights reserved.
//

import HealthKit


extension HKUnit {
    static func milligramsPerDeciliter() -> HKUnit {
        return HKUnit.gramUnit(with: .milli).unitDivided(by: HKUnit.literUnit(with: .deci))
    }
}
