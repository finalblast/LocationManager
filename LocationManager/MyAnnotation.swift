//
//  MyAnnotation.swift
//  LocationManager
//
//  Created by Nam (Nick) N. HUYNH on 3/24/16.
//  Copyright (c) 2016 Enclave. All rights reserved.
//

import UIKit
import MapKit

func == (left: PinColor, right: PinColor) -> Bool {
    
    return left.rawValue == right.rawValue
    
}

enum PinColor: String {
    
    case Blue = "Blue"
    case Red = "Red"
    
    func toPinColor() -> MKPinAnnotationColor {
        
        switch self {
            
        case .Red:
            return MKPinAnnotationColor.Red
            
        default:
            return MKPinAnnotationColor.Purple
            
        }
        
    }
    
}

class MyAnnotation: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var title: String!
    var subTitle: String!
    var pinColor: PinColor!
    
    init(coordinate: CLLocationCoordinate2D, title: String, subTitle: String, pinColor: PinColor) {
        
        self.coordinate = coordinate
        self.title = title
        self.subTitle = subTitle
        self.pinColor = pinColor
        super.init()
        
    }
    
    convenience init(coordinate: CLLocationCoordinate2D, title: String, subTitle: String) {
        
        self.init(coordinate: coordinate, title: title, subTitle: subTitle, pinColor: PinColor.Blue)
        
    }
    
}
