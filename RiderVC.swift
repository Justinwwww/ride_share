//
//  RiderVC.swift
//  Ober
//
//  Created by Austin Glugla on 2/3/17.
//  Copyright © 2017 Portable Hats. All rights reserved.
//

import UIKit
import MapKit

class RiderVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, RideController {
    
    
    
    @IBOutlet weak var MyMap: MKMapView!
    
    
    
    @IBOutlet weak var acceptRidebtn: UIButton!
   
    
    private var locationManager = CLLocationManager();
    private var userLocation: CLLocationCoordinate2D?;
    private var riderLocation: CLLocationCoordinate2D?;
    
    private var timer = Timer();
    
    private var acceptedRide = false;
    private var driverCanceledRide = false;
    
    override func viewDidLoad() {
    super.viewDidLoad()
        intializeLocationManager();
        
        RideHandler.Instance.delegate = self;
        RideHandler.Instance.observeDriverMessages();
        
        
}
    
    
    private func intializeLocationManager() {
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.requestWhenInUseAuthorization();
        locationManager.startUpdatingLocation();
        
    }
    //if we have coordinates
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locationManager.location?.coordinate {
        
            
            userLocation = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            
            let region = MKCoordinateRegion(center: userLocation!, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01));
            
            MyMap.setRegion(region, animated: true);
            
            MyMap.removeAnnotations(MyMap.annotations);
            
            if riderLocation != nil {
                if acceptedRide {
                    let riderAnnotation = MKPointAnnotation();
                    riderAnnotation.coordinate = riderLocation!;
                    riderAnnotation.title = "Riders Location";
                    MyMap.addAnnotation(riderAnnotation);
                
                }
            }
            
            let annotation = MKPointAnnotation();
            annotation.coordinate = userLocation!;
            annotation.title = "Drivers Location";
            MyMap.addAnnotation(annotation);
            }
    
    }
    
    
    func acceptRide(lat: Double, long: Double){
        if !acceptedRide {
            rideRequest(title: "Ride Request", message: "You have requested a ride here Lat: \(lat), Long:\(long)", requestAlive: true);
            
        }
    }
    
    func riderCanceledRide() {
        if !driverCanceledRide {
            // cancel ride(driver)
            RideHandler.Instance.cancelRideForDriver();
            self.acceptedRide = false;
            self.acceptRidebtn.isHidden = true;
            rideRequest(title: "Ride Canceled", message: "The Rider has Canceled", requestAlive: false);
        }
    
    }
    
    func rideCanceled() {
        acceptedRide = false;
        acceptRidebtn.isHidden = true;
        timer.invalidate();
    }
    func updateRidersLocation(lat: Double, long: Double) {
        riderLocation = CLLocationCoordinate2D(latitude: lat, longitude: long);
    }
    
    func updateDriversLocation() {
        RideHandler.Instance.updateDriverLocation(lat: userLocation!.latitude, long: userLocation!.longitude);
    }
    
    
    
    @IBAction func SignOut(_ sender: Any) {
    
    
    
        if AuthProvider.Instance.logOut() {
           
            if acceptedRide {
                acceptRidebtn.isHidden = true;
                RideHandler.Instance.cancelRideForDriver();
                timer.invalidate();
            }
            dismiss(animated: true, completion: nil);
            
            
        }else {
            //Problem with sign out
            rideRequest(title: "Could not logout", message: "Unable to complete Sign Out process :O",  requestAlive: false)
           
        }
    }

    private func rideRequest(title: String, message: String, requestAlive: Bool) {
        
         let alert = UIAlertController(title: title, message: message, preferredStyle:  .alert);
        
        
        if requestAlive{
            let accept = UIAlertAction(title: "Accept", style: .default, handler: { (alertAction: UIAlertAction) in
                
                self.acceptedRide = true;
                self.acceptRidebtn.isHidden = false;
                
                self.timer = Timer.scheduledTimer(timeInterval: TimeInterval(10), target: self, selector: #selector(RiderVC.updateDriversLocation), userInfo: nil, repeats: true);
                
                RideHandler.Instance.rideAccepted(lat: Double(self.userLocation!.latitude), long: Double(self.userLocation!.longitude));
                
            });
            
            let cancel = UIAlertAction(title: "Cancel", style: .default, handler: nil);
            
            alert.addAction(accept);
            alert.addAction(cancel);
            
        } else {
            let ok = UIAlertAction(title: "OK", style:      .default, handler: nil);
            alert.addAction(ok);
        }
       
        
        present(alert, animated: true, completion: nil);
        
        
        
    }
    
    private func alterTheUser(title: String, message: String) {
            let alert = UIAlertController(title: title, message: message, preferredStyle:  .alert);
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil);
            alert.addAction(ok);
            present(alert, animated: true, completion: nil);
            
        }

    @IBAction func CancelRide(_ sender: Any) {
        if acceptedRide{
            driverCanceledRide = true;
            acceptRidebtn.isHidden = true;
            RideHandler.Instance.cancelRideForDriver();
            timer.invalidate();
            
        }
    }
    }
    
    
    

    
//class
