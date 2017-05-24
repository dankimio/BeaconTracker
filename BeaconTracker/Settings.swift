//
//  Settings.swift
//  BeaconTracker
//
//  Created by Dan Kim on 2017-05-25.
//  Copyright © 2017 Dan Kim. All rights reserved.
//

import Foundation

class Settings {

  // MARK: - Init

  static let instance = Settings()
  private init() {}

  // MARK: - Properties

  let userDefaults = UserDefaults.standard

  // MARK: - Computed properties

  var trackingEnabled: Bool {
    get { return userDefaults.bool(forKey: "trackingEnabled") }
    set {
      userDefaults.set(newValue, forKey: "trackingEnabled")

      let trackingManager = TrackingManager.shared
      newValue ? trackingManager.startMonitoring() : trackingManager.stopMonitoring()

      print("Tracking enabled: \(newValue)")
      print("Is monitoring: \(trackingManager.isMonitoring)")
    }
  }

}
