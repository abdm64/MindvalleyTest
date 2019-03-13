//
//  ViewController.swift
//  testHttpreq
//
//  Created by ABD on 09/03/2019.
//  Copyright © 2019 ABD. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SDDownloadManager
import SDWebImage





class ViewController: UIViewController {
    // Mark : Outltes
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // Mark : Var
    
    let images = [#imageLiteral(resourceName: "image2"),#imageLiteral(resourceName: "image1"), #imageLiteral(resourceName: "image8"),#imageLiteral(resourceName: "image4"),#imageLiteral(resourceName: "image7"), #imageLiteral(resourceName: "image3"), #imageLiteral(resourceName: "image6")]
    var isLoading: Bool = false
    var photoThumbnail: UIImage!
    var selectedIndexPath: IndexPath!
    
    
    
    
    
  
   
    var photoArray = [Photo]()

   

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.retruveDatafromUrl(url: BASE_URL)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.activityIndicator.stopAnimating()
             self.collectionView.reloadData()
            
        }
       
        
        if let layout = collectionView.collectionViewLayout as? PinterestLayout {
            layout.delegate = self
        }
        collectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    //Mark UI
    
    
    
    func retruveDatafromUrl(url : String) {
        
        
             let url = URL(string: url)
        
        URLSession.shared.dataTask(with: url!) { (data, response, err) in
                self.isLoading = true
                    guard let data = data else {return}
            do {
                    let jsonData = try JSON(data : data)
                for i in 0...9 {
                    
                    self.retrivePhotoData(i: i, jsonData: jsonData)
                    
                }
                
                
                
                  
        
            } catch  {
                print(error)
                
            }
        
                }.resume()
         self.isLoading = false
        
    }
    func retrivePhotoData(i: Int, jsonData : JSON){
        let id = jsonData[i]["id"].stringValue
        let rowUrl = jsonData[i]["urls"]["raw"].stringValue
        let fullUrl  = jsonData[i]["urls"]["full"].stringValue
        let regularUrl = jsonData[i]["urls"]["regular"].stringValue
        let smallUrl = jsonData[i]["urls"]["small"].stringValue
        let thumbUrl =  jsonData[i]["urls"]["thumb"].stringValue
        let height = jsonData[i]["height"].intValue
        
        let url = Photo(id: id, raw: rowUrl, full: fullUrl, regular: regularUrl, small: smallUrl, thumb: thumbUrl, height: height)
        
        
        self.photoArray.append(url)
    
      
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier ==  SHOW_IMAGE_SEGUE {
        
            let imagedetailVC = segue.destination as! ImageDetaisVC
            let backItem = UIBarButtonItem()
            backItem.title = "Back"
            navigationItem.backBarButtonItem = backItem
            imagedetailVC.passedImage = photoThumbnail
            
            
        }
    }

   
    
        
    }
// Mark Flow layout Deleget

extension ViewController : PinterestLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        let height : CGFloat = CGFloat(photoArray[indexPath.item].height)
    
        return height * 0.2
    }
    
    
    
    
    
    
    
    
}
// Mark : DataSource

extension  ViewController : UICollectionViewDataSource, UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PHOTO_CELL, for: indexPath) as! PhotoCell
       // let image = images[indexPath.item]
      //  cell.imageView.image = image
        cell.downloadImage(withUrlString: photoArray[indexPath.item].regular)
       
        
        cell.imageView.image = photoThumbnail
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
      let cell = collectionView.cellForItem(at:  indexPath) as! PhotoCell
        
        photoThumbnail = cell.imageView.image
        
        self.selectedIndexPath = indexPath
        
        
    
        performSegue(withIdentifier: SHOW_IMAGE_SEGUE, sender: photoThumbnail)
    }
    
    
    
    
    
    
}

extension ViewController : ZoomingViewController {
    
    func zoomingBackgroundView(for transition: ZoomTransitioningDelegate) -> UIView? {
        return nil
    }
    
    func zoomingImageView(for transition: ZoomTransitioningDelegate) -> UIImageView? {
        if let indexPath = selectedIndexPath {
            let cell = collectionView?.cellForItem(at: indexPath) as! PhotoCell
            return cell.imageView
        }
        
        return nil
    }

    
}
