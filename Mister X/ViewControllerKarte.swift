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
    var mfc = MapFirebaseCom(updateTime: 30.0)
    var myLocation = UserLocationStruct()
    var lookAtMap : Bool = true
    var isHistoryShown = false
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
    
    var misterXPositions = [Dictionary<String, Any>]()
    
    //var positions = [Dictionary<String, Any>]()
   

    //Muss noch komplett überarbeitet werden. Daten müssen später aus Firebase kommen
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
        
        //Start MisterX Loc Observer
        mfc.getMisterX(map: mapView)
        
        //Am I Mister X?
        let defaults = UserDefaults.standard
        let misterX = defaults.string(forKey: "misterX")
        var currentGame = defaults.string(forKey: "gameCode")
        
        
        let uid = defaults.string(forKey: "uid")
        var ref: DatabaseReference
        ref = Database.database().reference()
        
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
        //TODO: Timer läuft nicht immer. Bsp: Wenn App im Hintergrund ist
        //Alle x Sekunden wird updateMisterXPosition aufgerufen
        //let xSekunden: Double = 10.0
        //var misterXTimer = Timer.scheduledTimer(timeInterval: xSekunden, target: self, selector: #selector(ViewControllerKarte.updateMisterXPosition), userInfo: nil, repeats: true)
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
    
    //TODO: Der Code wird auch im observer benutzt müsste noch refactored werden
    func setAnnotation(loc : UserLocationStruct, title : String) {
        //Remove Annotations
        mapView.removeAnnotations(mapView.annotations)
        
        //Set new Annotation
        let annotation = MKPointAnnotation()
        annotation.coordinate = loc.coordinate!
        annotation.title = title
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        let newdate = dateFormatter.string(from: loc.timestamp!)
        annotation.subtitle = "\(title) um \(newdate)"
        mapView.addAnnotation(annotation)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        //let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        if let location = locations.last {
            myLocation.coordinate = location.coordinate
            myLocation.timestamp = location.timestamp
            if lookAtMap{
                let region = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
                self.mapView.setRegion(region, animated: true)
                lookAtMap = false
            }
            let defaults = UserDefaults.standard
            let misterX = defaults.string(forKey: "misterX")
            if misterX! == "y" {
                if mfc.updateLocation(location: myLocation){
                    setAnnotation(loc: mfc.getMisterXLocation(), title: "Me MisterX")
                }
            }
        }
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
