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

    ServerManager
      .shared
      .showBeacon(majorMinorString: beacon.majorMinorString) { result in
        switch result {
        case .success(let beacon):
          self.beacon = beacon
          self.showBeacon()
        case .failure(_):
          let banner = NotificationBanner(title: "Could not load beacon",
                                          subtitle: "Try again later",
                                          style: .danger)
          banner.duration = 1
          banner.show()
        }
      }
  }

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

}
