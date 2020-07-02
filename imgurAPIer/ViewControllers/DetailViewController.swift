//
//  DetailViewController.swift
//  imgurAPIer
//
//  Created by John Wittnebel on 7/1/20.
//  Copyright © 2020 John Wittnebel. All rights reserved.
//

import Foundation
import UIKit

class DetailViewController: UIViewController {
  
  @IBOutlet weak var imageToDisplay: UIImageView!
  @IBOutlet weak var titleToDisplay: UILabel!
  @IBOutlet weak var viewsToDisplay: UILabel!
  @IBOutlet weak var scoreToDisplay: UILabel!
  @IBOutlet weak var urlLink: UILabel!
  
  var dataToDisplay: ImgurData?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    imageToDisplay.image = dataToDisplay?.image
    titleToDisplay.text = "Title: \(dataToDisplay?.title ?? "N/A")"
    viewsToDisplay.text = "Number of Views: \(dataToDisplay?.views ?? "N/A")"
    scoreToDisplay.text = "Score: \(dataToDisplay?.score ?? "N/A")"
    urlLink.text = dataToDisplay!.imageURL
    
    let tap = UITapGestureRecognizer(target: self, action: #selector(self.onClickLabel(sender:)))
    urlLink.isUserInteractionEnabled = true
    urlLink.addGestureRecognizer(tap)
  }
  
  @objc func onClickLabel(sender: UITapGestureRecognizer) {
    openUrl(urlString: dataToDisplay!.imageURL)
  }
  
  func openUrl(urlString: String!) {
    let url = URL(string: urlString)!
    UIApplication.shared.open(url)
  }
}
 
