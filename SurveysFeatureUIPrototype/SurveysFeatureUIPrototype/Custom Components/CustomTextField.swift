//
//  CustomTextField.swift
//  SurveysFeatureUIPrototype
//
//  Created by Duy Bui on 10/2/20.
//  Copyright © 2020 Duy Bui. All rights reserved.
//

import UIKit

@IBDesignable
class CustomTextField: UIView {

  @IBOutlet weak var textField: UITextField!
  @IBOutlet weak var transparentView: UIView!
  @IBOutlet weak var forgotButton: UIButton!

  @IBInspectable
  var placeholderText: String? {
    get {
      textField.attributedPlaceholder?.string
    }
    set {
      guard let newValue = newValue else {
        textField.attributedPlaceholder = nil
          return
      }

      let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.lightGray]

      let attributedText = NSAttributedString(string: newValue, attributes: attributes)

      textField.attributedPlaceholder = attributedText
    }
  }

  @IBInspectable
  var isSecuredField: Bool = false {
    didSet {
      textField.isSecureTextEntry = isSecuredField
    }
  }

  @IBInspectable
  var trailingText: String? {
    didSet {
      if let trailingText = trailingText {
        forgotButton.isHidden = false
        forgotButton.setTitle(trailingText, for: .normal)
      }
    }
  }

  @IBAction func didTapOnForgotButton(_ sender: Any) {

  }

  // MARK: - View Methods
  override init(frame: CGRect) {

    super.init(frame: frame)

    self.fromNib()
    transparentView.alpha = 0.2
    transparentView.layer.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)

    self.fromNib()
    transparentView.alpha = 0.2
    transparentView.layer.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor
  }
}
