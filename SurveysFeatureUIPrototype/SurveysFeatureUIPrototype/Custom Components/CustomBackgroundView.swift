//
//  CustomBackgroundView.swift
//  SurveysFeatureUIPrototype
//
//  Created by Duy Bui on 10/2/20.
//  Copyright © 2020 Duy Bui. All rights reserved.
//

import UIKit

class CustomBackgroundView: UIView {
  
  @IBOutlet weak var backgroundImageView: UIImageView!
  @IBOutlet weak var blurView: UIView!

  // MARK: - View Methods
  override init(frame: CGRect) {

    super.init(frame: frame)

    self.fromNib()
    blurView.addBlurToView(style: .systemMaterialDark)
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)

    self.fromNib()
    blurView.addBlurToView(style: .systemMaterialDark)
  }
}
