//
//  RestConnector.swift
//  Story
//
//  Created by Niraj Jha on 23/09/2018.
//  Copyright © 2018 home. All rights reserved.
//

import UIKit

class RestConnector: NSObject {
    static let shared: RestConnector = {
        return RestConnector()
    }()
    
    lazy var urlSession: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 60
        configuration.urlCache = nil
        configuration.httpCookieStorage = nil
        configuration.requestCachePolicy = .useProtocolCachePolicy
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue:OperationQueue.main)
        return session
    }()
}

//MARK:- Create Request
extension RestConnector {
    func createRequest(_ urlString:String, method: RequstMethod = .GET,
                       params:[String: Any]? = nil, headers:[String: String]? = nil,
                       encoding:RequestEncoding = .jsonEncode) -> URLRequest {
        
        let stringUrl                       = Service.getServiceURL(key: urlString)
        let url                             = URL(string: stringUrl)
        let requestHeader:[String:String]   = headers!
        
        var requestBody:[String:Any]        = [:]
        if params != nil {
            requestBody = params!
        }
        
        var request                         = NSMutableURLRequest(url: url!)
        
        switch encoding {
        case .jsonEncode:
            do{
                let data = try JSONSerialization.data(withJSONObject: requestBody, options: [])
                let dataLenght = (data as NSData).length
                request.setValue("\(dataLenght)", forHTTPHeaderField: "Content-Length")
                request.httpBody = data
            } catch let error as NSError{
                print(error)
            }
        case .urlEncode:
            if requestBody.count > 0 {
                let encodeURL = NSMutableString(string: (url?.absoluteString)! + "?")
                var first = true
                for (key, value) in requestBody {
                    if first {
                        encodeURL.append("\(key)=\(value)")
                    }else{
                        encodeURL.append("&\(key)=\(value)")
                    }
                    first = false
                }
                
                request = NSMutableURLRequest(url: (URL(string: (encodeURL as NSMutableString) as String))!)
            }
        case .wwwEncode:
            if let parameter = requestBody as? [String:String] {
                var arr: [String] = []
                for (key, val) in parameter {
                    arr.append("\(key)=\(val.wwwFormURLEncoded)")
                }
                let body = arr.joined(separator: "&")
                request.httpBody = body.data(using: .utf8)
            }
        case .imageEncode:
            if requestBody.count > 0 {
                let encodeURL =  NSMutableString(string: (url?.absoluteString)! + "/")
                for (_, value) in requestBody {
                    encodeURL.append("\(value)")
                }
                request = NSMutableURLRequest(url: (URL(string: (encodeURL as NSMutableString) as String))!)
            }
        }
        
        for (key, value) in requestHeader {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        print("Request Header:\(requestHeader)")
        print("Request Boady:\(requestBody)")
        request.httpMethod = method.rawValue
        return request as URLRequest
    }
}

//MARK:- Execute Request
extension RestConnector {
    func executeRequest(_ request: URLRequest, callback: @escaping (Any?, NSError?) -> Void) {
        let task = self.urlSession.dataTask(with: request, completionHandler: {(data, response, error) -> Void in
            if let requestResponse = response {
                var responseString: String?
                let urlResponse = requestResponse as! HTTPURLResponse
                let status = urlResponse.statusCode
                
                let json: Any?
                if let responseData = data {
                    json = self.jsonFromData(data: responseData)
                    if json == nil{
                        responseString = String(data: responseData, encoding: .utf8)
                    }
                }
                else {
                    json = nil
                }
                
                debugPrint("Request:", request.url!.absoluteString)
                debugPrint("Status:\(status)")
                debugPrint("ResponseBody:", json ?? "", responseString ?? "")
                
                if status != 200 {
                    var errorString:String = "Error Status Code: \(status)."
                    if let json = json as? NSDictionary, let detail = json["detail"] as? String {
                        errorString += " \(detail)"
                    }
                    let sucessError = NSError(domain: "", code: status, userInfo: [NSLocalizedDescriptionKey : errorString])
                    debugPrint("Sucess Error:\(sucessError)")
                    callback(nil, sucessError)
                }
                else {
                    callback(json, nil)
                }
            }
            else {
                let errorString:String = "Error Status Code: 500."
                let sucessError = NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey : errorString])
                debugPrint("Sucess Error:\(sucessError)")
                callback(nil, sucessError)
            }
        })
        task.resume()
    }
}

//MARK:- JSON Handlers
extension RestConnector {
    private func jsonFromData(data: Data) -> Any?{
        do {
            let object = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions(rawValue: JSONSerialization.ReadingOptions.RawValue(0)))
            return object
        } catch _ {
            return nil
        }
    }
}

//MARK:- Session Delegate
extension RestConnector:URLSessionDelegate {
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        //TO::DO Error Operation
    }
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        //TO::DO Perform Backgroud Operation
    }
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if let trust = challenge.protectionSpace.serverTrust{
            let credentials = URLCredential(trust: trust)
            completionHandler(.useCredential, credentials)
        }else{
            completionHandler(.performDefaultHandling, nil)
        }
    }
}
