//
//  UIView+Extension.swift
//  SurveysFeatureUIPrototype
//
//  Created by Duy Bui on 10/2/20.
//  Copyright © 2020 Duy Bui. All rights reserved.
//
import UIKit

extension UIView {
  @discardableResult
  func fromNib<T: UIView>() -> T? {
    guard let view = UINib(nibName: String(describing: type(of: self)), bundle: nil).instantiate(withOwner: self, options: nil).first as? T else {
      return nil
    }
    view.frame = bounds
    view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    addSubview(view)
    return view
  }
  
  @IBInspectable
  var borderRadius: CGFloat {
    get {
      return layer.cornerRadius
    }
    set {
      layer.cornerRadius = newValue
      clipsToBounds = newValue > 0
    }
  }
  
  @IBInspectable
  var borderColor: UIColor? {
    set {
      layer.borderColor = newValue?.cgColor
    }
    get {
      guard let color = layer.borderColor else {
        return nil
      }
      return UIColor(cgColor: color)
    }
  }
  
  @IBInspectable
  var borderWidth: CGFloat {
    set {
      layer.borderWidth = newValue
    }
    get {
      return layer.borderWidth
    }
  }
  
  func addBlurToView(style: UIBlurEffect.Style) {
    let blurEffect = UIBlurEffect(style: style)
    let blurEffectView = UIVisualEffectView(effect: blurEffect)
    blurEffectView.frame = self.bounds
    blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    self.addSubview(blurEffectView)
  }
}
