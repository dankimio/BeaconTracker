//
//  SettingsViewController.swift
//  BeaconTracker
//
//  Created by Dan Kim on 2017-05-19.
//  Copyright © 2017 Dan Kim. All rights reserved.
//

import UIKit
import NotificationBannerSwift

class SettingsViewController: UITableViewController {

  // MARK: Outlets

  @IBOutlet weak var emailLabel: UILabel!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var trackingSwitch: UISwitch!

  // MARK: UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    // Profile
    loadUser()

    // Settings
    trackingSwitch.isOn = Settings.instance.trackingEnabled
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

  // MARK: Actions

  @IBAction func toggleTracking(_ sender: UISwitch) {
    Settings.instance.trackingEnabled = sender.isOn
  }

  @IBAction func logOut(_ sender: Any) {
//    guard let user = User.current else { return }

    User.current!.logOut()
    performSegue(withIdentifier: "UnwindFromSettingsToBeacons", sender: self)
  }

  @IBAction func unwindToSettings(segue: UIStoryboardSegue) {
    loadUser()

    let banner = NotificationBanner(title: "Profile was successfully updated", style: .success)
    banner.duration = 1
    banner.show()
  }

  // MARK: Helpers

  private func loadUser() {
    guard let user = User.current else { return }

    emailLabel.text = user.email
    nameLabel.text = user.name
    trackingSwitch.isOn = false
  }

}
