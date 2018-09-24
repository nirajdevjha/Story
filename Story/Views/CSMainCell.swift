//
//  CSMainCell.swift
//  Story
//
//  Created by Niraj Jha on 23/09/2018.
//  Copyright © 2018 home. All rights reserved.

import UIKit

struct StoryViewModel {
    let name: String
    let type: String
    let imageUrl:String
    let summary:String
    let accessoryType:UITableViewCellAccessoryType
    
    //Dependency Injection (DI)
    init(model:Story) {
        self.name = model.headline
        self.imageUrl = model.imageUrl
        self.summary = model.summary
        
        if model.type.lowercased() != "story" {
            self.type = "Collection: \(model.type)"
        }
        else {
            self.type = model.type.capitalized
        }
        accessoryType = .detailDisclosureButton
    }
}

class CSMainCell: UITableViewCell {
    var storyViewModel:StoryViewModel! {
        didSet {
            textLabel?.text = storyViewModel.name
            detailTextLabel?.text = storyViewModel.type
            accessoryType = storyViewModel.accessoryType
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
