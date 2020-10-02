//
//  SurveyCollectionViewCell.swift
//  SurveysFeatureUIPrototype
//
//  Created by Duy Bui on 10/2/20.
//  Copyright © 2020 Duy Bui. All rights reserved.
//

import UIKit

class SurveyCollectionViewCell: UICollectionViewCell {
  
  @IBOutlet weak var imageView: UIImageView!
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  func configureCell(image: UIImage?) {
    imageView.image = image
  }
}
