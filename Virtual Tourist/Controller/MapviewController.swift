//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by Bahi El Feky on 5/11/19.
//  Copyright © 2019 Bahi El Feky. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapviewController: UIViewController {
    
    var dataController : DataController!
    
    @IBOutlet weak var myMapView: MKMapView!
    
    var resultsController: NSFetchedResultsController<Pin>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initResults()
        initMapAnnoitations()
        initLongPress()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        initResults()
        initMapAnnoitations()
        // TODO: update pins
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        resultsController = nil
    }
    

    
    private func initMapAnnoitations() {
        
        if let pins = resultsController.fetchedObjects {
            myMapView.addAnnotations(pins)
        }
        
    }
    private func initResults() {
        
        let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        resultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "pins")
        resultsController.delegate = self
        do {
            try resultsController.performFetch()
        } catch {
            fatalError("Fetch ERROR!: \(error.localizedDescription)")
        }
    }
    @objc func longPressed(sender: UILongPressGestureRecognizer) {
        
        if sender.state != .began {
            return
        }
        
        let touchPoint = sender.location(in: myMapView)
        let newCoordinates = myMapView.convert(touchPoint, toCoordinateFrom: myMapView)
        addNewPin(longitude: newCoordinates.longitude, latitude: newCoordinates.latitude)
    }
    func initLongPress(){
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressed(sender:)))
        myMapView.delegate = self
        myMapView.addGestureRecognizer(longPressRecognizer)
        
    }
    
    func addNewPin(longitude: Double, latitude: Double) {
        
        let pin = Pin(context: dataController.viewContext)
        pin.long = longitude
        pin.lat = latitude
        pin.creationDate = Date()
         do {
            try? dataController.viewContext.save()
        }
         catch{}
    }
    
    
}

extension MapviewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        if overlay.isKind(of: MKCircle.self) {
            let view = MKCircleRenderer(overlay: overlay)
            view.fillColor = UIColor.black.withAlphaComponent(0.2)
            return view
        }
        return MKOverlayRenderer(overlay: overlay)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        mapView.deselectAnnotation(view.annotation! , animated: true)
        
        let pin: Pin = view.annotation as! Pin
        let photosVC = storyboard?.instantiateViewController(withIdentifier: "PhotosViewController") as! PhotosViewController;
        photosVC.pin = pin
        photosVC.dataController = dataController
        
        navigationController?.pushViewController(photosVC, animated: true)
    }
}


extension MapviewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        guard let pin = anObject as? Pin else {
            preconditionFailure("Faild Pin")
        }
        
        switch type {
        case .insert:
            myMapView.addAnnotation(pin)
            break
        default: ()
        }
        
    }
}
