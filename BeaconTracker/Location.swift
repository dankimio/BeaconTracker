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

  // MARK: - Properties

  dynamic var id = 0
  dynamic var latitude = 0.0
  dynamic var longitude = 0.0
  dynamic var address = ""
  dynamic var city = ""
  dynamic var country = ""
  dynamic var countryCode = ""
  dynamic var createdAt = Date()

  // MARK: - Computed properties

  var formattedAddress: String {
    guard !country.isEmpty else {
      return "Unknown address"
    }
    guard !city.isEmpty else {
      return country
    }
    return "\(city), \(country)"
  }

  var formattedDate: String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .short

    return dateFormatter.string(from: createdAt)
  }

  var coordinates: String {
    return "\(latitude), \(longitude)"
  }

  // MARK: - Init

  required convenience init?(map: Map) {
    self.init()
  }

  override static func primaryKey() -> String? {
    return "id"
  }

  func mapping(map: Map) {
    id <- map["id"]
    latitude <- map["latitude"]
    longitude <- map["longitude"]
    address <- map["address"]
    city <- map["city"]
    country <- map["country"]
    countryCode <- map["country_code"]
    createdAt <- (map["created_at"], ISO8601DateTransform())
  }
}
