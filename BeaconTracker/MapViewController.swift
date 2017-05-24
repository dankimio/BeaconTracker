//
//  MapViewController.swift
//  BeaconTracker
//
//  Created by Dan Kim on 2017-05-24.
//  Copyright © 2017 Dan Kim. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

  @IBOutlet weak var mapView: MKMapView!

  var locations: [Location]!

  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
    showLocations()
  }

  func showLocations() {
    let annotations = locations.map { location -> MKPointAnnotation in
      let coordinate = CLLocationCoordinate2D(latitude: location.latitude, 
                                              longitude: location.longitude)
      let annotation = MKPointAnnotation()
      annotation.coordinate = coordinate
      return annotation
    }

    print(annotations)
    for annotation in annotations {
      print(annotation.coordinate)
    }

    mapView.addAnnotations(annotations)
    mapView.showAnnotations(annotations, animated: true)
  }

}
