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

class ViewControllerKarte: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    var isHistoryShown = false
    var lastPosition = MKPointAnnotation()
    
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var menuConstraint: NSLayoutConstraint!
    @IBOutlet var button_ich: UIButton!
    @IBAction func button_ich(_ sender: UIButton) {
        locationManager.startUpdatingLocation()
    }
    
    var misterXPositions = [Dictionary<String, Any>]()
    var isMisterX:Bool = false
    
    //var positions = [Dictionary<String, Any>]()
   

    
    func showHistorie(){
        var points: [CLLocationCoordinate2D] = [CLLocationCoordinate2D]()
        for coord in misterXPositions{
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: coord["latitude"] as! CLLocationDegrees,longitude: coord["longitude"] as! CLLocationDegrees)
            annotation.title = "Mister X"
            annotation.subtitle = "Position von Mister X um \(coord["title"])"
            mapView.addAnnotation(annotation)
            points.append(annotation.coordinate)
        }
        // Connect all the mappoints using Poly line.
        let polyline = MKPolyline(coordinates: points, count: points.count)
        mapView.add(polyline)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let polylineRenderer = MKPolylineRenderer(overlay: overlay)
        polylineRenderer.strokeColor = UIColor.red
        polylineRenderer.lineWidth = 5
        return polylineRenderer
    }
   
    
    func checkLocationAuthorizationStatus() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            mapView.showsUserLocation = true
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate=self
        //bottom menu
        bottomView.layer.shadowColor = UIColor.black.cgColor
        bottomView.layer.shadowOpacity = 0.8
        bottomView.layer.shadowOffset = CGSize(width: 5, height: 0)
        menuConstraint.constant = 128
        
        //Am I Mister X?
        let defaults = UserDefaults.standard
        let misterX = defaults.string(forKey: "misterX")
        var currentGame = defaults.string(forKey: "gameCode")
        
        
        let uid = defaults.string(forKey: "uid")
        var ref: DatabaseReference
        ref = Database.database().reference()
        /*ref.child("game").child(currentGame!).child("player").child(uid!).observeSingleEvent(of: .value, with: { (snapshot) /in
            // Get user value
            let value = snapshot.value as? NSDictionary
            let player = value!["MisterX"] as? Bool ?? false
            self.isMisterX = player
            print(self.isMisterX)
            //let user = User(username: username)
        }) { (error) in
            print("Geht nicht")
        }
 */
        
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
    
    @IBAction func toggleMenu(_ sender: UIButton) {
        if menuConstraint.constant > 0 {
            //hide menu
            UIView.animate(withDuration: 0.2, animations: {
                self.menuConstraint.constant = 0
                self.view.layoutIfNeeded()
            })
            
        }else{
            //show menu
            UIView.animate(withDuration: 0.2, animations: {
                self.menuConstraint.constant = 128
                self.view.layoutIfNeeded()
            })
        }
        
    }
    
    @IBOutlet weak var historySwitch: UISwitch!

    @IBAction func toggleHistorie(_ sender: UISwitch) {
        
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotation(lastPosition)
        mapView.removeOverlays(mapView.overlays)
        if isHistoryShown {
            //historie ausschalten
            isHistoryShown=false
            
        }
        else {
            //historie anschalten
            isHistoryShown=true
            showHistorie()
        }
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
        
        let currentGame = defaults.string(forKey: "gameCode")
        let misterX = defaults.string(forKey: "misterX")
        
        let uid = defaults.string(forKey: "uid")
        var ref: DatabaseReference
        ref = Database.database().reference()
        
        //Alle Annotations löschen
        mapView.removeAnnotations(mapView.annotations)
        if isHistoryShown{
            showHistorie()
        }
        
        if misterX! == "y" {
            
            //Firebase sync je nach Spieler
            ref.child("game/\(currentGame!)/Location/\(newLocName)").setValue(newPosition)
            
            //Neuste Annotation setzen wenn man MisterX ist
            print(misterX!)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = (newLoc)!
            annotation.title = "Mister X"
            annotation.subtitle = "Position von Mister X um \(newLocName)"
            mapView.addAnnotation(annotation)
            lastPosition = annotation
        }else{
            
            //Wenn Jäger dann Position in den player Zweig
            ref.child("game/\(currentGame!)/player/\(uid!)/Location/\(newLocName)").setValue(newPosition)
            
            print(misterX!)
        //ansonsten sich die Position von MisterX holen
            ref.child("game/\(currentGame!)/Location").observeSingleEvent(of: .value, with: { (snapshot) in
                if let result = snapshot.children.allObjects as? [DataSnapshot] {
                    //for child in result {
                        //do your logic and validation here
                    
                    let locations = snapshot.value as? NSDictionary
                    print (locations)
                    if locations != nil{
                        let firstkey = locations!.allKeys.first
                        let firstvalues = locations!.value(forKey: firstkey as! String)!as! NSDictionary
                        var newcoords = CLLocationCoordinate2D()
                        newcoords.latitude = firstvalues["latitude"]! as! CLLocationDegrees
                        newcoords.longitude = firstvalues["longitude"]! as! CLLocationDegrees
                    
                        print(firstvalues)
                        print("coords: \(newcoords) name: \(firstvalues["title"]!)")
                        
                        let annotation = MKPointAnnotation()
                        annotation.coordinate = newcoords
                        annotation.title = "Mister X"
                        annotation.subtitle = "Neue um \(firstvalues["title"]!)"
                        self.mapView.addAnnotation(annotation)
                    }else{
                        print("No values in Firebase")
                    }
                } else {
                    print("no results")
                }
            }) { (error) in
                print(error.localizedDescription)
            }
        }
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
