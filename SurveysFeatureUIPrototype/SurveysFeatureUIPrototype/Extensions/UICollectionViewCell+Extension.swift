//
//  UICollectionViewCell+Extension.swift
//  SurveysFeatureUIPrototype
//
//  Created by Duy Bui on 10/2/20.
//  Copyright © 2020 Duy Bui. All rights reserved.
//

import UIKit

protocol CellProtocol {

  static var reuseIdentifier: String { get }
}

extension CellProtocol {

  /// Take the name of xib file as reuseIdentifier
  static var reuseIdentifier: String {
    return String(describing: self)
  }
}

extension UICollectionViewCell: CellProtocol {}

extension UICollectionView {
  func registerWithNib<T: UICollectionViewCell>(_: T.Type) {
    let nib = UINib(nibName: T.reuseIdentifier, bundle: Bundle(for: T.self))
    register(nib, forCellWithReuseIdentifier: T.reuseIdentifier)
  }
}
