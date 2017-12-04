//
//  ViewControllerKarte.swift
//  Mister X
//
//  Created by admin on 10.11.17.
//  Copyright © 2017 Praktikum. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Foundation
import FirebaseDatabase

class ViewControllerKarte: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    
    @IBOutlet var button_ich: UIButton!
    @IBAction func button_ich(_ sender: UIButton) {
        locationManager.startUpdatingLocation()
    }
    
    var misterXPositions = [Dictionary<String, Any>]()
    
    func checkLocationAuthorizationStatus() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            mapView.showsUserLocation = true
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        func doblur(_ button:UIButton) {
            button.layer.cornerRadius = 5
            let blur = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.light))
            blur.frame = button.bounds
            blur.isUserInteractionEnabled = false //This allows touches to forward to the button.
            button.insertSubview(blur, at: 0)
            blur.layer.cornerRadius = 5//0.5 * button_ich.bounds.size.width
            blur.clipsToBounds = true
        }
        doblur(button_ich)
        
        //mapView.setUserTrackingMode(.follow, animated: true)
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest//kCLLocationAccuracyNearestTenMeters
            //locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        }
        //TODO: Timer läuft nicht immer. Bsp: Wenn App im Hintergrund ist
        //Alle x Sekunden wird updateMisterXPosition aufgerufen
        let xSekunden: Double = 10.0
        var misterXTimer = Timer.scheduledTimer(timeInterval: xSekunden, target: self, selector: #selector(ViewControllerKarte.updateMisterXPosition), userInfo: nil, repeats: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        //let location = locations.last! as CLLocation
        if let location = locations.last {
            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
            self.mapView.setRegion(region, animated: true)
        }
        manager.stopUpdatingLocation()
    }
    
    @objc func updateMisterXPosition()
    {
        //Variablen damit Name und Ort überall gleich ist
        let newLoc = locationManager.location?.coordinate
        let newLocName = getTodayString()
        let newPosition: [String:Any] = ["title": newLocName, "latitude":Double((newLoc?.latitude)!), "longitude":Double((newLoc?.longitude)!)]
        misterXPositions.append(newPosition)
        
        //Firebase sync
        let defaults = UserDefaults.standard
        let currentGame = defaults.string(forKey: "currentGame")
        let uid = defaults.string(forKey: "uid")
        var ref: DatabaseReference
        ref = Database.database().reference()
        ref.child("game/\(currentGame!)/player/\(uid!)/Location/\(newLocName)").setValue(newPosition)
        
        //Alle Annotations löschen
        mapView.removeAnnotations(mapView.annotations)
        
        //Neuste Annotation setzen
        let annotation = MKPointAnnotation()
        annotation.coordinate = (newLoc)!
        annotation.title = "Mister X"
        annotation.subtitle = "Position von Mister X um \(newLocName)"
        mapView.addAnnotation(annotation)
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkLocationAuthorizationStatus()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
