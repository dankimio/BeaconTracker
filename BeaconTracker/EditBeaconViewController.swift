//
//  EditBeaconViewController.swift
//  BeaconTracker
//
//  Created by Dan Kim on 2017-06-06.
//  Copyright © 2017 Dan Kim. All rights reserved.
//

import UIKit
import NotificationBannerSwift

class EditBeaconViewController: UITableViewController {

  // MARK: - Outlets

  @IBOutlet weak var nameTextField: UITextField!

  // MARK: - Properties

  var beacon: Beacon!

  override func viewDidLoad() {
    super.viewDidLoad()

    nameTextField.text = beacon.name
    nameTextField.becomeFirstResponder()
  }

  @IBAction func save(_ sender: UIBarButtonItem) {
    guard validate() else { return }
    updateBeacon()
  }

  private func validate() -> Bool {
    guard nameTextField.text!.characters.count > 0 else {
      let message = NSLocalizedString("beacon.validations.name.presence", comment: "Name must be present")
      presentBanner(message: message)
      return false
    }

    return true
  }

  private func updateBeacon() {
    let attributes = ["name": nameTextField.text!]

    ServerManager.shared.updateBeacon(
      beacon: beacon,
      attributes: attributes,
      completion: { result in
        switch result {
        case .success(_):
          self.performSegue(withIdentifier: "UnwindFromEditBeaconToBeacon", sender: self)
        case .failure(_):
          let message = NSLocalizedString("editBeacon.banner.error", comment: "Could not update beacon")
          self.presentBanner(message: message)
        }
      }
    )
  }

  private func presentBanner(message: String) {
    let banner = NotificationBanner(title: message, style: .danger)
    banner.duration = 1
    banner.show()
  }
  
}
