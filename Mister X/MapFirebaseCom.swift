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
    var name:String = ""
}

class MapFirebaseCom{
    
    let uTimeMisterX : Double
    let uTimeJaeger: Double
    //var firstTime : Bool = true
    var misterXChangedLocation = false
    var jaegerChangedLocation = false
    var allMisterXLocations : [UserLocationStruct]? = []
    var allJaegerLocations : [String:UserLocationStruct]? = [:]
    var newLocation = UserLocationStruct()
    var ref : DatabaseReference
    
    init(updateTime: Double, updateTimePlayer: Double) {
        uTimeMisterX = updateTime
        uTimeJaeger = updateTimePlayer
        ref = Database.database().reference()
    }
    
    func getGameCode() -> String? {
        let defaults = UserDefaults.standard
        return defaults.string(forKey: "gameCode")
    }
    
    func getUserID() -> String? {
        let defaults = UserDefaults.standard
        return defaults.string(forKey: "uid")
    }
    
    func observeMisterX() {
        ref.child("game/\(getGameCode()!)/MisterX").queryLimited(toLast: 1).observe(.childAdded , with: { (snapshot) in
            var newcoords = CLLocationCoordinate2D()
            let newvalue = snapshot.value as! NSDictionary
            newcoords.latitude = newvalue.value(forKey: "latitude") as! CLLocationDegrees
            newcoords.longitude = newvalue.value(forKey: "longitude") as! CLLocationDegrees
            let newkey = snapshot.key
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
            guard let newdate = dateFormatter.date(from: newkey) else {
                fatalError("ERROR: Date conversion failed due to mismatched format.")
            }
            var newloc = UserLocationStruct()
            newloc.coordinate = newcoords
            newloc.timestamp = newdate
            
            self.allMisterXLocations?.append(newloc)
            self.misterXChangedLocation = true
        })
    }
    
    func observeJaeger() {
        ref.child("game/\(getGameCode()!)/Jaeger").observe(.value , with: { (snapshot) in
            if let newvalues = snapshot.value as? NSDictionary{
                for (key,value) in newvalues {
                    
                    let newkey = key as! String
                    let newvalue = value as! NSDictionary
                    //print("jaeger key/newvalue: \(newkey) / \(newvalue)")
                    
                    var newcoords = CLLocationCoordinate2D()
                    newcoords.latitude = newvalue.value(forKey: "latitude") as! CLLocationDegrees
                    newcoords.longitude = newvalue.value(forKey: "longitude") as! CLLocationDegrees
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
                    guard let newdate = dateFormatter.date(from: newvalue.value(forKey: "timestamp") as! String) else {
                        fatalError("ERROR: Date conversion failed due to mismatched format.")
                    }
                    
                    var newloc = UserLocationStruct()
                    newloc.coordinate = newcoords
                    newloc.timestamp = newdate
                    newloc.name = newvalue.value(forKey: "username") as! String
                    
                    self.allJaegerLocations![newkey] = newloc
                    self.jaegerChangedLocation = true
                }
            }else{
                print("Keine Jäger Locations in Firebase")
            }
        })
    }
    
    
    func updateMisterXLocation(location: UserLocationStruct) {
        let newPosition: [String:Any] = ["latitude":Double((location.coordinate?.latitude)!), "longitude":Double((location.coordinate?.longitude)!)]
        if newLocation.timestamp == nil {
            newLocation = location
            ref.child("game/\(getGameCode()!)/MisterX/\(location.timestamp!)").setValue(newPosition)
        }else{
            if (location.timestamp!) > (newLocation.timestamp! + uTimeMisterX){
                newLocation = location
                ref.child("game/\(getGameCode()!)/MisterX/\(location.timestamp!)").setValue(newPosition)
            }
        }
    }
    
    func updateJaegerLocation(location: UserLocationStruct, name : String) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        let newdate = dateFormatter.string(from: location.timestamp!)
        
        let newPosition: [String:Any] = ["latitude":Double((location.coordinate?.latitude)!), "longitude":Double((location.coordinate?.longitude)!), "timestamp":newdate, "username":name]
        if newLocation.timestamp == nil {
            newLocation = location
            ref.child("game/\(getGameCode()!)/Jaeger/\(getUserID()!)").setValue(newPosition)
        }else{
            if (location.timestamp!) > (newLocation.timestamp! + uTimeJaeger){
                newLocation = location
                ref.child("game/\(getGameCode()!)/Jaeger/\(getUserID()!)").setValue(newPosition)
            }
        }
    }
    
    /*
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
     */
    
    /*
     Hilfe für Observerkram
     
     func getHistory(completion: @escaping ([UserLocationStruct]?) -> Void) {
     ref.child("game/\(getGameCode()!)/MisterX").observeSingleEvent(of: .value, with: { (snapshot) in
     completion(allLocations)
     
     //for child in snapshot.children.allObjects as! [DataSnapshot]{
     //let newvalues = child.value
     //let newkeys = child.key
     
     if let locations = snapshot.value as? NSDictionary{
     
     //let coords : [String:CLLocationDegrees] = ["latitude" : cvalue["latitude"]! as! CLLocationDegrees, "longitude": cvalue["longitude"]! as! CLLocationDegrees]
     //allLocations[newdate] = coords
     */
}
