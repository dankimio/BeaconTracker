//
//  RoundedButton.swift
//  BeaconTracker
//
//  Created by Dan Kim on 2017-04-22.
//  Copyright © 2017 Dan Kim. All rights reserved.
//

import UIKit

@IBDesignable
class RoundedButton: UIButton {

  @IBInspectable
  var cornerRadius: CGFloat = 0.0 {
    didSet {
      layer.cornerRadius = cornerRadius
    }
  }

}
