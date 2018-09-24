//
//  RestInterface.swift
//  Story
//
//  Created by Niraj Jha on 23/09/2018.
//  Copyright © 2018 home. All rights reserved.
//

import UIKit

class RestInterface: NSObject {
    class func getItemList(urlString:String, completionHandler: @escaping (Bool, Any?) ->Void) {
        let header = Service.requestHeaders()
        let request = RestConnector.shared.createRequest(urlString, method: .GET, params: nil, headers: header, encoding:.urlEncode)
        RestConnector.shared.executeRequest(request) { (result, error) in
            if error != nil {
                completionHandler(false,error)
            }
            else {
                let data = ResponseHandler.parseItemListData(result!)
                completionHandler(true,data)
            }
        }
    }
    
    class func getCollectionList(urlString:String, completionHandler: @escaping (Bool, Any?) ->Void) {
        let header = Service.requestHeaders()
        let request = RestConnector.shared.createRequest(urlString, method: .GET, params: nil, headers: header, encoding:.urlEncode)
        RestConnector.shared.executeRequest(request) { (result, error) in
            if error != nil {
                completionHandler(false,error)
            }
            else {
                let data = ResponseHandler.parseCollectionListData(result!)
                completionHandler(true,data)
            }
        }
    }
}

