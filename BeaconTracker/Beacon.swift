//
//  Beacon.swift
//  BeaconTracker
//
//  Created by Dan Kim on 2017-04-22.
//  Copyright © 2017 Dan Kim. All rights reserved.
//

import Foundation

class Beacon {
  var name: String
  var major: Int
  var minor: Int

  init(name: String, major: Int, minor: Int) {
    self.name = name
    self.major = major
    self.minor = minor
  }
}
