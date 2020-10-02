//
//  ForgotPasswordViewController.swift
//  SurveysFeatureUIPrototype
//
//  Created by Duy Bui on 10/2/20.
//  Copyright © 2020 Duy Bui. All rights reserved.
//

import UIKit

class ForgotPasswordViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.navigationController?.isNavigationBarHidden = false
    let leftBarButton = UIBarButtonItem(image: UIImage(named: "Arrow")?.withRenderingMode(.alwaysOriginal),
                                        style: .plain,
                                        target: self,
                                        action: #selector(backToVC))
    self.navigationController!.navigationBar.setBackgroundImage(UIImage(), for: .default)
    self.navigationController!.navigationBar.shadowImage = UIImage()
    self.navigationController!.navigationBar.isTranslucent = true
    navigationItem.leftBarButtonItem = leftBarButton
  }
  
  
  @objc func backToVC(sender: AnyObject) {
    navigationController?.popViewController(animated: true)
  }
}
