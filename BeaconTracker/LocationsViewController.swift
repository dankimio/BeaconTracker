//
//  LocationsViewController.swift
//  BeaconTracker
//
//  Created by Dan Kim on 2017-05-24.
//  Copyright © 2017 Dan Kim. All rights reserved.
//

import UIKit
import NotificationBannerSwift

class LocationsViewController: UITableViewController {

  var beacon: Beacon!
  var locations = [Location]()

  override func viewDidLoad() {
    super.viewDidLoad()

    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false

    loadLocations()
  }

  // MARK: - Table view data source

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return locations.count
  }

  override func tableView(_ tableView: UITableView,
                          cellForRowAt indexPath: IndexPath) -> UITableViewCell {

    let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath)

    let location = locations[indexPath.row]

    cell.textLabel?.text = location.formattedAddress
    cell.detailTextLabel?.text = "\(location.formattedDate) – \(location.coordinates)"

    return cell
  }

  // MARK: - Helpers

  func loadLocations() {
    ServerManager
      .shared
      .listLocations(beacon: beacon) { result in
        switch result {
        case .success(let locations):
          self.locations = locations
          self.tableView.reloadData()
        case .failure(_):
          let banner = NotificationBanner(title: "Could not load location history",
                                          subtitle: "Try again later",
                                          style: .danger)
          banner.duration = 1
          banner.show()
        }
      }
  }

}