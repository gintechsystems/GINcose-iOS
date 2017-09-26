//
//  LatestGlucose.swift
//  GINcose
//
//  Created by Joe Ginley on 3/10/16.
//  Copyright © 2016 GINtech Systems. All rights reserved.
//

import RealmSwift

@objcMembers
class GlucoseInfo : Object {
    dynamic var id = 0
    dynamic var glucose = 0
    dynamic var timestamp = ""
}
