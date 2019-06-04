//
//  FlickerAPI.swift
//  Virtual Tourist
//
//  Created by Bahi El Feky on 5/12/19.
//  Copyright © 2019 Bahi El Feky. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
class FlickerAPI {
    
    
    static func getListOfPhotosIn(lat: Double, lon: Double, completionHandler: @escaping (String, [String]?) -> Void) {
        let url = "\(Constants.BASE_URL)?api_key=\(Constants.API_KEY)&method=\(Constants.FLICKR_SEARCH_METHOD)&per_page=\(Constants.NUM_OF_PHOTOS)&format=json&nojsoncallback=?&lat=\(lat)&lon=\(lon)&page=\((1...10).randomElement() ?? 1)"
        
        if !Connectivity.isConnectedToInternet {
            completionHandler("Internet Not Connected", nil)
        }
        
        Alamofire.request(url).responseJSON { (response) in
            
            if((response.result.value) != nil) {
                let swiftyJsonVar = JSON(response.result.value!)
                var photosURL: [String] = []
                
                if let photos = swiftyJsonVar["photos"]["photo"].array {
                    for photo in photos {
                        let photoURL = "https://farm\(photo["farm"].stringValue).staticflickr.com/\(photo["server"].stringValue)/\(photo["id"])_\(photo["secret"]).jpg"
                        photosURL.append(photoURL)
                    }
                }
                
                completionHandler(displayError("Connected"), photosURL)
            } else {
                completionHandler(displayError("Error Occured"), nil)
            }
        }
        
    }
    
    static func displayError(_ error: String) -> String {
        print(error)
        return error
    }
}

class Connectivity {
    static var isConnectedToInternet: Bool {
        return NetworkReachabilityManager()!.isReachable
    }
    
    enum Status {
        case notConnected, connected, other
    }
}

