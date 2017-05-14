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

class BeaconsViewController: UITableViewController {

  let locationManager = CLLocationManager()
  let serverManager = ServerManager.shared

  var beacons = [Beacon]()

  override func viewDidLoad() {
    super.viewDidLoad()

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.leftBarButtonItem = self.editButtonItem

    requestAuthorization()

    if let currentUser = User.current {
      listBeacons()
    } else {
      performSegue(withIdentifier: "Login", sender: self)
    }
  }

  // MARK: - Table view data source

  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return beacons.count
  }

  override func tableView(_ tableView: UITableView,
                          cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "BeaconCell", for: indexPath)
      as! BeaconTableViewCell
    let beacon = beacons[indexPath.row]

    cell.nameLabel.text = "Name"
    cell.descriptionLabel.text = "Moscow, Russia – Sat, Apr 22"
    cell.enabledSwitch.isOn = false

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

  // Override to support rearranging the table view.
  override func tableView(_ tableView: UITableView,
                          moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
  }

  // Override to support conditional rearranging of the table view.
  override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
    // Return false if you do not want the item to be re-orderable.
    return true
  }

  @IBAction func unwindToBeacons(segue: UIStoryboardSegue) {
    listBeacons()
  }

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
      switch result {
      case .success(let beacons):
        self.beacons = beacons
        self.tableView.reloadData()
      case .failure(_):
        print("LOL")
      }
    }
  }

}
