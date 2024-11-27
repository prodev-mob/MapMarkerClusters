//
//  POIItem.swift
//  GoogleMapsClustersTest
//
//  Created by ****** ****** on 03.11.2020.
//

import GoogleMaps

class POIItem: NSObject, GMUClusterItem {
    
    var position: CLLocationCoordinate2D
    var marker: GMSMarker?
    var name: String?

    init(position: CLLocationCoordinate2D, marker: GMSMarker) {
        self.position = position
        self.marker = marker
  }
}

