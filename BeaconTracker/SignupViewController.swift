//
//  SignupViewController.swift
//  BeaconTracker
//
//  Created by Dan Kim on 2017-04-21.
//  Copyright © 2017 Dan Kim. All rights reserved.
//

import UIKit
import NotificationBannerSwift

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
    guard validate() else { return }

    ServerManager.shared.createUser(
      email: emailTextField.text!,
      name: nameTextField.text!,
      password: passwordTextField.text!,
      completion: { result in
        switch result {
        case .success(_):
          self.performSegue(withIdentifier: "UnwindFromSignupToBeacons", sender: self)
        case .failure(_):
          self.presentBanner(message: "User is invalid")
        }
      }
    )
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
      presentBanner(message: "Email is invalid")
      return false
    }
    guard nameTextField.text!.characters.count > 0 else {
      presentBanner(message: "Name must be present")
      return false
    }
    guard passwordTextField.text! != "" else {
      presentBanner(message: "Password must be present")
      return false
    }
    guard passwordTextField.text!.characters.count >= 6 else {
      presentBanner(message: "Password is too short")
      return false
    }
    guard passwordTextField.text! == passwordConfirmTextField.text! else {
      presentBanner(message: "Passwords do not match")
      return false
    }

    return true
  }

  private func presentBanner(message: String) {
    let banner = NotificationBanner(title: message, style: .danger)
    banner.duration = 1
    banner.show()
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
