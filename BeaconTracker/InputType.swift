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
    case .email: return "Email"
    case .name: return "Name"
    case .password: return "Password"
    }
  }
}
