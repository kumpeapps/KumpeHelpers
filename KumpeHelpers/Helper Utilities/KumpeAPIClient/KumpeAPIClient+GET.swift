//
//  APIClient+GET.swift
//  KumpeHelpers
//
//  Created by Justin Kumpe on 10/11/20.
//
import Foundation
import Alamofire
import Alamofire_SwiftyJSON
import UIKit

extension KumpeAPIClient {
    // MARK: Task For Get
    @available(*, deprecated, message: "Completion Handler changed to (response,error,httpStatusResponse)")
    open class func taskForGet<ResponseType: Decodable>(apiUrl: String, httpMethod: HTTPMethod = .get, responseType: ResponseType.Type, parameters: [String:String], invalidApiKeyStatusCode: Int = 401, debug: Bool = false, headers: HTTPHeaders = [:], successCode: Int = 200, completion: @escaping (_ response: ResponseType?, _ error: String?) -> Void) {
        taskForGet(apiUrl: apiUrl, httpMethod: httpMethod, responseType: responseType, parameters: parameters, invalidApiKeyStatusCode: invalidApiKeyStatusCode, debug: debug, headers: headers, successCode: successCode) { response, error, _ in
            completion(response,error)
        }
    }
    open class func taskForGet<ResponseType: Decodable>(apiUrl: String, httpMethod: HTTPMethod = .get, responseType: ResponseType.Type, parameters: [String:String], invalidApiKeyStatusCode: Int = 401, debug: Bool = false, headers: HTTPHeaders = [:], successCode: Int = 200, completion: @escaping (_ response: ResponseType?, _ error: String?, _ httpStatusResponse: HTTP_Status_Response) -> Void) {
            let url = URL(string: apiUrl)!
        Alamofire.request(url, method: httpMethod, parameters: parameters, encoding: URLEncoding.default, headers: headers) .responseSwiftyJSON { dataResponse in

                if debug {
                    Logger.log(.codeWarning, dataResponse)
                }

            guard let statusCode = dataResponse.response?.statusCode else { return }
            let statusCodeResponse: HTTP_Status_Response = .init(statusCode)
//              GUARD: API Key Valid (returns 412 when not valid)
                guard statusCode != invalidApiKeyStatusCode else {
                    completion(nil,"API Key Invalid", statusCodeResponse)
                    apiLogout()
                    return
                }

//              GUARD: isSuccess
                guard case dataResponse.result.isSuccess = true else {
                    completion(nil,dataResponse.error?.localizedDescription, statusCodeResponse)
                    return
                }

//              GUARD: Status code 2xx
                guard statusCode >= 200 && statusCode <= 299 else {
                    completion(nil,"\(statusCode)", statusCodeResponse)
                    Logger.log(.error, "Your request returned a status code other than 2xx! (\(String(describing: dataResponse.response?.statusCode)))")
                    return
                }

//              GUARD: Status Code 200
                guard statusCode == successCode || successCode == 0 else {
                    completion(nil,"Your request returned a status code other than 200!", statusCodeResponse)
                    Logger.log(.error, "No Data Found")
                    return
                }

//              GUARD: Response
                guard let data = dataResponse.data else {
                    completion(nil,dataResponse.error?.localizedDescription, statusCodeResponse)
                    Logger.log(.error, "No Data Found.")
                    return
                }

                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(responseType.self, from: data)
                    completion(response,nil, statusCodeResponse)
                } catch let error {
                    Logger.log(.error, "Task For Get: \(error.localizedDescription)")
                    completion(nil,error.localizedDescription, statusCodeResponse)
                }

            }
    }
}
