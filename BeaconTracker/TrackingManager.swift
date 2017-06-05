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
import RealmSwift

class TrackingManager: NSObject {

  // MARK: - Initialization

  static let shared = TrackingManager()

  // MARK: - Properties

  let locationManager = CLLocationManager()

  let region = CLBeaconRegion(
    proximityUUID: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
    identifier: "identifier"
  )

  var previousProximity: CLProximity?
  var lastLocation: CLLocation?
  var rangingTaskIdentifier: UIBackgroundTaskIdentifier?
  var syncTaskIdentifier: UIBackgroundTaskIdentifier?

  var isMonitoring: Bool {
    print("Monitored regions: \(locationManager.monitoredRegions)")
    print("Delegate: \(String(describing: locationManager.delegate))")
    return locationManager.monitoredRegions.count > 0
  }

  // MARK: - Initialization

  override private init() {
    // Configure notifications
    UNUserNotificationCenter
      .current()
      .requestAuthorization(options: [.alert, .badge, .sound]) {_,_ in
        print("requestAuthorization")
    }

    // Authorize for use in the background
    if CLLocationManager.authorizationStatus() != .authorizedAlways {
      locationManager.requestAlwaysAuthorization()
    }

    // Notify when the app is running
    region.notifyEntryStateOnDisplay = true

    // Geolocation configuration
    locationManager.desiredAccuracy = 100
    locationManager.distanceFilter = 100
  }

  // MARK: - Core

  func startMonitoring() {
    // Stop previous monitoring sessions
    stopMonitoring()

    // Ensure monitoring is available
    guard CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) else {
      print("Monitoring unavailable")
      return
    }

    locationManager.delegate = self
    locationManager.startMonitoring(for: region)
    print("Monitoring started for region: \(region)")
  }

  func stopMonitoring() {
    locationManager.stopMonitoring(for: region)
    print("Monitoring stopped for region: \(region)")
  }

  // MARK: - Helpers

  fileprivate func startRanging(region: CLBeaconRegion,
                                withLocationManager manager: CLLocationManager) {
    // Begin background task
    if rangingTaskIdentifier == nil {
      rangingTaskIdentifier = UIApplication.shared.beginBackgroundTask(
        withName: "ranging",
        expirationHandler: nil
      )
      print("Ranging background task started: \(rangingTaskIdentifier!)")
    }

    // Start ranging beacons
    manager.startRangingBeacons(in: region)
    print("Ranging started")
  }

  fileprivate func stopRanging(region: CLBeaconRegion,
                               withLocationManager manager: CLLocationManager) {
    // Stop ranging beacons
    locationManager.stopRangingBeacons(in: region)
    print("Ranging stopped")

    // Stop background task
    if let taskIdentifier = rangingTaskIdentifier {
      UIApplication.shared.endBackgroundTask(taskIdentifier)
      print("Ranging background task stopped: \(taskIdentifier)")
      rangingTaskIdentifier = nil
    }
  }

  fileprivate func assignLocationToDetectedBeacons() {
    // Begin background task
    if syncTaskIdentifier == nil {
      syncTaskIdentifier = UIApplication.shared.beginBackgroundTask(
        withName: "sync",
        expirationHandler: nil
      )
      print("Sync background task started: \(syncTaskIdentifier!)")
    }

    lastLocation = nil
    locationManager.requestLocation()
  }

  fileprivate func syncDetectedBeacons() {
    let detectedBeacons = DetectedBeacon.recent

    for detectedBeacon in detectedBeacons {
      ServerManager.shared.createLocation(detectedBeacon: detectedBeacon) { result in
        switch result {
        case .success(_):
          let realm = try! Realm()
          try! realm.write { detectedBeacon.isSynced = true }

          if detectedBeacon == detectedBeacons.last {
            // Stop background task
            if let taskIdentifier = self.syncTaskIdentifier {
              UIApplication.shared.endBackgroundTask(taskIdentifier)
              print("Sync background task stopped: \(taskIdentifier)")
              self.syncTaskIdentifier = nil
            }
          }
        case .failure(_):
          print("Could not create location for: \(detectedBeacon)")
        }
      }
    }
  }

  fileprivate func notify(title: String, body: String, identifier: String) {
    let content = UNMutableNotificationContent()
    content.title = title
    content.body = body
    content.sound = UNNotificationSound.default()

    let request = UNNotificationRequest(
      identifier: identifier,
      content: content,
      trigger: nil
    )

    UNUserNotificationCenter.current().add(request)
  }

}

// MARK: - CLLocationManagerDelegate

extension TrackingManager: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
    print("didStartMonitoringFor region: \(region))")
    print("didStartMonitoringFor state: \(locationManager.requestState(for: region))")
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

      let realm = try! Realm()
      let shouldNotify = realm
        .objects(Beacon.self)
        .filter("major = %@ AND minor = %@", beacon.major, beacon.minor)
        .count > 0

      print("shouldNotify: \(shouldNotify)")
      if shouldNotify {
        notify(title: "Proximity", body: message, identifier: "beaconProximityChanged")
      }

      if beacon.proximity == .unknown {
        let detectedBeacon = DetectedBeacon()
        detectedBeacon.major = beacon.major as! Int
        detectedBeacon.minor = beacon.minor as! Int

        let realm = try! Realm()
        try! realm.write { realm.add(detectedBeacon) }

        assignLocationToDetectedBeacons()
      }
    }

    previousProximity = beacon.proximity
  }

  func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
    print("didEnterRegion")
    notify(title: "didEnterRegion", body: "didEnterRegion", identifier: "didEnterRegion")

    // Start ranging in background
    guard let region = region as? CLBeaconRegion else { return }

    startRanging(region: region, withLocationManager: manager)
  }

  func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
    print("didExitRegion: \(region)")
    notify(title: "didExitRegion", body: "didExitRegion", identifier: "didExitRegion")

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
      print("outside: \(region)")
      guard let region = region as? CLBeaconRegion else { return }
      stopRanging(region: region, withLocationManager: manager)
    case .unknown: print("unknown")
    }
  }

  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    // Workaround for didUpdateLocations called multiple times
    guard lastLocation == nil else { return }

    print("didUpdateLocations: \(locations)")

    // Ensure location was set
    guard let location = locations.last else { return }
    lastLocation = location

    // Only recent beacons should be synced
    let detectedBeacons = DetectedBeacon.recent
    guard detectedBeacons.count > 0 else { return }

    // Write location data to Realm
    let realm = try! Realm()
    realm.beginWrite()
    for detectedBeacon in DetectedBeacon.recent {
      detectedBeacon.latitude = location.coordinate.latitude
      detectedBeacon.longitude = location.coordinate.longitude
    }
    try! realm.commitWrite()

    // Begin sync
    syncDetectedBeacons()
  }

  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("didFailWithError error: \(error)")
    return
  }

}
