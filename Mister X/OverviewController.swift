//
//  OverviewController.swift
//  Mister X
//
//  Created by admin on 12.01.18.
//  Copyright © 2018 Praktikum. All rights reserved.
//

import UIKit
import FirebaseDatabase
import MapKit

class OverviewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet var mapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
        Database.database().reference().child("game").observe(.childAdded, with: { (snap: DataSnapshot) in
            
            for s in snap.children {
                
                //check if the game is still running
                if (s as! DataSnapshot).key == "MisterX" {
                    var time: [Int] = [2018, 1, 1, 0, 0]
                    var coord = CLLocationCoordinate2D(latitude: 0, longitude: 0);
                    
                    let date = Date()
                    let calendar = Calendar.current
                    let day = calendar.component(.day, from: date)
                    let month = calendar.component(.month, from: date)
                    let year = calendar.component(.year, from: date)
                    let hour = calendar.component(.hour, from: date)
                    var minutes = calendar.component(.minute, from: date)
                    
                    
                    
                    
                    for t in (s as! DataSnapshot).children {
                        
                        let temp = (t as! DataSnapshot).key
                        let timeArray = temp.components(separatedBy: " ")
                        let ymd = timeArray[0].components(separatedBy: "-")
                        let hms = timeArray[1].components(separatedBy: ":")
                        let value = (t as! DataSnapshot).value as? NSDictionary
                        
                        //get latest time
                        //later year
                        if Int(ymd[0])! > time[0] {
                            time = [Int(ymd[0])!, Int(ymd[1])!, Int(ymd[2])!, Int(hms[0])!, Int(hms[1])!]
                            coord.longitude = value?["longitude"] as? Double ?? 0
                            coord.latitude = value?["latitude"] as? Double ?? 0
                        }
                        else if Int(ymd[0])! == time[0] {
                            //later month
                            if Int(ymd[1])! > time[1] {
                                time = [Int(ymd[0])!, Int(ymd[1])!, Int(ymd[2])!, Int(hms[0])!, Int(hms[1])!]
                                coord.longitude = value?["longitude"] as? Double ?? 0
                                coord.latitude = value?["latitude"] as? Double ?? 0
                            }
                            else if Int(ymd[1])! == time[1] {
                                //later day
                                if Int(ymd[2])! > time[2] {
                                    time = [Int(ymd[0])!, Int(ymd[1])!, Int(ymd[2])!, Int(hms[0])!, Int(hms[1])!]
                                    coord.longitude = value?["longitude"] as? Double ?? 0
                                    coord.latitude = value?["latitude"] as? Double ?? 0
                                }
                                else if Int(ymd[2])! == time[2] {
                                    //later hour
                                    if Int(hms[0])! > time[3] {
                                        time = [Int(ymd[0])!, Int(ymd[1])!, Int(ymd[2])!, Int(hms[0])!, Int(hms[1])!]
                                        coord.longitude = value?["longitude"] as? Double ?? 0
                                        coord.latitude = value?["latitude"] as? Double ?? 0
                                    }
                                    else if Int(hms[0])! == time[3] {
                                        //later minute
                                        if Int(hms[1])! > time[4] {
                                            time = [Int(ymd[0])!, Int(ymd[1])!, Int(ymd[2])!, Int(hms[0])!, Int(hms[1])!]
                                            coord.longitude = value?["longitude"] as? Double ?? 0
                                            coord.latitude = value?["latitude"] as? Double ?? 0
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    if time[0] == year && time[1] == month && time[2] == day {
                        time[3] = time[3]+1
                        if time[3] == hour {
                            if minutes-20 < time[4] {
                                let annotation = MisterXAnnotation(coordinate: coord,gameCode: snap.key)
                                self.mapView.addAnnotation(annotation)
                                print(snap.key)
                            }
                        }
                        if time[3] == hour-1 {
                            if minutes-20 < 0 {
                                minutes = 60 + minutes-20
                                if minutes < time[4] {
                                    let annotation = MisterXAnnotation(coordinate: coord,gameCode: snap.key)
                                    self.mapView.addAnnotation(annotation)
                                    print(snap.key)
                                }
                            }
                        }
                    }

                    
                }
            }
            
            
        })
    }
    
    //Add button to annotation
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseIdentifier = "MisterXAnnotation"
        print(reuseIdentifier)
        if annotation is MKUserLocation { return nil }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier) as? MKPinAnnotationView
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
            annotationView?.canShowCallout = false
        } else {
            annotationView?.annotation = annotation
        }
        
        return annotationView
    }

    //action when annotation was tapped
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let game = view.annotation as! MisterXAnnotation
        print(game.gameCode!)
        let alert = UIAlertController(title: "Achtung", message: "Willst du diesem Spiel beitreten?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ja", style: UIAlertActionStyle.destructive, handler: { action in
            //add player to game
            let defaults = UserDefaults.standard
            defaults.set(game.gameCode!, forKey:"gameCode")
            defaults.set("", forKey:"misterX")
            let uid = defaults.string(forKey: "uid")
            Database.database().reference().child("game").child(game.gameCode!).child("player").child(uid!).setValue(["MisterX" : false])
            
            
            self.performSegue(withIdentifier: "joinGameFromOverview", sender: self)
        }))
        alert.addAction(UIAlertAction(title: "Nein", style: UIAlertActionStyle.cancel, handler: nil))
        
        present(alert, animated: true)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
