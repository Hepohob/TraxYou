//
//  MKGPX.swift
//  TraxYou
//
//  Created by Aleksei Neronov on 03.01.17.
//  Copyright © 2017 Aleksei Neronov. All rights reserved.
//

import MapKit

extension GPX.Waypoint : MKAnnotation {
    var coordinate : CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    var title: String? { return name }
    var subtitle: String? { return info }
}
