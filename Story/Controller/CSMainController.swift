//
//  CSMainController.swift
//  Story
//
//  Created by Niraj Jha on 23/09/2018.
//  Copyright © 2018 home. All rights reserved.
//

import UIKit
import CoreData

class CSMainController: UIViewController {
    var itemArray:[Any]?                            //For handling Home item List
    var storyArray:[StoryViewModel]?                //Array for showing MVVM Pattern
    var selectedStoryViewModel:StoryViewModel?
    
    let myGroup = DispatchGroup()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let updateManager = UpdateDatabaseManager.shared

    @IBOutlet weak var listTableView:UITableView!
   
    //MARK: Self Method
    override func viewDidLoad() {
        super.viewDidLoad()
        initHUD()
    }
    
    //MARK:- Private Methods
    private func initHUD() {
        listTableView.tableFooterView = UIView(frame: .zero)

        listTableView.delegate = self
        listTableView.dataSource = self
        
        //Navigation Title
         self.title = "Home"
        
        //Fetch Data from Database if Exist, else call API
        getDataFromCoreData()
    }
    
    //MARK:- Navigation Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "mainToDetail" {
            let controller = segue.destination as! CSDetailController
            controller.storyViewModel = selectedStoryViewModel!
        }
    }
}

//MARK:- TableViewDelegate, TableViewDatasource
extension CSMainController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if storyArray != nil {
            return (storyArray?.count)!
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "storyCell", for: indexPath) as! CSMainCell
        let storyViewModel = storyArray![indexPath.row]
        cell.storyViewModel = storyViewModel            
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyViewModel = storyArray![indexPath.row]
        selectedStoryViewModel = storyViewModel                         //Storing selected Story
        performSegue(withIdentifier: "mainToDetail", sender: nil)
    }
}


//MARK:- Data Handlers
extension CSMainController {
    //Map Each Collection Story to Single Array With Maintaing Order
    func updateStoryWithResponseData() {
        var array:[Story] = []
        for item in itemArray! {
            if let collectionItem =  item as? ItemList, let storyArray = collectionItem.items as? [Story] {
                let sArray = storyArray.map { (story) -> Story in
                    var sItem = story
                    sItem.type = collectionItem.name
                    return sItem
                }
                array = array + sArray
            }
            else {
                let storyItem = item as! Story
                array.append(storyItem)
            }
        }
        
        //Store in Database
        updateStoryToCoreData(dataArray: array)

        //Creating ViewModel for handling MVVM on TableViewCell
        storyArray = array.map({ (model) -> StoryViewModel in
            return StoryViewModel(model: model)
        })
        
        CSLoadingView.hide()
        
        //Reload TableView once data is updated
        listTableView.reloadData()
    }
    
    //After Mapping Update to CoreData
    func updateStoryToCoreData(dataArray:[Story]) {
        //Core Database Context
        let context = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "StoryItem", in: context)
        
        for index in 0..<dataArray.count {
            let item = dataArray[index]
            let newStory = NSManagedObject(entity: entity!, insertInto: context)
            newStory.setValue(index + 1, forKey: "index")
            newStory.setValue(item.id, forKey: "id")
            newStory.setValue(item.type, forKey: "type")
            newStory.setValue(item.authorName, forKey: "authorName")
            newStory.setValue(item.slug, forKey: "slug")
            newStory.setValue(item.headline, forKey: "headline")
            newStory.setValue(item.imageUrl, forKey: "imageUrl")
            newStory.setValue(item.summary, forKey: "summary")
        }
        
        do {
            try context.save()
        } catch {
            print("Failed saving")
        }
    }
    
    //Delete the Data from Database
    func deleteFromCoreData() {
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "StoryItem")
        let deleteBatchRequest = NSBatchDeleteRequest(fetchRequest: request)

        do {
            try context.execute(deleteBatchRequest)
            try context.save()
        } catch {
            print ("There was an error")
        }
    }
    
    //Fetch from CoreData, if Exist else Call API
    func getDataFromCoreData() {
        CSLoadingView.show()
        
        //Core Database Context
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "StoryItem")
        //Fecth based on order stored in database
        let sort = NSSortDescriptor(key: #keyPath(StoryItem.index), ascending: true) //Fetching with Stored Order
        request.sortDescriptors = [sort]
        
        do {
            //Get list of ManagedObjects
            let result = try context.fetch(request)
            var array:[Story] = []
            //Checking is data is previous data data or not
            if !result.isEmpty && !updateManager.checkIfLoadRequired(){
                for data in result as! [NSManagedObject] {
                    let id = data.value(forKey: "id") as! String
                    let type = data.value(forKey: "type") as! String
                    let authorName = data.value(forKey: "authorName") as! String
                    let headline = data.value(forKey: "headline") as! String
                    let summary = data.value(forKey: "summary") as! String
                    let imageUrl = data.value(forKey: "imageUrl") as! String
                    let slug = data.value(forKey: "slug") as! String
                    
                    let storyModel = Story(id: id, type: type, authorName: authorName,
                                           headline: headline, slug: slug, imageUrl: imageUrl, summary: summary)
                    array.append(storyModel)
                }
                
                storyArray = array.map({ (model) -> StoryViewModel in
                    return StoryViewModel(model: model)
                })
                
                CSLoadingView.hide()
                listTableView.reloadData()
            }
            else {
                //Delete old data from database
                deleteFromCoreData()
                callItemListService()           //Calling from API if Data not exist in CoreData
            }
        } catch {
            //TO::DO Error
        }
    }
}

//MARK:- Service API
extension CSMainController {
    func callItemListService() {
        RestInterface.getItemList(urlString: "collection") { (success, response) in
            if success {
                if let data = response as? ItemList {
                    if !data.items.isEmpty {
                        self.itemArray = data.items
                        for index in 0..<data.items.count {
                            if let item = data.items[index] as? Collection {
                                self.myGroup.enter() //Entering Run Wait Async for only CollectionType
                                self.callCollectionService(model: item, completionHandler: { (itemResponse) in
                                    if itemResponse != nil {
                                        self.itemArray![index] = itemResponse!
                                    }
                                    else {
                                        self.itemArray![index] = ItemList(name: "", summary: "", items: [])
                                    }
                                    self.myGroup.leave()
                                })
                            }
                        }
                        //Updating UI once Dispatch Group Completes
                        self.myGroup.notify(queue: DispatchQueue.main, execute: {
                            self.updateStoryWithResponseData()
                        })
                    }
                }
            }
            else {
                //TO::DO Error
                CSLoadingView.hide()
            }
        }
    }
    
    func callCollectionService(model:Collection, completionHandler: @escaping (ItemList?) ->Void) {
        let urlPath = URL(string: model.url)?.lastPathComponent
        RestInterface.getCollectionList(urlString: urlPath!) { (success, response) in
            if success {
                if let data = response as? ItemList {
                    completionHandler(data)
                }
                else {
                    completionHandler(nil)
                }
            }
            else {
                completionHandler(nil)
            }
        }
    }    
 }
