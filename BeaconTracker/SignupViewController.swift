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
    if validate() {
      performSegue(withIdentifier: "UnwindFromSignupToBeacons", sender: self)
    }
  }

  // Resign first responder when tapped outside text field
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    view.endEditing(true)
  }

  private var isEmailValid: Bool {
    do {
      let regex = try NSRegularExpression(pattern: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}", options: .caseInsensitive)
      return regex.firstMatch(in: emailTextField.text!, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, emailTextField.text!.characters.count)) != nil
    } catch {
      return false
    }
  }

  private func validate() -> Bool {
    guard isEmailValid else {
      presentAlertController(message: "Email is invalid")
      return false
    }
    guard nameTextField.text!.characters.count > 0 else {
      presentAlertController(message: "Name must be present")
      return false
    }
    guard passwordTextField.text! != "" else {
      presentAlertController(message: "Password must be present")
      return false
    }
    guard passwordTextField.text!.characters.count >= 6 else {
      presentAlertController(message: "Password is too short")
      return false
    }
    guard passwordTextField.text! == passwordConfirmTextField.text! else {
      presentAlertController(message: "Passwords do not match")
      return false
    }

    return true
  }

  private func presentAlertController(message: String) {
    let alertController = UIAlertController(
      title: "Error",
      message: message,
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
