//
//  RideHandler.swift
//  ober driver
//
//  Created by Austin Glugla on 2/5/17.
//  Copyright © 2017 Portable Hats. All rights reserved.
//

import Foundation
import FirebaseDatabase

protocol RideController: class {
    func acceptRide(lat: Double, long: Double);
    func riderCanceledRide();
    func rideCanceled();
    func updateRidersLocation(lat: Double, long: Double);
}

class RideHandler{
    private static let _instance = RideHandler();
    
    weak var delegate: RideController?;
    
    var rider = "";
    var driver = "";
    var driver_id = "";
    
    static var Instance: RideHandler{
        return _instance;
    }
    
    func observeDriverMessages() {
        //rider requested a car
        DBProvider.Instance.requestRef.observe(FIRDataEventType.childAdded) { (snapshot: FIRDataSnapshot) in
            
            if let data =  snapshot.value as? NSDictionary {
                if let latitude = data[Constants.LATITUDE] as?
                    Double {
                    if let longitude = data[Constants.LONGITUDE] as? Double{
                        self.delegate?.acceptRide(lat: latitude, long: longitude);
                        
                    }
                }
                
                if let name = data[Constants.NAME] as? String {
                    self.rider = name;
                }
            
                
            }
            DBProvider.Instance.requestRef.observe(FIRDataEventType.childRemoved, with: { (snapshot: FIRDataSnapshot) in
                if let data = snapshot.value as? NSDictionary {
                    if let name = data[Constants.NAME] as? String {
                        if name == self.rider {
                            self.rider = "";
                            self.delegate?.riderCanceledRide();
                        }
                    }
                }
                
            });
            
            //Rider updating Location
            DBProvider.Instance.requestRef.observe(FIRDataEventType.childChanged) { (snapshot: FIRDataSnapshot) in
                
                if let data = snapshot.value as? NSDictionary {
                    if let lat = data[Constants.LATITUDE] as? Double {
                        if let long = data [Constants.LONGITUDE] as? Double {
                            self.delegate?.updateRidersLocation(lat: lat, long: long);
                            
                        }
                    }
                }
                
            }
            
            // Driver Accepts Ride
            DBProvider.Instance.requestAcceptedRef.observe(FIRDataEventType.childAdded) { (snapshot: FIRDataSnapshot) in
                if let data = snapshot.value as? NSDictionary {
                    if let name = data[Constants.NAME] as? String {
                        if name == self.driver {
                            self.driver_id = snapshot.key;
                        }
                    }
                }
            }
            
            // Driver Caneled Ride 
            DBProvider.Instance.requestAcceptedRef.observe(FIRDataEventType.childRemoved) { (snapshot: FIRDataSnapshot) in
                if let data = snapshot.value as? NSDictionary {
                    if let name = data[Constants.NAME] as? String {
                        if name == self.driver {
                            self.delegate?.rideCanceled();
                            
                    }
                }
                }
            }
            
            
        }//observes messages
        
      
        }
    func rideAccepted( lat: Double, long: Double){
        let data: Dictionary<String,Any> = [Constants.NAME: driver, Constants.LATITUDE: lat, Constants.LONGITUDE: long];
        
        DBProvider.Instance.requestAcceptedRef.childByAutoId().setValue(data);
        
    }
    
    func cancelRideForDriver() {
        DBProvider.Instance.requestAcceptedRef.child(driver_id).removeValue();
    }
    
    func updateDriverLocation(lat: Double, long: Double) {
        DBProvider.Instance.requestAcceptedRef.child(driver_id).updateChildValues([Constants.LATITUDE: lat, Constants.LONGITUDE:long]);
    }
}
