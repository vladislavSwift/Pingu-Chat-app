//
//  LocationPickerViewController.swift
//  Pingu Chat
//
//  Created by vladislav vaz on 27/11/20.
//  Copyright © 2020 vladislav vaz. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

final class LocationPickerViewController: UIViewController {
    
    public var completion: ((CLLocationCoordinate2D) -> Void)?
    
    private var coordinates: CLLocationCoordinate2D?
    
    private var isPickable = true
    
    
    private let map: MKMapView = {
        
        let map = MKMapView()
        return map
        
    }()
    
    init(coordinates: CLLocationCoordinate2D?) {
        
        self.coordinates = coordinates
        self.isPickable = coordinates == nil
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        
        if isPickable {
            
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Send",
                                                                style: .done,
                                                                target: self,
                                                                action: #selector(sendButtonTapped))
            
            
            navigationItem.rightBarButtonItem?.isEnabled = false
            
            
            map.isUserInteractionEnabled = true
            
            
            let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapMap(_:)))
            
            gesture.numberOfTouchesRequired = 1
            gesture.numberOfTapsRequired = 1
            map.addGestureRecognizer(gesture)
            
            
        } else {
            
            //just showing location
            
            guard let coordinates = self.coordinates else {
                
                return
            }
            
            let region = MKCoordinateRegion( center: coordinates, latitudinalMeters: CLLocationDistance(exactly: 800)!, longitudinalMeters: CLLocationDistance(exactly: 800)!)
            map.setRegion(map.regionThatFits(region), animated: true)
            
            //drop pin on the map for user to show the location
            
            let pin = MKPointAnnotation()
            pin.coordinate = coordinates
            
            map.addAnnotation(pin)
            
            
        }
        
        

        //view.backgroundColor = .blue   // Not required
        view.addSubview(map)
        
        
    }
    
    
    @objc func sendButtonTapped() {
        
        guard let coordinates = coordinates else {
            
            return
        }
        
        navigationController?.popViewController(animated: true)
        
        completion?(coordinates)
        
    }
    
    
    @objc func didTapMap(_ gesture: UITapGestureRecognizer) {
        
        
        navigationItem.rightBarButtonItem?.isEnabled = true
        
        let locationInView = gesture.location(in: map)
        let coordinates = map.convert(locationInView, toCoordinateFrom: map)
        self.coordinates = coordinates
        
        //Remove more than one map pins from the mapView
        for annotation in map.annotations {
            
            map.removeAnnotation(annotation)
        }
        
        //drop pin on the map for user to choose the location
        
        let pin = MKPointAnnotation()
        pin.coordinate = coordinates
        
        map.addAnnotation(pin)
        
    }
    

    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        map.frame = view.bounds
    }
    
    
    


}
