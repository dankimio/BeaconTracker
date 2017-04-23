//
//  SignupViewController.swift
//  BeaconTracker
//
//  Created by Dan Kim on 2017-04-21.
//  Copyright © 2017 Dan Kim. All rights reserved.
//

import UIKit

class SignupViewController: UIViewController {

  @IBOutlet weak var emailTextField: UITextField!
  @IBOutlet weak var nameTextField: UITextField!
  @IBOutlet weak var passwordTextField: UITextField!
  @IBOutlet weak var passwordConfirmTextField: UITextField!

  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
  }

  @IBAction func signUp(_ sender: UIButton) {
    performSegue(withIdentifier: "UnwindFromSignupToBeacons", sender: self)
  }

  // Resign first responder when tapped outside text field
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    view.endEditing(true)
  }
}

extension SignupViewController: UITextFieldDelegate {

  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    switch textField {
    case emailTextField:
      nameTextField.becomeFirstResponder()
    case nameTextField:
      passwordTextField.becomeFirstResponder()
    case passwordTextField:
      passwordConfirmTextField.becomeFirstResponder()
    default:
      view.endEditing(true)
    }

    return true
  }
  
}
