//
//  MapFirebaseCom.swift
//  Mister X
//
//  Created by Bill Bapisch on 07.01.18.
//  Copyright © 2018 Praktikum. All rights reserved.
//

import Foundation
import MapKit
import CoreLocation
import FirebaseDatabase

struct UserLocationStruct {
    var coordinate:CLLocationCoordinate2D?
    var timestamp:Date?
}

class MapFirebaseCom{
    
    let uTime : Double
    var firstTime : Bool = true
    var newMisterXLocation = UserLocationStruct()
    var ref : DatabaseReference
    private var map : MKMapView?
    
    init(updateTime: Double) {
        uTime = updateTime
        ref = Database.database().reference()
    }
    
    func getGameCode() -> String? {
        let defaults = UserDefaults.standard
        return defaults.string(forKey: "gameCode")
    }
    
    func getMisterXLocation() -> UserLocationStruct {
        return newMisterXLocation
    }
    
    func updateLocation(location: UserLocationStruct) -> Bool {
        var rc = false
        if firstTime {
            newMisterXLocation = location
            setMisterX(loc: newMisterXLocation)
            rc = true
            firstTime = false
        }else{
            //print("actual: \(location.timestamp!) new: \(newMisterXLocation.timestamp!) new+: \(newMisterXLocation.timestamp! + uTime)")
            if (location.timestamp!) > (newMisterXLocation.timestamp! + uTime){
                newMisterXLocation = location
                setMisterX(loc: newMisterXLocation)
                rc = true
            }
        }
        return rc
    }
    
    func getHistory(completion: @escaping ([UserLocationStruct]?) -> Void) {
        ref.child("game/\(getGameCode()!)/MisterX").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get all Locations
            //var allLocations: [Date:[String:Any]] = [:]
            var allLocations : [UserLocationStruct]? = []
            for child in snapshot.children.allObjects as! [DataSnapshot]{
                if let cvalue = child.value as? NSDictionary{
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
                    guard let newdate = dateFormatter.date(from: child.key) else {
                        fatalError("ERROR: Date conversion failed due to mismatched format.")
                    }
                    var newloc = UserLocationStruct()
                    var newcoord = CLLocationCoordinate2D()
                    newcoord.latitude = cvalue["latitude"]! as! CLLocationDegrees
                    newcoord.longitude = cvalue["longitude"]! as! CLLocationDegrees
                    newloc.coordinate = newcoord
                    newloc.timestamp = newdate
                    
                    print("newcoords \(newloc)")
                    
                    allLocations?.append(newloc)
                    
                    //let coords : [String:CLLocationDegrees] = ["latitude" : cvalue["latitude"]! as! CLLocationDegrees, "longitude": cvalue["longitude"]! as! CLLocationDegrees]
                    //allLocations[newdate] = coords
                    
                    print(allLocations!)
                    completion(allLocations)
                }else{
                    print("No values in Firebase")
                }
            }

        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func getMisterX(map: MKMapView) {
        self.map = map
        ref.child("game/\(getGameCode()!)/MisterX").queryLimited(toLast: 1).observe(.childAdded , with: { (snapshot) in
            var newcoords = CLLocationCoordinate2D()
            let newvalue = snapshot.value as! NSDictionary
            newcoords.latitude = newvalue.value(forKey: "latitude") as! CLLocationDegrees
            newcoords.longitude = newvalue.value(forKey: "longitude") as! CLLocationDegrees
            let newkey = snapshot.key
            //print("Val: \(newvalue) Key: \(newkey)")
        
            /*
            //Remove Annotations
            //self.map.removeAnnotations(map.annotations)
            
            //Set new Annotation
            let annotation = MKPointAnnotation()
            annotation.coordinate = newcoords
            annotation.title = "Mister X"
             */
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
            guard let newdate = dateFormatter.date(from: newkey) else {
                fatalError("ERROR: Date conversion failed due to mismatched format.")
            }
            
            var newloc = UserLocationStruct()
            newloc.coordinate = newcoords
            newloc.timestamp = newdate
            self.setAnnotation(loc: newloc, title: "MisterX")
            
            /*
            dateFormatter.dateFormat = "HH:mm:ss"
            let newdate2 = dateFormatter.string(from: newdate)
            annotation.subtitle = "Mister X um \(newdate2)"
            self.map.addAnnotation(annotation)
            
            
            Hilfe
             //for child in snapshot.children.allObjects as! [DataSnapshot]{
             //let newvalues = child.value
             //let newkeys = child.key
             
            if let locations = snapshot.value as? NSDictionary{
             */
        })
    }
    
    func setMisterX(loc: UserLocationStruct){
        let newPosition: [String:Any] = ["latitude":Double((loc.coordinate?.latitude)!), "longitude":Double((loc.coordinate?.longitude)!)]
        ref.child("game/\(getGameCode()!)/MisterX/\(loc.timestamp!)").setValue(newPosition)
    }
    
    func setAnnotation(loc : UserLocationStruct, title : String) {
        //Remove Annotations
        map?.removeAnnotations((map?.annotations)!)
        
        //Set new Annotation
        let annotation = MKPointAnnotation()
        annotation.coordinate = loc.coordinate!
        annotation.title = title
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        let newdate = dateFormatter.string(from: loc.timestamp!)
        annotation.subtitle = "\(title) um \(newdate)"
        map?.addAnnotation(annotation)
    }
    
    func getTodayString() -> String{
        
        let date = Date()
        let calender = Calendar.current
        let components = calender.dateComponents([.year,.month,.day,.hour,.minute,.second], from: date)
        
        //let year = components.year
        //let month = components.month
        //let day = components.day
        let hour = components.hour
        let minute = components.minute
        let second = components.second
        
        let today_string = String(format: "%02d", hour!)  + ":" + String(format: "%02d", minute!) + ":" +  String(format: "%02d", second!)
        
        return today_string
    }
}
