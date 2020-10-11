//
//  APIClient.swift
//  KumpeHelpers
//
//  Created by Justin Kumpe on 10/11/20.
//

import Foundation
import Alamofire
import Alamofire_SwiftyJSON
import UIKit

public class APIClient{
    open func apiLogout(){
        NotificationCenter.default.post(name: .invalidAPIKey, object: nil)
    }
}
