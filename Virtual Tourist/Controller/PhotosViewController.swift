//
//  PhotosViewController.swift
//  Virtual Tourist
//
//  Created by Bahi El Feky on 5/17/19.
//  Copyright © 2019 Bahi El Feky. All rights reserved.
//

import UIKit
import CoreData
import MapKit
import Kingfisher

class PhotosViewController : UIViewController {
    
    @IBOutlet weak var myMapView: MKMapView!
    @IBOutlet weak var myCollectionView: UICollectionView!
    @IBOutlet weak var btnNewPhotos: UIButton!
    
    private let itemsPerRow: CGFloat = 2
    private let insets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
    private let reuseId = "CollectionViewCell"
    var dataController: DataController!
    var resultsController: NSFetchedResultsController<Photo>!
    var pin: Pin!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myCollectionView.dataSource = self
        myCollectionView.delegate = self
        
        initResults()
        
        setNewPhotosButtonEnabled(to: false)
        
        if (resultsController.sections?[0].numberOfObjects ?? 0 == 0) {
            getPhotos()
        } else {
            setNewPhotosButtonEnabled(to: true)
        }
        
        myMapView.addAnnotation(pin)
        myMapView.showAnnotations([pin], animated: true)
        myMapView.isUserInteractionEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
        super.viewWillAppear(animated)
        initResults()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        resultsController = nil
    }
    
    private func setNewPhotosButtonEnabled(to state: Bool) {
        btnNewPhotos.isEnabled = state
    }
    
    private func initResults() {
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        let predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.predicate = predicate
        resultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "\(pin!.creationDate!)-photos")
        resultsController.delegate = self
        do {
            try resultsController.performFetch()
        } catch {
            fatalError("fetch error: \(error.localizedDescription)")
        }
    }
    
    private func getPhotos() {
        setNewPhotosButtonEnabled(to: false)
        FlickerAPI.getListOfPhotosIn(lat: pin.lat, lon: pin.long) { (error, photosURL) in
            
            if error.contains("Not Connected"){
                DispatchQueue.main.async {
                    self.showAlert(message: "Error, No Connection")
                }
            }
            else if error.contains("Connected"){
                for photoURL in photosURL! {
                    self.addPhoto(url: photoURL)
                    
                }
            }
            else {
                DispatchQueue.main.async {
                    self.showAlert(message: "Somthing Wrong happend. Please try again later!")
                }
            }
            
            DispatchQueue.main.async {
                self.myCollectionView.reloadData()
                self.setNewPhotosButtonEnabled(to: true)
            }
        }
    }
    
    func addPhoto(url: String) {
        
        let photo = Photo(context: dataController.viewContext)
        photo.creationDate = Date()
        photo.url = url
        photo.pin = pin
        try? dataController.viewContext.save()
        
    }
    
    func deletePhoto(_ photo: Photo) {
        dataController.viewContext.delete(photo)
        do {
            try dataController.viewContext.save()
        } catch {
            print("Error saving")
        }
        
    }
    
    @IBAction func reloadPhotos() {
        if let photos = resultsController.fetchedObjects {
            for photo in photos {
                dataController.viewContext.delete(photo)
                do {
                    try dataController.viewContext.save()
                } catch {
                    print("Error deleting")
                }
            }
        }
        getPhotos()
    }
    
}

extension PhotosViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let padding = insets.right * (itemsPerRow + 1)
        let availableWidth = view.frame.width - padding
        let widthOfItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthOfItem, height: widthOfItem)
        
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return insets
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return insets.right
    }
}

extension PhotosViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (resultsController.sections?[section].numberOfObjects ?? 0 == 0) {
            collectionView.setEmptyMessage("No Photos!")
        } else {
            collectionView.deleteEmptyMessage()
        }

        return resultsController.sections?[section].numberOfObjects ?? 0
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cellPhoto = resultsController.object(at: indexPath)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseId, for: indexPath) as! CollectionViewCell
        
        // Configure cell
        if let photoData = cellPhoto.data {
            cell.cellImage.image = UIImage(data: photoData)
        } else if let photoURL = cellPhoto.url {
            guard let url = URL(string: photoURL) else {
                return cell
            }
            cell.cellImage.kf.setImage(with: url, placeholder: UIImage(named: "Placeholder"), options: nil, progressBlock: nil) { (img, err, cacheType, url) in
                if ((err) != nil) {

                } else {
                    cellPhoto.data = img?.pngData()
                    try? self.dataController.viewContext.save()
                }
            }
        }
        
        return cell
    }
}

extension PhotosViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photoToDelete = resultsController.object(at: indexPath)
        deletePhoto(photoToDelete)
        
    }
    
}

extension PhotosViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            myCollectionView.insertItems(at: [newIndexPath!])
            break
        case .delete:
                self.myCollectionView.deleteItems(at: [indexPath!])
            break
        default: ()
        }
    }
}

extension UICollectionView {
    func setEmptyMessage(_ message: String) {
        
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textAlignment = .center;
        messageLabel.sizeToFit()
        self.backgroundView = messageLabel;
        
    }
    func deleteEmptyMessage() {
        DispatchQueue.main.async {
        self.backgroundView = nil
        }
    }
}

