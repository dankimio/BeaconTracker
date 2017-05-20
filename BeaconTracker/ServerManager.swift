//
//  ServerManager.swift
//  BeaconTracker
//
//  Created by Dan Kim on 2017-04-23.
//  Copyright © 2017 Dan Kim. All rights reserved.
//

import Alamofire
import ObjectMapper

enum JSONError: Error {
  case lal
}

class ServerManager {
  static let shared = ServerManager()

  //    private let baseURL = "https://beacon-tracker.herokuapp.com/api"
  private let baseURL = "http://localhost:3000/api"

  private init() {}

  private var defaultParams: Parameters {
    if let apiToken = apiToken {
      return ["api_token": apiToken]
    } else {
      return [:]
    }
  }

  private var apiToken: String? {
    return User.current?.apiToken
  }

  // MARK: Users

  func authenticate(email: String,
                    password: String,
                    completion: @escaping (Result<User>) -> Void) {
    let params = [
      "user": ["email": email, "password": password]
    ]

    request(path: .authenticateUser, params: params).responseJSON() { response in
      switch response.result {
      case .success:
        guard let json = response.result.value as? Parameters else { return }
        guard let user = User(json: json) else { return }

        user.save()

        completion(.success(user))
      case .failure:
        completion(.failure(NSError()))
      }
    }
  }

  func createUser(email: String,
                  name: String,
                  password: String,
                  completion: @escaping (Result<User>) -> Void) {
    let params = [
      "user": ["email": email, "name": name, "password": password]
    ]

    request(path: .createUser, params: params).responseJSON() { response in
      switch response.result {
      case .success:
        guard let json = response.result.value as? Parameters else { return }
        guard let user = User(json: json) else { return }

        user.save()

        completion(.success(user))
      case .failure:
        completion(.failure(NSError()))
      }
    }
  }

  func updateUser(attributes: Parameters,
                  completion: @escaping (Result<User>) -> Void) {
    let params: Parameters = [
      "api_token": apiToken,
      "user": attributes
    ]

    request(path: .updateUser, params: params).responseJSON() { response in
      switch response.result {
      case .success:
        guard let json = response.result.value as? Parameters else { return }
        guard let user = User(json: json) else { return }

        user.save()

        completion(.success(user))
      case .failure:
        completion(.failure(NSError()))
      }
    }
  }


  // MARK: Beacons

  func listBeacons(completion: @escaping (Result<[Beacon]>) -> Void) {
    request(path: .listBeacons, params: defaultParams)
      .responseJSON { response in
        switch response.result {
        case .success:
          let json = response.result.value! as! [Parameters]
          let beacons = json.map { Mapper<Beacon>().map(JSON: $0) }.flatMap { $0 }

          completion(.success(beacons))
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
          guard let json = response.result.value! as? Parameters else {
            completion(.failure(NSError()))
            return
          }
          guard let beacon = Mapper<Beacon>().map(JSON: json) else {
            completion(.failure(NSError()))
            return
          }

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
