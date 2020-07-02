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
          DispatchQueue.main.async {
            let currImage = self.myData[indexPath.section].image ?? UIImage(named: "placeholder.png")
            cell.collViewImage.image = currImage
            }
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

extension MainController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let item = myData[indexPath.section]
        let width = collectionView.frame.size.width
        guard item.width > 0 && item.height > 0 else {
            return CGSize(width: width, height: width)
        }
        let imageRatio = Double(item.height) / Double(item.width)
        let height = width * CGFloat(imageRatio)
        return CGSize(width: width, height: height)
    }
}
