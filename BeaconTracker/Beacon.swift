//
//  Beacon.swift
//  BeaconTracker
//
//  Created by Dan Kim on 2017-04-22.
//  Copyright © 2017 Dan Kim. All rights reserved.
//

import RealmSwift
import ObjectMapper

class Beacon: Object, Mappable {
  dynamic var id: Int = 0
  dynamic var name: String = ""
  dynamic var major: Int = 0
  dynamic var minor: Int = 0
  dynamic var status: String = ""

  dynamic var lastLocation: Location?

  var majorMinorString: String {
    return "\(major)-\(minor)"
  }

  required convenience init?(map: Map) {
    self.init()
  }

  override static func primaryKey() -> String? {
    return "id"
  }

  func mapping(map: Map) {
    id <- map["id"]
    name <- map["name"]
    major <- map["major"]
    minor <- map["minor"]
    status <- map["status"]
  }
}
