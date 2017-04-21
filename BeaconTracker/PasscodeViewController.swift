//
//  PasscodeViewController.swift
//  BeaconTracker
//
//  Created by Dan Kim on 2017-04-21.
//  Copyright © 2017 Dan Kim. All rights reserved.
//

import UIKit
import CoreLocation

class PasscodeViewController: UIViewController {

  var beacon: CLBeacon!

  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
    print(beacon.proximityUUID)
  }

  @IBAction func add(_ sender: UIButton) {
    performSegue(withIdentifier: "UnwindFromPasscodeToBeacons", sender: self)
  }
}
