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
    var mfc = MapFirebaseCom(updateTime: 30.0, updateTimePlayer: 10.0)
    var myLocation = UserLocationStruct()
    var boost1 : [UserLocationStruct] = []
    var lookAtMap : Bool = true
    var lastPosition = MKPointAnnotation()
    
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var menuConstraint: NSLayoutConstraint!
    @IBOutlet var button_ich: UIButton!
    @IBAction func button_ich(_ sender: UIButton) {
        if myLocation.coordinate != nil {
            let region = MKCoordinateRegion(center: (myLocation.coordinate)!, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
            self.mapView.setRegion(region, animated: true)
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let polylineRenderer = MKPolylineRenderer(overlay: overlay)
        polylineRenderer.strokeColor = UIColor.red
        polylineRenderer.lineWidth = 5
        return polylineRenderer
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if (annotation is MKUserLocation) {
            return nil
        }
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "myAnnotation") as? MKPinAnnotationView

        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "myAnnotation")
            annotationView?.canShowCallout = true
        } else {
            annotationView?.annotation = annotation
        }
        
        if let annotation = annotation as? MyPointAnnotation {
            annotationView?.pinTintColor = annotation.pinTintColor
        }
 
        return annotationView
    }
    
    func checkLocationAuthorizationStatus() {
        if CLLocationManager.authorizationStatus() == .authorizedAlways{
            mapView.showsUserLocation = true
        } else {
            locationManager.requestAlwaysAuthorization()
            locationManager.allowsBackgroundLocationUpdates = true
        }
        /*
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            mapView.showsUserLocation = true
        } else {
            locationManager.requestWhenInUseAuthorization()
            locationManager.requestAlwaysAuthorization()
            locationManager.allowsBackgroundLocationUpdates = true
        }
 */
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate=self
        //bottom menu
        bottomView.layer.shadowColor = UIColor.black.cgColor
        bottomView.layer.shadowOpacity = 0.8
        bottomView.layer.shadowOffset = CGSize(width: 5, height: 0)
        menuConstraint.constant = 128
        
        //Start MisterX Loc Observer
        mfc.observeMisterX()
        mfc.observeJaeger()
        
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
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters //kCLLocationAccuracyBest
            //locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        }
        let defaults = UserDefaults.standard
        let misterX = defaults.string(forKey: "misterX")
        if misterX! == "y" {
        
        }else{
            Boost1_button.isEnabled = false
            Boost2_button.isEnabled = false
            Boost3_button.isEnabled = false
        }
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
    
    @IBOutlet weak var Boost1_button: UIButton!
    @IBAction func Boost1(_ sender: UIButton) {
        for (_ , userlocation) in mfc.allJaegerLocations!{
            boost1.append(userlocation)
        }
        Boost1_button.isEnabled = false
        showMapObjects()
    }
    
    @IBOutlet weak var Boost2_button: UIButton!
    @IBAction func Boost2(_ sender: UIButton) {
    }
    
    @IBOutlet weak var Boost3_button: UIButton!
    @IBAction func Boost3(_ sender: UIButton) {
    }
    
    
    @IBOutlet weak var historySwitch: UISwitch!

    @IBAction func toggleHistorie(_ sender: UISwitch) {
        showMapObjects()
    }
    
    func showMapObjects() {
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)
        
        if historySwitch.isOn{
            var points: [CLLocationCoordinate2D] = [CLLocationCoordinate2D]()
            if (mfc.allMisterXLocations != nil){
                for loc in mfc.allMisterXLocations!{
                    self.setAnnotation(loc: loc, isMisterX: true)
                    points.append(loc.coordinate!)
                }
            }
            let polyline = MKPolyline(coordinates: points, count: points.count)
            self.mapView.add(polyline)
        }else{
            if mfc.allMisterXLocations?.last != nil {
                setAnnotation(loc: (mfc.allMisterXLocations?.last)!, isMisterX: true)
            }
        }
        let defaults = UserDefaults.standard
        let misterX = defaults.string(forKey: "misterX")
        if misterX! != "y" {
            for (_ , userlocation) in mfc.allJaegerLocations!{
                setAnnotation(loc: userlocation, isMisterX: false)
            }
        }
        if boost1.isEmpty{
            //print("No Jaeger in Game")
        }else{
            for jaeger in boost1{
                setAnnotation(loc: jaeger, isMisterX: false)
            }
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        //let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        if let location = locations.last {
            
            //lookAtMap wird am Anfang und wenn die View wieder aufgerufen wird gesetzt und dann wird auf die aktuelle Position gezoomt
            if lookAtMap{
                let region = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
                self.mapView.setRegion(region, animated: true)
                lookAtMap = false
            }
            
            //updateLocation schreiben der Location von MisterX und Jäger in die Firebase
            myLocation.coordinate = location.coordinate
            myLocation.timestamp = location.timestamp
            //print("Location Service running")
            let defaults = UserDefaults.standard
            let misterX = defaults.string(forKey: "misterX")
            if misterX! == "y" {
                mfc.updateMisterXLocation(location: myLocation)
            }else{
                let name = defaults.string(forKey: "name")
                mfc.updateJaegerLocation(location: myLocation, name: name!)
            }
            
            //Wenn sich die Position von MisterX geändert hat dann Historie oder Annotation updaten
            //Firebase meldet die Veränderung durch einen Observer
            if mfc.misterXChangedLocation{
                showMapObjects()
                mfc.misterXChangedLocation = false
            }
            if mfc.jaegerChangedLocation{
                showMapObjects()
                mfc.jaegerChangedLocation = false
            }
        }
    }
    
    func setAnnotation(loc : UserLocationStruct, isMisterX: Bool) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        let newdate = dateFormatter.string(from: loc.timestamp!)
        
        //Set new Annotation
        let annotation = MyPointAnnotation()
        annotation.coordinate = loc.coordinate!
        
        if isMisterX{
            annotation.title = "Mister X"
            annotation.subtitle = "Mister X um \(newdate)"
            annotation.pinTintColor = .red
        }else{
            annotation.title = loc.name
            annotation.subtitle = "\(loc.name) um \(newdate)"
            annotation.pinTintColor = .green
        }
        mapView.addAnnotation(annotation)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkLocationAuthorizationStatus()
        lookAtMap = true
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

class MyPointAnnotation : MKPointAnnotation {
    var pinTintColor: UIColor?
}
