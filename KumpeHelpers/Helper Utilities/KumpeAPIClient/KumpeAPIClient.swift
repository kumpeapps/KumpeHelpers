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

open class KumpeAPIClient {

    // MARK: parameters
    public static let appBuildString: String? = (Bundle.main.infoDictionary!["CFBundleVersion"] as! String)
    public static let appBuild = Int((Bundle.main.infoDictionary!["CFBundleVersion"] as! String))
    public static var isKumpeAppsApi: Bool = false

// MARK: apiLogout
//    Initiates logout for invalid API Key
    open class func apiLogout() {
        NotificationCenter.default.post(name: .invalidAPIKey, object: nil)
    }

    open class func setIsKumpeAppsApi(_ isKumpeAppsApi: Bool = true) {
        self.isKumpeAppsApi = isKumpeAppsApi
    }

// MARK: statusCodeDescription
    open class func statusCodeDescription(_ statusCode: Int) -> String {
        var errorMessage = "Unknown Error Occurred"
        switch statusCode {
        case 401: errorMessage = "API Key Not Valid"
        case 409: errorMessage = "The username/email already exists or does not meet the requirements."
        case 410: errorMessage = "Delete unsuccessful. User/Chore may not exist."
        case 451: errorMessage = "App has been blocked for legal reasons. Please email support for more information!"
        default: errorMessage = "Unknown Error Occurred"
        }
        return errorMessage
    }

    // MARK: - apiMethod
    open class func apiMethod(silent: Bool = false, apiUrl: String, httpMethod: HTTPMethod, parameters: [String:Any], blockInterface: Bool = false, invalidApiKeyStatusCode: Int = 401, postToBody: Bool = false, headers:HTTPHeaders = [:], completion: @escaping (_ success: Bool, _ error: String?, _ httpStatusResponse: HTTP_Status_Response) -> Void) {
                let url = URL(string: apiUrl)!
                let alertId = "api_\(Int.random(in: 0..<10))"
                if !silent {
                    ShowAlert.statusLineStatic(id: alertId, theme: .warning, title: "Sending Data", message: "Sending Data, Please Wait ....", blockInterface: blockInterface)
                }
                let queue = DispatchQueue(label: "com.kumpeapps.api", qos: .background, attributes: .concurrent)
        var encoding: ParameterEncoding = URLEncoding(destination: .queryString)
        if postToBody {
            encoding = JSONEncoding.default
        }
        Alamofire.request(url, method: httpMethod, parameters: parameters, encoding: encoding, headers: headers).responseSwiftyJSON(queue: queue) { dataResponse in
            guard let statusCode = dataResponse.response?.statusCode else { return }
            let statusResponse: HTTP_Status_Response = .init(statusCode)
    //            GUARD: API Key Valid
                guard statusCode != invalidApiKeyStatusCode else {
                    Logger.log(.error, "API Key Not Valid")
                    ShowAlert.dismissStatic(id: alertId)
                    completion(false,"API Key Not Valid",statusResponse)
                    apiLogout()
                    return
                }

        //            GUARD: Status code 2xx
                guard statusCode >= 200 && statusCode <= 299 else {
                    Logger.log(.error, "Your request returned a status code other than 2xx! (\(statusResponse.statusCode): \(statusResponse.statusDescription)")
                        ShowAlert.dismissStatic(id: alertId)
                        let errorMessage = statusCodeDescription(statusCode)
                        completion(false,errorMessage,statusResponse)
                        return
                    }

    //            GUARD: isSuccess
                guard case dataResponse.result.isSuccess = true else {
                    completion(false,dataResponse.error?.localizedDescription,statusResponse)
                    ShowAlert.dismissStatic(id: alertId)
                    return
                }

                    ShowAlert.dismissStatic(id: alertId)
                    completion(true,nil,statusResponse)
                }
    }
}
