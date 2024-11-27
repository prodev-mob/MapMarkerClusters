//
//  GooglePlaceModel.swift
//  clusterUser
//
//  Created by DREAMWORLD on 19/11/24.
//

import Foundation

let googleMapsApiKey = "YOUR_GOOGLE_API_KEY"

struct PlacesResponse: Decodable {
    let candidates: [Place]
}

struct Place: Decodable {
    let name: String
    let formatted_address: String?
    let geometry: Geometry
}

struct Geometry: Decodable {
    let location: Location
}

struct Location: Decodable {
    let lat: Double
    let lng: Double
}
