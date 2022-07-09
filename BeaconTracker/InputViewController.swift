//
//  InputViewController.swift
//  BeaconTracker
//
//  Created by Dan Kim on 2017-05-19.
//  Copyright © 2017 Dan Kim. All rights reserved.
//

import UIKit
import NotificationBannerSwift
import Alamofire

class InputViewController: UITableViewController {

  var inputType: InputType!

  @IBOutlet weak var textField: UITextField!

  override func viewDidLoad() {
    super.viewDidLoad()

    guard let user = User.current else { return }

    navigationItem.title = inputType.title
    textField.placeholder = inputType.title

    switch inputType! {
    case .email:
      textField.text = user.email
    case .name:
      textField.text = user.name
    case .password:
      textField.isSecureTextEntry = true
    }

    textField.becomeFirstResponder()
  }

  @IBAction func save(_ sender: UIBarButtonItem) {
    guard validate() else { return }
    updateUser()
  }

  private func validate() -> Bool {
    guard textField.text!.count > 0 else {
      let messageFormat = NSLocalizedString(
        "user.validations.presence",
        comment: "Banner with placeholder for attribute name"
      )
      let message = String(format: messageFormat, inputType.rawValue.capitalized)
      presentBanner(message: message)
      return false
    }

    // TODO: implement email validation

    if inputType == .password {
      if textField.text!.count < 6 {
        let message = NSLocalizedString("user.validations.password.tooShort", comment: "Password is too short")
        presentBanner(message: message)
      }
    }

    return true
  }

  private func updateUser() {
    let attributes = [inputType.rawValue: textField.text!]

    ServerManager.shared.updateUser(
      attributes: attributes,
      completion: { result in
        switch result {
        case .success(_):
          self.performSegue(withIdentifier: "UnwindFromInputToSettings", sender: self)
        case .failure(_):
          let message = NSLocalizedString("input.banner.error", comment: "Could not update the user")
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
