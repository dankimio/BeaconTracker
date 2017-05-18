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

}
