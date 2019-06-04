//
//  Pin.swift
//  Virtual Tourist
//
//  Created by Bahi El Feky on 5/11/19.
//  Copyright © 2019 Bahi El Feky. All rights reserved.
//

import Foundation
import MapKit

extension Pin: MKAnnotation {
    public var coordinate: CLLocationCoordinate2D {
        let latDegrees = CLLocationDegrees(lat)
        let longDegrees = CLLocationDegrees(long)
        return CLLocationCoordinate2D(latitude: latDegrees, longitude: longDegrees)
    }
}
