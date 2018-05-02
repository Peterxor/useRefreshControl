//
//  ViewController.swift
//  useRefreshControl
//
//  Created by Peter on 2018/4/26.
//  Copyright © 2018年 Peter. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate{
    
    
    
    var collection: UICollectionViewController!
    var layout: UICollectionViewFlowLayout?
    var data: [JustImage]?
    var context: NSManagedObjectContext?
    var refreshControl: UIRefreshControl?
    var imageDataNumInContext: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        
        //set collection layout and collection setting
        layout = UICollectionViewFlowLayout()
        layout?.scrollDirection = .vertical
        layout?.itemSize = CGSize.init(width: 200, height: 200)
        layout?.sectionInset = UIEdgeInsets.init(top: 30, left: 30, bottom: 40, right: 40)
        collection = UICollectionViewController.init(collectionViewLayout: layout!)
        collection.collectionView?.delegate = self
        collection.collectionView?.dataSource = self
        collection.collectionView?.backgroundColor = .black
        collection.collectionView?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        self.view.addSubview(collection.collectionView!)
        
        //output data from context
        checkImageDataNumberInContext()
        
        do {
            data = try context?.fetch(JustImage.fetchRequest())
        } catch  {
            print("error")
        }
        data?.sort(by: {$0.order < $1.order})
        
        //set refreshcontrol
        collection.collectionView?.refreshControl = UIRefreshControl()
        self.refreshControl = collection.collectionView?.refreshControl
        refreshControl?.tintColor = UIColor.lightGray
        refreshControl?.attributedTitle = NSAttributedString.init(string: "Reloading Data", attributes: [.foregroundColor:UIColor.white])
        refreshControl?.addTarget(self, action: #selector(self.refresh), for: .valueChanged)
        
        
        
        
        
    }
    
    func checkImageDataNumberInContext(){
        do {
            imageDataNumInContext =  try context?.count(for: JustImage.fetchRequest())
        } catch {
            print("count image error")
        }
    }
    
    //
    @objc func refresh(){
        refreshControl?.beginRefreshing()
        var numberOfPictureInContext = 0
        do {
            numberOfPictureInContext =  (try context?.count(for: JustImage.fetchRequest()))!
        } catch {
            print("numberOfPictureInContext Error")
        }
        
        if numberOfPictureInContext > 6 {
            let subData1 = data!.remove(at: 7)
            let subData2 = data!.remove(at: 6)
            context?.delete(subData1)
            context?.delete(subData2)
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
        }
        collection.collectionView?.reloadData()
        refreshControl?.endRefreshing()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collection.collectionView?.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        let imageData = data![indexPath.row].imageData
        let imageView = UIImageView.init(image: UIImage.init(data: imageData!))
        cell?.backgroundView = imageView
        return cell!
    }
}

