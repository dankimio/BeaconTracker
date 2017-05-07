//
//  ServerManager.swift
//  BeaconTracker
//
//  Created by Dan Kim on 2017-04-23.
//  Copyright © 2017 Dan Kim. All rights reserved.
//

//import enum Result.Result
import Alamofire

enum JSONError: Error {
  case lal
}

class ServerManager {
  static let shared = ServerManager()

  private let baseURL = "https://beacon-tracker.herokuapp.com/api"
//  private let baseURL = "http://localhost:3000/api"

  private init() {}

  func authenticate(email: String,
                    password: String,
                    completion: @escaping (Result<Void>) -> Void) {
    let params = [
      "user": ["email": email, "password": password]
    ]

    performRequest(path: .authenticateUser, params: params, completion: completion)
  }

  func activateBeacon(majorMinorString: String,
                      passcode: String,
                      completion: @escaping (Result<Void>) -> Void) {
    let params: Parameters = [
      "api_token": "foobar",
      "beacon": ["passcode": passcode]
    ]

    performRequest(
      path: .activateBeacon(majorMinor: majorMinorString),
      params: params,
      completion: completion
    )
  }

  private func performRequest(path: APIPath,
                              params: Parameters? = nil,
                              completion: @escaping (Result<Void>) -> Void) {
    Alamofire
      .request(
        baseURL + path.path,
        method: path.method,
        parameters: params,
        encoding: JSONEncoding.default)
      .responseJSON { response in
        print(response)

        switch response.result {
        case .success:
          completion(.success())
        case .failure:
          completion(.failure(NSError()))
        }
    }
  }
}
