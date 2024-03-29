//
//  KumpeAPIClient+Sync.swift
//  KumpeHelpers
//
//  Created by Justin Kumpe on 10/11/20.
//

import Foundation

import Alamofire
import Alamofire_SwiftyJSON
import Sync
import CoreData

extension KumpeAPIClient {

    // MARK: apiSync
    //    Get function to sync data from API to CoreData
    @available(*, deprecated, message: "Completion Handler changed to (success,error,httpStatusResponse)")
    open class func apiSync(silent: Bool = false, apiUrl: String, parameters: [String:Any], jsonArrayName: String, coreDataEntityName: String, invalidApiKeyStatusCode: Int = 401, headers: HTTPHeaders = [:], completion: @escaping (_ success: Bool, _ error: String?) -> Void) {
        apiSync(silent: silent, apiUrl: apiUrl, parameters: parameters, jsonArrayName: jsonArrayName, coreDataEntityName: coreDataEntityName, invalidApiKeyStatusCode: invalidApiKeyStatusCode, headers: headers) { success, error, _ in
            completion(success,error)
        }
    }
    open class func apiSync(silent: Bool = false, apiUrl: String, parameters: [String:Any], jsonArrayName: String, coreDataEntityName: String, invalidApiKeyStatusCode: Int = 401, headers: HTTPHeaders = [:], completion: @escaping (_ success: Bool, _ error: String?, _ httpStatusResponse: HTTP_Status_Response) -> Void) {

            if !silent {
                ShowAlert.statusLineStatic(id: "sync_\(coreDataEntityName)", theme: .warning, title: "Syncing", message: "Syncing \(coreDataEntityName) Information....")
            }
            let url = URL(string: apiUrl)!

            let queue = DispatchQueue(label: "com.kumpeapps.api", qos: .background, attributes: .concurrent)
        Alamofire.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: headers).responseSwiftyJSON(queue: queue) { dataResponse in
            guard let statusCode = dataResponse.response?.statusCode else { return }
            let statusCodeResponse: HTTP_Status_Response = .init(statusCode)
                //            GUARD: API Key Valid (returns 401 when not valid)
                guard statusCode != invalidApiKeyStatusCode else {
                    Logger.log(.error, "API Key Not Valid")
                    ShowAlert.dismissStatic(id: "sync_\(coreDataEntityName)")
                    apiLogout()
                    return
                }
                if let jsonObject = dataResponse.value, let JSON = jsonObject[jsonArrayName].arrayObject as? [[String: Any]] {

                    DataController.shared.backgroundContext.sync(JSON, inEntityNamed: coreDataEntityName) { _ in
                        completion(true,nil,statusCodeResponse)
                        Logger.log(.action, "Sync \(coreDataEntityName) Complete")
                    }

                } else if let error = dataResponse.error {
                    completion(false,error.localizedDescription,statusCodeResponse)
                } else {
                    Logger.log(.error, dataResponse.value as Any)
                }
                try? DataController.shared.backgroundContext.save()
                ShowAlert.dismissStatic(id: "sync_\(coreDataEntityName)")
                UserDefaults.standard.set(Date(), forKey: "\(coreDataEntityName)LastUpdated")

            }

        }

}
