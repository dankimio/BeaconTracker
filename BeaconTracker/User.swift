//
//  User.swift
//  BeaconTracker
//
//  Created by Dan Kim on 2017-05-14.
//  Copyright © 2017 Dan Kim. All rights reserved.
//

import Foundation

class User: NSObject, NSCoding {
  var id: Int
  var name: String
  var apiToken: String

  init(id: Int, name: String, apiToken: String) {
    self.id = id
    self.name = name
    self.apiToken = apiToken
  }

  init?(json: [String: Any]) {
    guard let id = json["id"] as? Int,
      let name = json["name"] as? String,
      let apiToken = json["api_token"] as? String
    else {
        return nil
    }

    self.id = id
    self.name = name
    self.apiToken = apiToken
  }

  required convenience init?(coder aDecoder: NSCoder) {
    let id = aDecoder.decodeInteger(forKey: "id")
    let name = aDecoder.decodeObject(forKey: "name") as! String
    let apiToken = aDecoder.decodeObject(forKey: "apiToken") as! String

    self.init(id: id, name: name, apiToken: apiToken)
  }

  static var current: User? {
    guard let data = UserDefaults.standard.object(forKey: "currentUser") as? Data else {
      return nil
    }
    guard let user = NSKeyedUnarchiver.unarchiveObject(with: data) as? User else {
      return nil
    }

    return user
  }

  func save() {
    let userDefaults = UserDefaults.standard
    let encodedUser = NSKeyedArchiver.archivedData(withRootObject: self)
    userDefaults.set(encodedUser, forKey: "currentUser")
    userDefaults.synchronize()
  }

  func encode(with aCoder: NSCoder) {
    aCoder.encode(id, forKey: "id")
    aCoder.encode(name, forKey: "name")
    aCoder.encode(apiToken, forKey: "apiToken")
  }
}
