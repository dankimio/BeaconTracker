//
//  Location.swift
//  BeaconTracker
//
//  Created by Dan Kim on 2017-05-24.
//  Copyright © 2017 Dan Kim. All rights reserved.
//

import RealmSwift
import ObjectMapper

class Location: Object, Mappable {
  dynamic var id = 0
  dynamic var latitude = 0.0
  dynamic var longitude = 0.0
  dynamic var address = ""
  dynamic var city = ""
  dynamic var country = ""
  dynamic var countryCode = ""

  required convenience init?(map: Map) {
    self.init()
  }

  func mapping(map: Map) {
    id <- map["id"]
    latitude <- map["latitude"]
    longitude <- map["longitude"]
    address <- map["address"]
    city <- map["city"]
    country <- map["country"]
    countryCode <- map["country_code"]
  }
}
