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

  @IBOutlet weak var passcodeTextField: UITextField!

  var beacon: CLBeacon!

  override func viewDidLoad() {
    super.viewDidLoad()

    passcodeTextField.becomeFirstResponder()
  }

  @IBAction func add(_ sender: UIButton) {
    guard let passcode = passcodeTextField.text else { return }

    let majorMinorString = "\(beacon.major)-\(beacon.minor)"

    ServerManager
      .shared
      .activateBeacon(majorMinorString: majorMinorString, passcode: passcode) { result in
        switch result {
        case .success(_):
          self.handleSuccess()
        case .failure(_):
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
