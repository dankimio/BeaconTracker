//
//  NewBeaconViewController.swift
//  BeaconTracker
//
//  Created by Dan Kim on 2017-04-21.
//  Copyright © 2017 Dan Kim. All rights reserved.
//

import UIKit
import CoreLocation

class NewBeaconViewController: UIViewController {

  let locationManager = CLLocationManager()
  let region = CLBeaconRegion(
    proximityUUID: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
    identifier: "identifier"
  )

  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
    locationManager.delegate = self
    locationManager.startRangingBeacons(in: region)
  }

  @IBAction func cancel(_ sender: UIBarButtonItem) {
    performSegue(withIdentifier: "UnwindFromNewBeaconToBeacons", sender: self)
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard let passcodeViewController = segue.destination as? PasscodeViewController else { return }
    guard let beacon = sender as? CLBeacon else { return }
    passcodeViewController.beacon = beacon
  }

}

extension NewBeaconViewController: CLLocationManagerDelegate {

  func locationManager(_ manager: CLLocationManager,
                       didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
    print(beacons)

    guard let beacon = beacons.first else { return }
    guard beacon.proximity == .immediate else { return }

    performSegue(withIdentifier: "Passcode", sender: beacon)
    locationManager.stopRangingBeacons(in: region)
  }

}
