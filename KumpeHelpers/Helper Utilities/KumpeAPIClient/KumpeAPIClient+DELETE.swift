//
//  KumpeAPIClient+DELETE.swift
//  KumpeHelpers
//
//  Created by Justin Kumpe on 10/11/20.
//

import Foundation
import UIKit
import Alamofire
import Alamofire_SwiftyJSON

extension KumpeAPIClient {

// MARK: apiDelete
    @available(*, deprecated, message: "Completion Handler changed to (success,error,httpStatusResponse)")
    open class func apiDelete(silent: Bool = false, apiUrl: String, parameters: [String:Any], blockInterface: Bool = false, invalidApiKeyStatusCode: Int = 401, headers: HTTPHeaders = [:], completion: @escaping (_ success: Bool, _ error: String?) -> Void) {
        apiDelete(silent: silent, apiUrl: apiUrl, parameters: parameters, blockInterface: blockInterface, invalidApiKeyStatusCode: invalidApiKeyStatusCode, headers: headers) { success, error, _ in
            completion(success,error)
        }
    }
    open class func apiDelete(silent: Bool = false, apiUrl: String, parameters: [String:Any], blockInterface: Bool = false, invalidApiKeyStatusCode: Int = 401, headers: HTTPHeaders = [:], completion: @escaping (_ success: Bool, _ error: String?, _ httpStatusResponse: HTTP_Status_Response) -> Void) {
        apiMethod(silent: silent, apiUrl: apiUrl, httpMethod: .delete, parameters: parameters, blockInterface: blockInterface, invalidApiKeyStatusCode: invalidApiKeyStatusCode, headers: headers) { (success, error, httpStatusResponse) in
            completion(success,error,httpStatusResponse)
        }
    }

}
