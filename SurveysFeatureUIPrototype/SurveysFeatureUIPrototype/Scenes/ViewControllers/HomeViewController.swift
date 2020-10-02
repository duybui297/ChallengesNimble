//
//  HomeViewController.swift
//  SurveysFeatureUIPrototype
//
//  Created by Duy Bui on 10/2/20.
//  Copyright © 2020 Duy Bui. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

  @IBOutlet weak var collectionView: UICollectionView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var descriptionLabel: UILabel!
  @IBOutlet weak var pageControl: UIPageControl!

  private struct Data {
    let title: String
    let description: String
    let image: String
  }

  private let arrays = [Data(title: "Working from home Check-In",
                             description: "We would like to know how you feel about our work from home...",
                             image: "image1"),
                        Data(title: "Career training and development",
                             description: "We would like to know what are your goals and skills you wanted....",
                             image: "Image2"),
                        Data(title: "Inclusion and belonging",
                             description: "Building a workplace culture that prioritizes belonging and inclusio...",
                             image: "Image3")]

  override func viewDidLoad() {
    super.viewDidLoad()

    collectionView.delegate = self
    collectionView.dataSource = self
    collectionView.registerWithNib(SurveyCollectionViewCell.self)
    pageControl.numberOfPages = arrays.count
  }

  @IBAction func didTapOnDetailedSurvey(_ sender: Any) {
    self.navigationController?.pushViewController(UIViewController(), animated: true)
  }
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 3
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let data = arrays[indexPath.row]
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SurveyCollectionViewCell", for: indexPath) as! SurveyCollectionViewCell
    cell.configureCell(image: UIImage(named: data.image))
    return cell
  }

  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize {

    return CGSize(width: UIScreen.main.bounds.width,
                  height: collectionView.frame.height)
  }
}


extension HomeViewController: UIScrollViewDelegate {

  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    let xOffset = self.collectionView.contentOffset.x
    let width = self.collectionView.bounds.size.width
    let index = Int(xOffset/width) % 3
    pageControl.currentPage = index
    let data = arrays[index]
    titleLabel.text = data.title
    descriptionLabel.text = data.description
  }
}
