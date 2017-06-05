//
//  DetectedBeacon.swift
//  BeaconTracker
//
//  Created by Dan Kim on 2017-06-04.
//  Copyright © 2017 Dan Kim. All rights reserved.
//

import RealmSwift

class DetectedBeacon: Object {

  // MARK: - Properties

  dynamic var major = 0
  dynamic var minor = 0
  dynamic var latitude = 0.0
  dynamic var longitude = 0.0
  dynamic var isSynced = false
  dynamic var detectedAt = Date()

  // MARK: - Computed properties

  var majorMinorString: String {
    return "\(major)-\(minor)"
  }

  static var recent: [DetectedBeacon] {
    let realm = try! Realm()

    let calendar = Calendar.current
    let recently = calendar.date(byAdding: .minute, value: -10, to: Date())! as NSDate
    let predicate = NSPredicate(format: "detectedAt > %@ AND isSynced = false", recently)
    let results = realm.objects(DetectedBeacon.self).filter(predicate)

    return Array(results)
  }

}
