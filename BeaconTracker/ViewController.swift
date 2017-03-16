//
//  ViewController.swift
//  BeaconTracker
//
//  Created by Dan Kim on 2017-03-12.
//  Copyright © 2017 Dan Kim. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {

  let locationManager = CLLocationManager()

  let region = CLBeaconRegion(
    proximityUUID: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
    major: 1,
    minor: 1,
    identifier: "Bag"
  )

  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view, typically from a nib.
//    guard CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) else {
//      print("Monitoring unavailable")
//      return
//    }
//
//    if CLLocationManager.authorizationStatus() != .authorizedAlways {
//      locationManager.requestAlwaysAuthorization()
//    }
//
//    locationManager.delegate = self
//    locationManager.startRangingBeacons(in: region)
  }

}

//extension ViewController: CLLocationManagerDelegate {
//  func locationManager(_ manager: CLLocationManager,
//                       didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
//    print(beacons)
//  }
//
//  func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
//    print("didEnterRegion")
//    print(region)
//  }
//
//  func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
//    print("didExitRegion")
//    print(region)
//  }
//}
