//
//  BeaconsViewController.swift
//  BeaconTracker
//
//  Created by Dan Kim on 2017-04-21.
//  Copyright © 2017 Dan Kim. All rights reserved.
//

import UIKit
import CoreLocation
import UserNotifications
import NotificationBannerSwift
import RealmSwift

class BeaconsViewController: UITableViewController {

  let locationManager = CLLocationManager()
  let serverManager = ServerManager.shared

  let realm = try! Realm()
  lazy var beacons = try! Realm().objects(Beacon.self)

  override func viewDidLoad() {
    super.viewDidLoad()

    print(beacons)

    requestAuthorization()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    guard User.current != nil else {
      performSegue(withIdentifier: "Login", sender: self)
      return
    }

    listBeacons()
  }

  // MARK: - Table view

  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return beacons.count
  }

  override func tableView(_ tableView: UITableView,
                          cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    // Dequeue cell
    let cell = tableView.dequeueReusableCell(withIdentifier: "BeaconCell", for: indexPath)
      as! BeaconTableViewCell

    // Configure cell with beacon
    let beacon = beacons[indexPath.row]
    if beacon.name.isEmpty {
      cell.nameLabel.text = NSLocalizedString("beacon.unnamed", comment: "Unnamed beacon")
    } else {
      cell.nameLabel.text = beacon.name
    }

    let description: String
    if let lastLocation = beacon.lastLocation {
      description = "\(lastLocation.formattedAddress) – \(lastLocation.formattedDate)"
    } else {
      description = "No location data"
    }
    cell.descriptionLabel.text = description
    cell.enabledSwitch.isOn = (beacon.status == "enabled")

    return cell
  }

  // Override to support conditional editing of the table view.
  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    // Return false if you do not want the specified item to be editable.
    return true
  }

  // Override to support editing the table view.
  override func tableView(_ tableView: UITableView,
                          commit editingStyle: UITableViewCellEditingStyle,
                          forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      // Delete the row from the data source
//      beacons.remove(at: indexPath.row)
      tableView.deleteRows(at: [indexPath], with: .fade)
    }
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "ShowBeacon" {
      guard let beaconViewController = segue.destination as? BeaconViewController else { return }
      guard let cell = sender as? UITableViewCell else { return }
      guard let indexPath = tableView.indexPath(for: cell) else { return }

      beaconViewController.beacon = beacons[indexPath.row]
    }
  }

  // MARK: Actions

  @IBAction func unwindToBeacons(segue: UIStoryboardSegue) {
    guard User.current != nil else { return }
    listBeacons()
  }

  @IBAction func refreshTableView(_ sender: UIRefreshControl) {
    listBeacons()
  }

  // MARK: Helpers

  private func requestAuthorization() {
    // Configure notifications
    UNUserNotificationCenter
      .current()
      .requestAuthorization(options: [.alert, .badge, .sound]) {_,_ in
        print("requestAuthorization")
    }

    // Configure location manager
    guard CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) else {
      print("Monitoring unavailable")
      return
    }

    if CLLocationManager.authorizationStatus() != .authorizedAlways {
      locationManager.requestAlwaysAuthorization()
    }
  }

  private func listBeacons() {
    serverManager.listBeacons() { result in
      self.refreshControl?.endRefreshing()

      switch result {
      case .success(_):
        self.tableView.reloadData()
      case .failure(_):
        let banner = NotificationBanner(
          title: NSLocalizedString("beacons.banner.error", comment: "Could not load beacons"),
          style: .danger
        )
        banner.duration = 1
        banner.show()
      }
    }
  }

}
