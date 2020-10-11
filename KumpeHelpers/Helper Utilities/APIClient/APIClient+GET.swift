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

public extension APIClient{
    //    MARK: Task For Get
    class func taskForGet<ResponseType: Decodable>(module: String, responseType: ResponseType.Type, parameters: [String:String], completion: @escaping (ResponseType?, String?) -> Void){
            let url = URL(string: "")!
            Alamofire.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default) .responseSwiftyJSON { dataResponse in
                        
                
//              GUARD: API Key Valid (returns 412 when not valid)
                guard let statusCode = dataResponse.response?.statusCode, statusCode != 412 else{
                    completion(nil,"API Key Invalid")
                    NotificationCenter.default.post(name: .invalidAPIKey, object: nil)
                    return
                }
                
//              GUARD: isSuccess
                guard case dataResponse.result.isSuccess = true else {
                    completion(nil,dataResponse.error?.localizedDescription)
                    return
                }
                

                
//              GUARD: Status code 2xx
                guard statusCode >= 200 && statusCode <= 299 else{
                    Logger.log(.error, "Your request returned a status code other than 2xx! (\(String(describing: dataResponse.response?.statusCode)))")
                    return
                }
                            
//              GUARD: Status Code 200
                guard statusCode == 200 else{
                    Logger.log(.error, "No Data Found")
                    return
                }
                        
//              GUARD: Response
                guard let data = dataResponse.data else{
                    completion(nil,dataResponse.error?.localizedDescription)
                    Logger.log(.error, "No Data Found.")
                    return
                }
                        
                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(responseType.self, from: data)
                    completion(response,nil)
                } catch let error {
                    Logger.log(.error, "Task For Get: \(error.localizedDescription)")
                    completion(nil,error.localizedDescription)
                }
                        
                        
            }
    }
}