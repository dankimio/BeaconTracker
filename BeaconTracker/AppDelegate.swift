//
//  AppDelegate.swift
//  BeaconTracker
//
//  Created by Dan Kim on 2017-03-12.
//  Copyright © 2017 Dan Kim. All rights reserved.
//

import UIKit
import CoreLocation
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  let locationManager = CLLocationManager()

  let region = CLBeaconRegion(
    proximityUUID: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
    major: 1,
    minor: 1,
    identifier: "Bag"
  )

  var previousProximity: CLProximity?
  var backgroundTaskIdentifier: UIBackgroundTaskIdentifier?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

    // Override point for customization after application launch.
    print("didFinishLaunching")
    print(launchOptions)

    // Configure notifications
    UNUserNotificationCenter
      .current()
      .requestAuthorization(options: [.alert, .badge, .sound]) {_,_ in
        print("requestAuthorization")
      }

    // Configure location manager
    guard CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) else {
      print("Monitoring unavailable")
      return false
    }

    if CLLocationManager.authorizationStatus() != .authorizedAlways {
      locationManager.requestAlwaysAuthorization()
    }

    region.notifyEntryStateOnDisplay = true

    locationManager.delegate = self
    locationManager.startMonitoring(for: region)

    return true
  }

  func applicationWillResignActive(_ application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.

  }

  func applicationDidEnterBackground(_ application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    print("didEnterBackground")
  }

  func applicationWillEnterForeground(_ application: UIApplication) {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    print("willEnterForeground")
  }

  func applicationDidBecomeActive(_ application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }

  func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }
  
}

extension AppDelegate: CLLocationManagerDelegate {
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

    if let backgroundTaskIdentifier = backgroundTaskIdentifier, beacon.proximity == .unknown {
      print("Ending background task")
      UIApplication.shared.endBackgroundTask(backgroundTaskIdentifier)
    }
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

//    UIApplication.shared.endBackgroundTask(backgroundTask)
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

