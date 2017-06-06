//
//  LoginViewController.swift
//  BeaconTracker
//
//  Created by Dan Kim on 2017-04-21.
//  Copyright © 2017 Dan Kim. All rights reserved.
//

import UIKit
import Alamofire
import NotificationBannerSwift

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
          let message = NSLocalizedString("login.banner.invalidPassword", comment: "Invalid password")
          self.presentBanner(message: message)
        }
      }
  }

  // Resign first responder when tapped outside text field
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    view.endEditing(true)
  }

  private func presentBanner(message: String) {
    let banner = NotificationBanner(title: message, style: .danger)
    banner.duration = 1
    banner.show()
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
