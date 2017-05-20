//
//  APIPath.swift
//  BeaconTracker
//
//  Created by Dan Kim on 2017-05-08.
//  Copyright © 2017 Dan Kim. All rights reserved.
//

import Foundation
import Alamofire

enum APIPath {
  case showUser
  case createUser
  case updateUser
  case authenticateUser
  case listBeacons
  case showBeacon(majorMinor: String)
  case activateBeacon(majorMinor: String)

  var path: String {
    switch self {
    case .showUser:
      return "/user"
    case .createUser:
      return "/user"
    case .updateUser:
      return "/user"
    case .authenticateUser:
      return "/user/authenticate"
    case .listBeacons:
      return "/beacons"
    case .showBeacon(let majorMinor):
      return "/beacon/\(majorMinor)"
    case .activateBeacon(let majorMinor):
      return "/beacons/\(majorMinor)/activations"
    }
  }

  var method: HTTPMethod {
    switch self {
    case .createUser:
      return .post
    case .updateUser:
      return .patch
    case .authenticateUser:
      return .post
    case .activateBeacon(_):
      return .post
    default:
      return .get
    }
  }
}
