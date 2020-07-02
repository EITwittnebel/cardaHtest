//
//  MainController.swift
//  imgurAPIer
//
//  Created by John Wittnebel on 7/1/20.
//  Copyright © 2020 John Wittnebel. All rights reserved.
//

import UIKit
import Alamofire

class MainController: UIViewController {

  @IBOutlet weak var imageCollection: UICollectionView!
  var myData: [ImgurData] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    imageCollection.dataSource = self
    imageCollection.delegate = self
    refresh()
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard let senderCell = sender as? UICollectionViewCell,
      let cellPath = imageCollection.indexPath(for: senderCell),
      let dest = segue.destination as? DetailViewController else { return }
    dest.dataToDisplay = myData[cellPath.section]
  }
  
  @IBAction func refreshButton(_ sender: Any) {
    refresh()
  }
  
  func refresh() {
    AFManager.shared.basicInfoPull { result in
      switch result {
      case .success(let basicData):
        self.myData = basicData
      case .failure(let error):
        self.presentErrorAlert(error: error)
      }
      self.imageCollection.reloadData()
    }
  }
  
}

extension MainController: UICollectionViewDelegate, UICollectionViewDataSource {
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! CollViewCell
    
    //Get Image Data
    if (myData[indexPath.section].image == nil) {
      AFManager.shared.getImage(imageURL: myData[indexPath.section].imageURL) { result in
        switch result {
        case .success(let image):
          self.myData[indexPath.section].image = image
          self.imageCollection.reloadSections([indexPath.section])
        case .failure(let error):
          self.presentErrorAlert(error: error)
        }
      }
    }
    
    //Set Image in UI
    let currImage = myData[indexPath.section].image ?? UIImage(named: "placeholder.png")
    cell.collViewImage.image = currImage
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 1
  }
  
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return myData.count
  }
}
