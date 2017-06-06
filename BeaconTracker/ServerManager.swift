//
//  ServerManager.swift
//  BeaconTracker
//
//  Created by Dan Kim on 2017-04-23.
//  Copyright © 2017 Dan Kim. All rights reserved.
//

import Alamofire
import ObjectMapper
import RealmSwift

enum JSONError: Error {
  case lal
}

struct ServerError: Error {
}

class ServerManager {
  static let shared = ServerManager()

//  private let baseURL = "https://beacon-tracker.herokuapp.com/api"
  private let baseURL = "http://localhost:3000/api"
//  private let baseURL = "http://192.168.0.64:3000/api"

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

  // MARK: - Users

  func authenticate(email: String,
                    password: String,
                    completion: @escaping (Result<User>) -> Void) {
    let params = [
      "user": ["email": email, "password": password]
    ]

    request(path: .authenticateUser, params: params).responseJSON() { response in
      switch response.result {
      case .success(let value):
        guard let json = value as? Parameters else { return }
        guard let user = User(json: json) else { return }

        user.save()

        completion(.success(user))
      case .failure(let error):
        completion(.failure(error))
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
      case .success(let value):
        guard let json = value as? Parameters else {
          completion(.failure(ServerError()))
          return
        }
        guard let user = User(json: json) else {
          completion(.failure(ServerError()))
          return
        }

        user.save()

        completion(.success(user))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func updateUser(attributes: Parameters,
                  completion: @escaping (Result<User>) -> Void) {
    let params: Parameters = [
      "api_token": apiToken!,
      "user": attributes
    ]

    request(path: .updateUser, params: params).responseJSON() { response in
      switch response.result {
      case .success(let value):
        guard let json = value as? Parameters else { return }
        guard let user = User(json: json) else { return }

        user.save()

        completion(.success(user))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }


  // MARK: - Beacons

  func listBeacons(completion: @escaping (Result<[Beacon]>) -> Void) {
    request(path: .listBeacons, params: defaultParams)
      .responseJSON { response in
        switch response.result {
        case .success(let value):
          guard let json = value as? [Parameters] else { return }

          let realm = try! Realm()

          realm.beginWrite()

          let beacons = json
            .flatMap { jsonBeacon -> Beacon? in
              guard let beacon = Mapper<Beacon>().map(JSON: jsonBeacon) else { return nil }

              realm.add(beacon, update: true)

              if let lastLocationJSON = jsonBeacon["last_location"] as? Parameters,
                let lastLocation = Mapper<Location>().map(JSON: lastLocationJSON) {
                realm.add(lastLocation, update: true)
                beacon.locations.append(lastLocation)
              }

              return beacon
            }

          try! realm.commitWrite()

          completion(.success(beacons))
        case .failure(let error):
          completion(.failure(error))
        }
    }
  }

  func activateBeacon(majorMinorString: String,
                      passcode: String,
                      completion: @escaping (Result<Beacon>) -> Void) {
    let params: Parameters = [
      "api_token": apiToken!,
      "beacon": ["passcode": passcode]
    ]

    request(path: .activateBeacon(majorMinor: majorMinorString), params: params)
      .responseJSON { response in
        print(response)

        switch response.result {
        case .success(let value):
          guard let json = value as? Parameters else {
            completion(.failure(NSError()))
            return
          }
          guard let beacon = Mapper<Beacon>().map(JSON: json) else {
            completion(.failure(NSError()))
            return
          }

          completion(.success(beacon))
        case .failure(let error):
          completion(.failure(error))
        }
    }
  }

  func updateBeacon(beacon: Beacon,
                    attributes: Parameters,
                    completion: @escaping (Result<Beacon>) -> Void) {
    let params: Parameters = [
      "api_token": apiToken!,
      "beacon": attributes
    ]

    request(path: .updateBeacon(beacon: beacon), params: params)
      .responseJSON { response in
        print(response)

        switch response.result {
        case .success(let value):
          guard let json = value as? Parameters else {
            completion(.failure(NSError()))
            return
          }
          guard let beacon = Mapper<Beacon>().map(JSON: json) else {
            completion(.failure(NSError()))
            return
          }

          completion(.success(beacon))
        case .failure(let error):
          completion(.failure(error))
        }
    }
  }

  // MARK: - Locations

  func listLocations(beacon: Beacon, completion: @escaping (Result<[Location]>) -> Void) {
    request(path: .listLocations(beacon: beacon), params: defaultParams)
      .responseJSON { response in
        switch response.result {
        case .success(let value):
          let json = value as! [Parameters]
          let locations = json.flatMap { Mapper<Location>().map(JSON: $0) }

          let realm = try! Realm()
          try! realm.write {
            // Clean up beacon's locations
            realm.delete(beacon.locations)

            // Persist new locations and assign to the beacon
            realm.add(locations, update: true)
            beacon.locations.append(objectsIn: locations)
          }

          completion(.success(locations))
        case .failure:
          completion(.failure(NSError()))
        }
    }
  }

  func createLocation(detectedBeacon: DetectedBeacon,
                      completion: @escaping (Result<Void>) -> Void) {

    let params: Parameters = [
      "api_token": apiToken!,
      "location": ["latitude": detectedBeacon.latitude, "longitude": detectedBeacon.longitude]
    ]

    request(path: .createLocation(detectedBeacon: detectedBeacon), params: params)
      .responseJSON { response in
        switch response.result {
        case .success(_):
          let realm = try! Realm()
          try! realm.write { detectedBeacon.isSynced = true }
          completion(.success())
        case .failure(let error):
          completion(.failure(error))
        }
      }
  }

  // MARK: - Helpers

  private func request(path: APIPath, params: Parameters? = nil) -> DataRequest {
    return Alamofire
      .request(
        baseURL + path.path,
        method: path.method,
        parameters: params,
        encoding: (path.method == .get) ? URLEncoding.default : JSONEncoding.default
      )
      .validate()
  }
  
}
