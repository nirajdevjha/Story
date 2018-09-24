//
//  ServiceConstant.swift
//  Story
//
//  Created by Niraj Jha on 23/09/2018.
//  Copyright © 2018 home. All rights reserved.
//

import Foundation

let CONTENT_TYPE                = "Content-Type"
let CONTENT_TYPE_JSON           = "application/json"
let CONTENT_TYPE_TEXT           = "application/text"
let BASE_API_URL                = "https://demo9639618.mockable.io/"

// API Service Constant
enum RequestEncoding {
    case jsonEncode
    case wwwEncode
    case urlEncode
    case imageEncode
}

enum RequstMethod: String {
    case POST   = "POST"
    case GET    = "GET"
    case PUT    = "PUT"
}

extension String {
    var wwwFormURLEncoded: String {
        var characterSet = CharacterSet().union(CharacterSet.alphanumerics)
        characterSet.insert(charactersIn: "-._* ")
        return (addingPercentEncoding(withAllowedCharacters: characterSet) ?? "").replacingOccurrences(of: " ", with: "+")
    }
}

class Service {
    //Fetching the Service API URL from plist
    class func getServiceURL(key:String) -> String {
        if key.contains("http") {
            return key
        }
        return BASE_API_URL + key
    }
    
    //Fetching the Request Header
    class func requestHeaders() -> [String:String] {
        var header:[String:String] = [:]
        header[CONTENT_TYPE] = CONTENT_TYPE_JSON
        return header
    }
}

class JSON {
    class func toString(_ value: Any?) -> String {
        if let stringValue = value as? String, stringValue != "<null>", stringValue != "NA"  { return stringValue }
        else if value is NSNull { return "" as String }
        return ""
    }
    
    class func toInt(_ data: Any?) -> Int {
        if let value = data, value is NSNumber, let numberValue = value as? NSNumber  { return numberValue.intValue }
        else if data is NSNull { return 0 }
        return 0
    }
    
    class func toBool(_ data: Any?) -> Bool {
        if let value = data, value is NSNumber, let numberValue = value as? NSNumber  { return numberValue.boolValue }
        else if data is NSNull { return false }
        return false
    }
    
    class func toDouble(_ data: Any?) -> Double {
        if let value = data, value is NSNumber, let numberValue = value as? NSNumber  { return numberValue.doubleValue }
        else if data is NSNull { return 0.0 }
        return 0.0
    }
    
    class func toFloat(_ data: Any?) -> Float {
        if let value = data, value is NSNumber, let numberValue = value as? NSNumber  { return numberValue.floatValue }
        else if data is NSNull { return 0.0 }
        return 0.0
    }
    
    class func toArray(_ data: Any?) -> [Any] {
        if let value = data, value is Array<Any>, let valueArray = value as? Array<Any>  { return valueArray }
        else if data is NSNull { return [] }
        return []
    }
}
