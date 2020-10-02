//
//  CustomLogoView.swift
//  SurveysFeatureUIPrototype
//
//  Created by Duy Bui on 10/2/20.
//  Copyright © 2020 Duy Bui. All rights reserved.
//

import UIKit

@IBDesignable
class CustomLogoView: UIView {
  
  @IBOutlet weak var logoImageView: UIImageView!
  @IBOutlet weak var titleLabel: UILabel!

  @IBInspectable
  var descriptionText: String? = nil {
    didSet {

      titleLabel.isHidden = descriptionText == nil
      titleLabel.text = descriptionText
    }
  }

  override init(frame: CGRect) {

    super.init(frame: frame)
    self.fromNib()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)

    self.fromNib()
  }
}
