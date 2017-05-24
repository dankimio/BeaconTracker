//
//  TrackingManager.swift
//  BeaconTracker
//
//  Created by Dan Kim on 2017-05-25.
//  Copyright © 2017 Dan Kim. All rights reserved.
//

import UIKit
import CoreLocation
import UserNotifications

class TrackingManager: NSObject {

  // MARK: - Singleton

  static let shared = TrackingManager()
  override private init() {}

  // MARK: - Properties

  let locationManager = CLLocationManager()
  let region = CLBeaconRegion(
    proximityUUID: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
    identifier: "identifier"
  )

  var previousProximity: CLProximity?
  var backgroundTaskIdentifier: UIBackgroundTaskIdentifier?

  // MARK: - Computed properties

  var isMonitoring: Bool {
    return locationManager.monitoredRegions.count > 0
  }

  func startMonitoring() {
    guard !isMonitoring else { return }

    // Configure notifications
    UNUserNotificationCenter
      .current()
      .requestAuthorization(options: [.alert, .badge, .sound]) {_,_ in
        print("requestAuthorization")
    }

    // Configure location manager
    guard CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) else {
      print("Monitoring unavailable")
      return
    }

    if CLLocationManager.authorizationStatus() != .authorizedAlways {
      locationManager.requestAlwaysAuthorization()
    }

    region.notifyEntryStateOnDisplay = true
    locationManager.delegate = self

    locationManager.startMonitoring(for: region)
  }

  func stopMonitoring() {
    locationManager.stopMonitoring(for: region)
  }
}

extension TrackingManager: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
    print(locationManager.requestState(for: region))
  }

  func locationManager(_ manager: CLLocationManager,
                       didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
    print(beacons)

    guard let beacon = beacons.first else { return }

    // Notify of new proximity state
    if previousProximity != beacon.proximity {
      let message: String
      switch beacon.proximity {
      case .far: message = "Far"
      case .immediate: message = "Immediate"
      case .near: message = "Near"
      case .unknown: message = "Unknown"
      }

      let content = UNMutableNotificationContent()
      content.title = "Proximity"
      content.body = message
      content.sound = UNNotificationSound.default()

      let request = UNNotificationRequest(
        identifier: "beaconProximityChanged",
        content: content,
        trigger: nil
      )

      UNUserNotificationCenter.current().add(request)
    }

    previousProximity = beacon.proximity
  }

  func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
    print("didEnterRegion")

    let content = UNMutableNotificationContent()
    content.title = "didEnterRegion"
    content.body = "didEnterRegion"
    content.sound = UNNotificationSound.default()

    let request = UNNotificationRequest(
      identifier: "didEnterRegion",
      content: content,
      trigger: nil
    )

    UNUserNotificationCenter.current().add(request)

    // Start ranging in background
    guard let region = region as? CLBeaconRegion else { return }

    backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask(
      withName: "ranging",
      expirationHandler: nil
    )
    manager.startRangingBeacons(in: region)
  }

  func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
    print("didExitRegion")

    let content = UNMutableNotificationContent()
    content.title = "didExitRegion"
    content.body = "didExitRegion"
    content.sound = UNNotificationSound.default()

    let request = UNNotificationRequest(
      identifier: "didEnterRegion",
      content: content,
      trigger: nil
    )

    UNUserNotificationCenter.current().add(request)

    // Stop background ranging
    if let backgroundTaskIdentifier = backgroundTaskIdentifier {
      print("Ending background task")
      UIApplication.shared.endBackgroundTask(backgroundTaskIdentifier)
    }
  }

  func locationManager(_ manager: CLLocationManager,
                       didDetermineState state: CLRegionState, for region: CLRegion) {
    print("didDetermineState: ", terminator: "")

    switch state {
    case .inside: print("inside")
    case .outside: print("outside")
    case .unknown: print("unknown")
    }
  }

}
