//
//  LocationManager.swift
//  Map
//
//  Created by Maxim Anisimov on 03.11.2019.
//  Copyright © 2019 alekseyrobul. All rights reserved.
//

import UIKit
import CoreLocation

final class LocationManager: NSObject, CLLocationManagerDelegate {
    
    static var shared = LocationManager()
    
    var currentLocation: CLLocationCoordinate2D?
    
    private let locationManager = CLLocationManager()
    private var isLocationUpdatingStarted = false
    
    func setupLocationManager() {
        
        locationManager.delegate = self
//        locationManager.distanceFilter = kCLDistanceFilterNone//1000 // 1 km
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.showsBackgroundLocationIndicator = true
//        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.requestAlwaysAuthorization()
        runLocationUpdate()
    }
    
    // MARK: Delegate
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            self.startUpdatingLocation()
        }
    }
    
    // MARK: Funcs
    func runLocationUpdate() {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            self.locationManager.requestAlwaysAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            self.startUpdatingLocation()
        default:
            break
        }
    }
    
    func startUpdatingLocation() {
        guard locationManager.delegate != nil else { return }
        
        if !isLocationUpdatingStarted {
            locationManager.startUpdatingLocation()
            locationManager.startMonitoringSignificantLocationChanges()
            isLocationUpdatingStarted = true
        }
    }
    
    
    var coordinate: CLLocationCoordinate2D?
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        if let location = locations.last {
            let data : Data = "\(location)".data(using: .utf8) ?? Data()
            saveDataToDocuments(data)
            print(location)
            
        }
        
        
        
        //		if isLocationUpdatingStarted {
        //			if self.currentLocation == nil {
        //				NotificationCenter.default.post(name: .didUpdateLocations, object: location)
        //			}
        //			coordinate = location.coordinate
        //
        //		}
        //
        //		self.currentLocation = location.coordinate
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func saveDataToDocuments(_ data: Data, jsonFilename: String = "Locations.JSON") {
        
        let jsonFileURL = getDocumentsDirectory().appendingPathComponent(jsonFilename)
        //            if FileManager.default.fileExists(atPath: jsonFileURL.absoluteURL.path()){
        print(jsonFileURL)
        do {
            try data.write(to: jsonFileURL)
        } catch {
            print("Error = \(error)")
        }
        //            }
    }
    
    @objc func protectedDataAvailableNotification(_ notification: Notification) {
        NotificationCenter.default.removeObserver(self, name: UIApplication.protectedDataDidBecomeAvailableNotification, object: nil)
        
    }
    
    
    
}

extension NSNotification.Name {
    static let didUpdateLocations = NSNotification.Name("didUpdateLocations")
    static let reloadFavoritePlace = NSNotification.Name("reloadFavoritePlace")
    static let reloadExploreDetails = NSNotification.Name("reloadExploreDetails")
    static let reloadAccountDetails = NSNotification.Name("reloadAccountDetails")
    static let reloadBadgeOnHomeScreen = NSNotification.Name("reloadBadgeOnHomeScreen")
    static let openNewFavoriteView = NSNotification.Name("openNewFavoriteView")
}
