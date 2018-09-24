//
//  ResponseHandler.swift
//  Story
//
//  Created by Niraj Jha on 23/09/2018.
//  Copyright © 2018 home. All rights reserved.
//

import Foundation

class ResponseHandler {
    static func parseItemListData(_ response:Any) -> ItemList {
        var model = ItemList(name: "", summary: "", items: [])
        if let data = response as? [String:Any] {
            model.name = JSON.toString(data["name"])
            model.summary = JSON.toString(data["summary"])
            if let itemArray = data["items"] as? [[String:Any]] {
                for item in itemArray {
                    let id = JSON.toString(item["id"])
                    let type = JSON.toString(item["type"])
                    if type == "collection" {
                        let name = JSON.toString(item["name"])
                        let url = JSON.toString(item["url"])
                        let slug = JSON.toString(item["slug"])
                        let cModel = Collection(id: id, type: type, name: name, url: url, slug: slug)
                        model.items.append(cModel)
                    }
                    else {
                        if let story = item["story"] as? [String:Any] {
                            let author = JSON.toString(story["author-name"])
                            let headline = JSON.toString(story["headline"])
                            let slug = JSON.toString(story["slug"])
                            let summary = JSON.toString(story["summary"])
                            let imageUrl = JSON.toString(story["hero-image"])
                            
                            let sModel = Story(id: id, type: type, authorName: author,
                                               headline: headline, slug: slug, imageUrl: imageUrl, summary: summary)
                            model.items.append(sModel)
                        }
                    }
                }
            }
        }
        return model
    }
    
    static func parseCollectionListData(_ response:Any) -> ItemList {
        var model = ItemList(name: "", summary: "", items: [])
        if let data = response as? [String:Any] {
            model.name = JSON.toString(data["name"])
            model.summary = JSON.toString(data["summary"])
            if let itemArray = data["items"] as? [[String:Any]] {
                for item in itemArray {
                    let id = JSON.toString(item["id"])
                    let type = JSON.toString(item["type"])
                    
                    if let story = item["story"] as? [String:Any] {
                        let author = JSON.toString(story["author-name"])
                        let headline = JSON.toString(story["headline"])
                        let summary = JSON.toString(story["summary"])
                        let imageUrl = JSON.toString(story["hero-image"])
                        
                        let sModel = Story(id: id, type: type, authorName: author,
                                           headline: headline, slug: "", imageUrl: imageUrl, summary: summary)
                        model.items.append(sModel)
                    }
                }
            }
        }
        return model
    }
}
