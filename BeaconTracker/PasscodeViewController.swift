//
//  PasscodeViewController.swift
//  BeaconTracker
//
//  Created by Dan Kim on 2017-04-21.
//  Copyright © 2017 Dan Kim. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire

class PasscodeViewController: UIViewController {

  var beacon: CLBeacon!

  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
//    print(beacon.proximityUUID)
  }

  @IBAction func add(_ sender: UIButton) {
    performSegue(withIdentifier: "UnwindFromPasscodeToBeacons", sender: self)

    let majorMinorString = "\(beacon.major)-\(beacon.minor)"
    let params = ["beacon": ["code": "1234"]]

    // TODO: activate the beacon on the server, save beacon on success, present alert otherwise
    Alamofire
      .request(
        "/api/beacons/\(majorMinorString)/activation",
        method: .post,
        parameters: params,
        encoding: JSONEncoding.default
      ).responseJSON { response in
        print(response)
      }
  }
}
