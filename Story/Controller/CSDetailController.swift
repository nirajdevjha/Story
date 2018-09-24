//
//  CSDetailController.swift
//  Story
//
//  Created by Niraj Jha on 24/09/2018.
//  Copyright © 2018 home. All rights reserved.
//

import UIKit

class CSDetailController: UIViewController {
    var storyViewModel:StoryViewModel?
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var storyImageView: UIImageView!
    @IBOutlet weak var summaryLabel: UILabel!
   
    //MARK: Self Method
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initHUD()
        callStoryImageService()                 //Updating Image for imageUrl 
    }
    
    //MARK:- Private Methods
    private func initHUD() {
        titleLabel.text = storyViewModel?.name
        summaryLabel.text = storyViewModel?.summary
        self.title = storyViewModel?.type.capitalized
    }
}

//MARK:- Service API
extension CSDetailController {
    func callStoryImageService() {
        CSLoadingView.show()
        do {
            let data = try Data(contentsOf:URL(string: (storyViewModel?.imageUrl)!)!, options: Data.ReadingOptions.alwaysMapped)
            if let pic = UIImage(data: data) {
                self.storyImageView.image = pic
            }
            CSLoadingView.hide()
        }
        catch {
            //TO:DO Error
        }
    }
}
