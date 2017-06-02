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
    print("Monitored regions: \(locationManager.monitoredRegions)")
    print("Delegate: \(String(describing: locationManager.delegate))")
    return locationManager.monitoredRegions.count > 0
  }

  func startMonitoring() {
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

    // Authorize for use in the background
    if CLLocationManager.authorizationStatus() != .authorizedAlways {
      locationManager.requestAlwaysAuthorization()
    }

    // Notify when the app is running
    region.notifyEntryStateOnDisplay = true

    locationManager.delegate = self
    locationManager.startMonitoring(for: region)

    print("Monitoring started")
  }

  func stopMonitoring() {
    locationManager.stopMonitoring(for: region)
    print("Monitoring stopped for \(region)")
  }
}

extension TrackingManager: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
    print("didStartMonitoringFor, state: \(locationManager.requestState(for: region))")
  }

  func locationManager(_ manager: CLLocationManager,
                       didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
    print("didRangeBeacons: \(beacons)")

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

      print("didRangeBeacons: \(message)")

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

    startRanging(region: region, withLocationManager: manager)
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
    stopRanging(region: region as! CLBeaconRegion, withLocationManager: manager)
  }

  func locationManager(_ manager: CLLocationManager,
                       didDetermineState state: CLRegionState, for region: CLRegion) {
    print("didDetermineState: ", terminator: "")

    switch state {
    case .inside:
      print("inside")
      guard let region = region as? CLBeaconRegion else { return }
      startRanging(region: region, withLocationManager: manager)
    case .outside:
      print("outside")
      guard let region = region as? CLBeaconRegion else { return }
      stopRanging(region: region, withLocationManager: manager)
    case .unknown: print("unknown")
    }
  }

  private func startRanging(region: CLBeaconRegion, withLocationManager manager: CLLocationManager) {
    // Begin background task
    backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask(
      withName: "ranging",
      expirationHandler: nil
    )
    print("Background task started")

    // Start ranging beacons
    manager.startRangingBeacons(in: region)
  }

  private func stopRanging(region: CLBeaconRegion, withLocationManager manager: CLLocationManager) {
    // Stop ranging beacons
    locationManager.stopRangingBeacons(in: region)

    // Stop background task
    if let backgroundTaskIdentifier = backgroundTaskIdentifier {
      UIApplication.shared.endBackgroundTask(backgroundTaskIdentifier)
      print("Background task stopped")
    }
  }

}
