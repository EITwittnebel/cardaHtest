//
//  AFManager.swift
//  imgurAPIer
//
//  Created by John Wittnebel on 7/1/20.
//  Copyright © 2020 John Wittnebel. All rights reserved.
//

import Alamofire
import SwiftyJSON

enum ImgurErrors: Error {
  case badURL
  case badCredentials
  case dataLimitReached
  case badData
  case noConnection
  case other(Error)
}

enum URLStrings {
  static let currViralBaseURL = "https://api.imgur.com/3/gallery/hot/viral/day/2"
}

final class AFManager {
  
  static var shared = AFManager()
  private var basicHeaders: HTTPHeaders {
    return ["Authorization" : "Client-ID 8378276d7b6df43"]
  }
  
  private init() { }
  
  private func request(_ url: URLConvertible,
                       _ responseHandler: @escaping (AFDataResponse<Any>) -> Void,
                       _ errorCompletion: @escaping (ImgurErrors) -> Void) {
    AF.request(url, headers: basicHeaders).responseJSON { response in
      if let error = response.error {
        if (error.localizedDescription == "URLSessionTask failed with error: The Internet connection appears to be offline.") {
          errorCompletion(.noConnection)
        } else {
          errorCompletion(.other(error))
        }
        return
      }
      responseHandler(response)
    }
  }
  
  func basicInfoPull(completion: @escaping (_ result: Result<[ImgurData], ImgurErrors>) -> ()) {
    let urlString: String = URLStrings.currViralBaseURL
    
    request(urlString, { response in
      let json: JSON = JSON(response.data as Any)
      
      let imageArr: [JSON] = json["data"].arrayValue
      var returnArr: [ImgurData] = []
      returnArr = imageArr.compactMap({ currImage in
        let imgurTitle: String = currImage["title"].stringValue
        let type: String = currImage["images"][0]["type"].stringValue
        let imgurURL: String = currImage["images"][0]["link"].stringValue
        if (type == "video/mp4") || (imgurURL == "") { return nil }
        let imgurID: String = currImage["id"].stringValue
        let imgurDescription: String = currImage["description"].stringValue
        let imgurDate: String = currImage["datetime"].stringValue
        let imgurWidth: Int = currImage["width"].intValue
        let imgurHeight: Int = currImage["height"].intValue
        let imgurView: String = currImage["views"].stringValue
        let imgurScore: String = currImage["score"].stringValue
        let currData: ImgurData = ImgurData(imageURL: imgurURL, id: imgurID, title: imgurTitle, des: imgurDescription, date: imgurDate, width: imgurWidth, height: imgurHeight, views: imgurView, score: imgurScore)
        return currData
      })
      completion(.success(returnArr))
    }) { error in
      completion(.failure(error))
    }
  }
  
  func getImage(imageURL: String, key: String? = nil, completion: @escaping (_ result: Result<UIImage, ImgurErrors>) -> ()) {
    AF.request(imageURL).responseData { response in
      if let error = response.error {
        if (error.localizedDescription == "The Internet connection appears to be offline.") {
          completion(.failure(.noConnection))
        } else {
          completion(.failure(.other(error)))
        }
        return
      }
      guard let imageData = response.data,
        let image = UIImage(data: imageData) else {
          completion(.failure(.badData))
          return
      }
      completion(.success(image))
    }

  }
  
}

