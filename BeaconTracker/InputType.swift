//
//  InputType.swift
//  BeaconTracker
//
//  Created by Dan Kim on 2017-05-20.
//  Copyright © 2017 Dan Kim. All rights reserved.
//

import Foundation

enum InputType: String {
  case email, name, password

  var title: String {
    switch self {
    case .email:
      return NSLocalizedString("inputType.email", comment: "Email placeholder")
    case .name:
      return NSLocalizedString("inputType.name", comment: "Name placeholder")
    case .password:
      return NSLocalizedString("inputType.password", comment: "Password placeholder")
    }
  }
}
