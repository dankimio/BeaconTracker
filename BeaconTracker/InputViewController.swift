//
//  InputViewController.swift
//  BeaconTracker
//
//  Created by Dan Kim on 2017-05-19.
//  Copyright © 2017 Dan Kim. All rights reserved.
//

import UIKit

class InputViewController: UITableViewController {

  @IBOutlet weak var textField: UITextField!

  override func viewDidLoad() {
    super.viewDidLoad()

    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false
    navigationItem.title = "Title"
  }

}
