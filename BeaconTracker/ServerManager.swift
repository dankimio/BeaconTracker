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

//    private let baseURL = "https://beacon-tracker.herokuapp.com/api"
  private let baseURL = "http://localhost:3000/api"

  private init() {}

  private let defaultParams: Parameters = ["api_token": "foobar"]

  // MARK: Users

  func authenticate(email: String,
                    password: String,
                    completion: @escaping (Result<Void>) -> Void) {
    let params = [
      "user": ["email": email, "password": password]
    ]

    request(path: .authenticateUser, params: params).responseJSON() { response in
      switch response.result {
      case .success:
        completion(.success())
      case .failure:
        completion(.failure(NSError()))
      }
    }
  }

  // MARK: Beacons

  func listBeacons(completion: @escaping (Result<String>) -> Void) {
    request(path: .listBeacons, params: defaultParams)
      .responseJSON { response in
        switch response.result {
        case .success:
          let json = response.result.value! as! [Parameters]
          print(json)
          completion(.success("String"))
        case .failure:
          completion(.failure(NSError()))
        }
    }
  }

  func activateBeacon(majorMinorString: String,
                      passcode: String,
                      completion: @escaping (Result<Beacon>) -> Void) {
    let params: Parameters = [
      "api_token": "foobar",
      "beacon": ["passcode": passcode]
    ]

    request(path: .activateBeacon(majorMinor: majorMinorString), params: params)
      .responseJSON { response in
        print(response)

        switch response.result {
        case .success:
          let json = response.result.value! as! Parameters
          let beacon = Beacon(name: "Beacon", major: json["major"] as! Int, minor: json["minor"] as! Int)
          completion(.success(beacon))
        case .failure:
          completion(.failure(NSError()))
        }
    }
  }

  private func request(path: APIPath, params: Parameters? = nil) -> DataRequest {
    return Alamofire.request(
      baseURL + path.path,
      method: path.method,
      parameters: params,
      encoding: (path.method == .get) ? URLEncoding.default : JSONEncoding.default
    )
  }
  
}
