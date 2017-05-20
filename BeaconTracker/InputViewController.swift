//
//  InputViewController.swift
//  BeaconTracker
//
//  Created by Dan Kim on 2017-05-19.
//  Copyright © 2017 Dan Kim. All rights reserved.
//

import UIKit

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

}
