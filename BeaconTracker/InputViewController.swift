//
//  InputViewController.swift
//  BeaconTracker
//
//  Created by Dan Kim on 2017-05-19.
//  Copyright © 2017 Dan Kim. All rights reserved.
//

import UIKit
import NotificationBannerSwift
import Validator

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

    performSegue(withIdentifier: "UnwindFromInputToSettings", sender: self)
  }

  private func validate() -> Bool {
    guard textField.text!.characters.count > 0 else {
      presentBanner(message: "\(inputType.rawValue.capitalized) must be present")
      return false
    }

    if inputType == .email {
      let emailRule = ValidationRulePattern(pattern: EmailValidationPattern.standard,
                                            error: ValidationError())
      guard emailRule.validate(input: textField.text!) else {
        presentBanner(message: "Invalid email")
        return false
      }
    }

    if inputType == .password {
      let minLengthRule = ValidationRuleLength(min: 6, error: ValidationError())

      guard minLengthRule.validate(input: textField.text!) else {
        presentBanner(message: "Password is too short")
        return false
      }
    }

    return true
  }

  private func presentBanner(message: String) {
    let banner = NotificationBanner(title: message, style: .danger)
    banner.duration = 1
    banner.show()
  }

}
