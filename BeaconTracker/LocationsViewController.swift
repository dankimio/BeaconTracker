//
//  LocationsViewController.swift
//  BeaconTracker
//
//  Created by Dan Kim on 2017-05-24.
//  Copyright © 2017 Dan Kim. All rights reserved.
//

import UIKit
import RealmSwift
import NotificationBannerSwift

class LocationsViewController: UITableViewController {

  var beacon: Beacon!
  var locations: List<Location>!

  override func viewDidLoad() {
    super.viewDidLoad()

    print(beacon)

    loadLocations()
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "ShowAllLocationsOnMap" {
      guard let mapViewController = segue.destination as? MapViewController else { return }

      mapViewController.locations = Array(locations)
    }

    if segue.identifier == "ShowLocationOnMap" {
      guard let mapViewController = segue.destination as? MapViewController else { return }
      guard let cell = sender as? UITableViewCell else { return }
      guard let indexPath = tableView.indexPath(for: cell) else { return }

      mapViewController.locations = [Array(locations)[indexPath.row]]
    }
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

  // MARK: - Actions

  @IBAction func refreshTableView(_ sender: UIRefreshControl) {
    loadLocations()
  }

  // MARK: - Helpers

  func loadLocations() {
    ServerManager
      .shared
      .listLocations(beacon: beacon) { result in
        self.tableView.refreshControl?.endRefreshing()

        switch result {
        case .success(_):
          self.tableView.reloadData()
        case .failure(_):
          let banner = NotificationBanner(
            title: NSLocalizedString("locations.banner.error", comment: "Could not load location history"),
            style: .danger
          )
          banner.duration = 1
          banner.show()
        }
      }
  }

}
