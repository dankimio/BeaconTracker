//
//  LoginViewController.swift
//  BeaconTracker
//
//  Created by Dan Kim on 2017-04-21.
//  Copyright © 2017 Dan Kim. All rights reserved.
//

import UIKit
import Alamofire

class LoginViewController: UIViewController {

  @IBOutlet weak var emailTextField: UITextField!
  @IBOutlet weak var passwordTextField: UITextField!

  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
  }

  @IBAction func logIn(_ sender: UIButton) {
    let email = emailTextField.text!
    let password = passwordTextField.text!

    ServerManager
      .shared
      .authenticate(email: email, password: password) { result in
        switch result {
        case .success(_):
          self.performSegue(withIdentifier: "UnwindFromLoginToBeacons", sender: self)
        case .failure(_):
          self.handleFailure()
        }
      }
  }

  // Resign first responder when tapped outside text field
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    view.endEditing(true)
  }

  private func handleFailure() {
    let alertController = UIAlertController(
      title: "Error",
      message: "Invalid password",
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

extension LoginViewController: UITextFieldDelegate {

  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    switch textField {
    case emailTextField:
      passwordTextField.becomeFirstResponder()
    case passwordTextField:
      passwordTextField.resignFirstResponder()
    default:
      ()
    }

    return true
  }

}
