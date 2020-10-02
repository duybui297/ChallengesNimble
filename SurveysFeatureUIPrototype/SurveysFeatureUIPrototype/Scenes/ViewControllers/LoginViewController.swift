//
//  LoginViewController.swift
//  SurveysFeatureUIPrototype
//
//  Created by Duy Bui on 10/2/20.
//  Copyright © 2020 Duy Bui. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

  @IBOutlet weak var emailTextField: CustomTextField!
  @IBOutlet weak var passwordTextField: CustomTextField!

  override func viewDidLoad() {
    super.viewDidLoad()
  }

  @IBAction func didTapOnLoginButton(_ sender: Any) {
    let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
    guard let homeVC = storyboard.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController else {
      print("Instantiate HomeViewController Failed at Main Storyboard")
      return
    }

    self.navigationController?.pushViewController(homeVC, animated: true)
  }
}
