//
//  KumpeAPIClient+PUT.swift
//  KumpeHelpers
//
//  Created by Justin Kumpe on 10/11/20.
//

import Foundation
import UIKit
import Alamofire
import Alamofire_SwiftyJSON

extension KumpeAPIClient {

// MARK: apiPut
    open class func apiPut(silent: Bool = false, apiUrl: String, parameters: [String:Any], blockInterface: Bool = false, invalidApiKeyStatusCode: Int = 401, headers: HTTPHeaders = [:], completion: @escaping (_ success: Bool, _ error: String?, _ httpStatusResponse: HTTP_Status_Response) -> Void) {
        apiMethod(silent: silent, apiUrl: apiUrl, httpMethod: .put, parameters: parameters, blockInterface: blockInterface, invalidApiKeyStatusCode: invalidApiKeyStatusCode, headers: headers) { (success, error, httpStatusResponse) in
            completion(success,error,httpStatusResponse)
        }
    }

}
