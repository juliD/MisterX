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

class ViewControllerKarte: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    
    @IBOutlet var button_x: UIButton!
    @IBAction func button_x(_ sender: UIButton) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = (locationManager.location?.coordinate)!
        annotation.title = "Mister X"
        annotation.subtitle = "Position von Mister X"
        mapView.addAnnotation(annotation)
    }
    @IBOutlet var button_ich: UIButton!
    @IBAction func button_ich(_ sender: UIButton) {
        locationManager.startUpdatingLocation()
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
        doblur(button_x)
        
        //mapView.setUserTrackingMode(.follow, animated: true)
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest//kCLLocationAccuracyNearestTenMeters
            //locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
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
