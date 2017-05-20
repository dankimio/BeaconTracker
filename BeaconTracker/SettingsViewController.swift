//
//  SettingsViewController.swift
//  BeaconTracker
//
//  Created by Dan Kim on 2017-05-19.
//  Copyright © 2017 Dan Kim. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {

  @IBOutlet weak var trackingSwitch: UISwitch!

  override func viewDidLoad() {
    super.viewDidLoad()

    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false

    trackingSwitch.isOn = false
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard let tableViewCell = sender as? UITableViewCell else { return }
    guard let inputViewController = segue.destination as? InputViewController else { return }

    switch tableViewCell.tag {
    case 0:
      inputViewController.inputType = .email
    case 1:
      inputViewController.inputType = .name
    case 2:
      inputViewController.inputType = .password
    default:
      return
    }
  }

  @IBAction func unwindToSettings(segue: UIStoryboardSegue) {
    print("Unwind to settings")
  }

}
