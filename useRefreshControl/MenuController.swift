//
//  MenuController.swift
//  useRefreshControl
//
//  Created by Peter on 2018/4/26.
//  Copyright © 2018年 Peter. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class MenuController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    var leftItem: UIBarButtonItem?
    var rightItem: UIBarButtonItem?
    var tableViewController: UITableViewController?
    var data: [JustString]?
    var context: NSManagedObjectContext?
    var delegate: AppDelegate?
    var num: Int?
    var imageNum: Int?
    override func viewDidLoad() {
        super.viewDidLoad()
        //set tableview
        let height = (self.navigationController?.navigationBar.frame.height)! + UIApplication.shared.statusBarFrame.height
        tableViewController = UITableViewController()
        tableViewController?.tableView.frame = CGRect.init(x: CGFloat(0), y: height, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - height)
        tableViewController?.tableView.dataSource = self
        tableViewController?.tableView.delegate = self
        tableViewController?.tableView.register(MenuCell.self, forCellReuseIdentifier: "MenuKey")
        self.view.addSubview((tableViewController?.tableView)!)
        
        //set navigation item
        leftItem = UIBarButtonItem.init(title: "Delete", style: .plain, target: self, action: #selector(self.deleteData))
        rightItem = UIBarButtonItem.init(title: "Add", style: .plain, target: self, action: #selector(self.addData))
        self.navigationItem.title = "Menu"
        self.navigationItem.setLeftBarButton(leftItem, animated: true)
        self.navigationItem.setRightBarButton(rightItem, animated: true)
        
        //set data in context
        delegate = UIApplication.shared.delegate as? AppDelegate
        context = delegate?.persistentContainer.viewContext
        checkDataNumberInContext() //makesure how many JustString data in context
        if num == 0 {
            data = []
            for _ in 0...5{
                data?.append(JustString(context: self.context!))
            }
            print((data?.count)!)
            for index in 0...5{
                if(index == 0){
                    data![index].content = "testRefreshControlApp" // the data connect to ViewController
                    data![index].order = Int64.init(exactly: index)!
                }else{
                    data![index].content = String.init(format: "Other App [%d]", index)
                    data![index].order = Int64.init(exactly: index)!
                }
            }
            delegate?.saveContext()
        }
        else{
            do{
                data = try context?.fetch(JustString.fetchRequest())
            }catch{
                print("error")
            }
            //the data fetched from context is unordered, so we must sorted
            data?.sort(by: {$0.order < $1.order})
        }
    }
    
    @objc func deleteData(){
        checkDataNumberInContext()
        if num! <= 0{
            let alert = UIAlertController.init(title: "Error", message: "You can't delete the last data", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction.init(title: "Ok", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }else{
            context?.delete(data![num! - 1])
            data!.remove(at: num! - 1)
            delegate?.saveContext()
            checkDataNumberInContext()
            print("The last JustString data numbers : ", num!)
            //when deleting testRefreshControlApp, i need delete imagedata in context
            if num! == 0{
                var imageDatas: [JustImage]?
                do{
                    imageDatas = try context?.fetch(JustImage.fetchRequest())
                } catch {
                    print("fetch images error")
                }
                print("Image data numbers in context : ", imageDatas!.count)
                while(imageDatas!.count > 0){
                    let num = imageDatas!.count - 1
                    let imageData = imageDatas?.remove(at: num)
                    context?.delete(imageData!)
                }
                checkImageDataNumberInContext()
                print("Image data numbers in context after finishing delete image data : " , imageNum!)
                delegate?.saveContext()
            }
        }
        tableViewController?.tableView.reloadData()
    }
    
    @objc func addData(){
        let aJustString = JustString(context: self.context!)
        data?.append(aJustString)
        checkDataNumberInContext()
        if(num! == 1){
            aJustString.content = "testRefreshControlApp"
            aJustString.order = Int64(num! - 1)
        }else{
            aJustString.content = String.init(format: "Other App [%d]", num! - 1)
            aJustString.order = Int64(num! - 1)
        }
        delegate?.saveContext()        
        tableViewController?.tableView.reloadData()
    }
    
    func checkDataNumberInContext(){
        do {
            num = (try context?.count(for: JustString.fetchRequest()))!
        } catch {
            print("fetch error")
        }
    }
    
    func checkImageDataNumberInContext(){
        do {
            imageNum = try context?.count(for: JustImage.fetchRequest())
        } catch {
            print("error")
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = (tableViewController?.tableView.dequeueReusableCell(withIdentifier: "MenuKey", for: indexPath))! as! MenuCell
        let content = data![indexPath.row].content
        cell.textLabel?.text = content
        if(content == "testRefreshControlApp"){
            cell.addButton()
            cell.button?.addTarget(self, action: #selector(self.intoRefreshControlApp), for: .touchDown)
        }
        return cell
    }
    
    @objc func intoRefreshControlApp(){
        // Before into RefreshControlApp we must set image in context
        let pictureName = ["blue.png", "bodyline.png", "darkvarder.png", "dudu.jpg", "hello.jpg", "hhhhh.jpg", "run.png", "wave.jpg"]
        
        var numberOfImageData: Int = 0
        do {
            numberOfImageData =  (try context?.count(for: JustImage.fetchRequest()))!
        } catch  {
            print("count error")
        }
        
        if numberOfImageData == 0 {
            for index in 0...7{
                let image = UIImage.init(named: pictureName[index])
                let myData = UIImagePNGRepresentation(image!)
                let aImage = JustImage(context: self.context!)
                aImage.content = pictureName[index]
                aImage.order = Int64(index + 100)
                aImage.imageData = myData
                (UIApplication.shared.delegate as! AppDelegate).saveContext()
            }
        }
        else if numberOfImageData < 8{
            let youNeedToAdd = 8 - numberOfImageData
            for index in 0...(youNeedToAdd - 1){
                let image = UIImage.init(named: pictureName[numberOfImageData + index])
                let imageData = UIImagePNGRepresentation(image!)
                let aJustImage = JustImage(context: self.context!)
                aJustImage.imageData = imageData
                aJustImage.content = pictureName[numberOfImageData + index]
                aJustImage.order = Int64(100 + numberOfImageData + index)
            }
        }
        self.navigationController?.pushViewController(ViewController(), animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data!.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
}
