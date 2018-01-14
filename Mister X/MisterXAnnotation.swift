//
//  MisterXAnnotation.swift
//  Mister X
//
//  Created by admin on 14.01.18.
//  Copyright © 2018 Praktikum. All rights reserved.
//

import UIKit
import MapKit

class MisterXAnnotation: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var gameCode: String?
    
    init(coordinate: CLLocationCoordinate2D, gameCode: String) {
        self.coordinate = coordinate
        self.gameCode = gameCode
    }
}
