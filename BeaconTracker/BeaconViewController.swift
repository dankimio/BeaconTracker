//
//  BeaconViewController.swift
//  BeaconTracker
//
//  Created by Dan Kim on 2017-05-24.
//  Copyright © 2017 Dan Kim. All rights reserved.
//

import UIKit
import NotificationBannerSwift
import MapKit
import RealmSwift

class BeaconViewController: UITableViewController {

  var beacon: Beacon!

  @IBOutlet weak var locationMapView: MKMapView!
  @IBOutlet weak var overlayView: UIView!

  @IBOutlet weak var trackingSwitch: UISwitch!
  @IBOutlet weak var notificationsSwitch: UISwitch!

  @IBOutlet weak var majorValueLabel: UILabel!
  @IBOutlet weak var minorValueLabel: UILabel!

  override func viewDidLoad() {
    super.viewDidLoad()

    print(beacon)

    self.showBeacon()
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "ShowLocations" {
      guard let locationsViewController = segue.destination
        as? LocationsViewController else { return }

      locationsViewController.beacon = beacon
      locationsViewController.locations = beacon.locations
    }
  }

  @IBAction func toggleTracking(_ sender: UISwitch) {
    let status = (sender.isOn ? "enabled" : "disabled")
    let attributes = ["status": status]

    ServerManager.shared.updateBeacon(beacon: beacon, attributes: attributes) { result in
      switch result {
      case .success(_): return
      case .failure(_):
        let message = (sender.isOn ? "Could not enable tracking" : "Could not disable tracking")
        self.presentBanner(message: message)
        self.trackingSwitch.setOn(!sender.isOn, animated: true)
      }
    }
  }

  // MARK: - Helpers

  private func showBeacon() {
    if let location = beacon.lastLocation {
      showLocation(location)
    } else {
      overlayView.isHidden = false
    }

    majorValueLabel.text = "\(beacon.major)"
    minorValueLabel.text = "\(beacon.minor)"
  }

  private func showLocation(_ location: Location) {
    let center = CLLocationCoordinate2D(latitude: location.latitude,
                                        longitude: location.longitude)
    let span = MKCoordinateSpan(latitudeDelta: 0.04, longitudeDelta: 0.04)
    let region = MKCoordinateRegion(center: center, span: span)
    locationMapView.setRegion(region, animated: true)

    let annotation = MKPointAnnotation()
    annotation.coordinate = center
    locationMapView.addAnnotation(annotation)
  }

  private func presentBanner(message: String) {
    let banner = NotificationBanner(title: message, style: .danger)
    banner.duration = 1
    banner.show()
  }

}
