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

  @IBAction func add(_ sender: UIButton) {
    //    let majorMinorString = "\(beacon.major)-\(beacon.minor)"
        let majorMinorString = "0-0"
        let params: [String: Any] = ["api_token": "foobar", "beacon": ["code": "1234"]]

    Alamofire
      .request(
        "https://beacon-tracker.herokuapp.com/api/beacons/\(majorMinorString)/activations",
        method: .post,
        parameters: params,
        encoding: JSONEncoding.default
      ).responseJSON { response in
        switch response.result {
        case .success:
          self.handleSuccess()
        case .failure:
          self.handleFailure()
        }
    }
  }

  private func handleSuccess() {
    performSegue(withIdentifier: "UnwindFromPasscodeToBeacons", sender: nil)
  }

  private func handleFailure() {
    let alertController = UIAlertController(
      title: "Error",
      message: "Invalid passcode",
      preferredStyle: .alert
    )

    let defaultAction = UIAlertAction(
      title: "OK",
      style: .default,
      handler: nil
    )
    alertController.addAction(defaultAction)

    present(alertController, animated: true, completion: nil)
  }
}
