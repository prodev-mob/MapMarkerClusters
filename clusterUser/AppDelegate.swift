//
//  AppDelegate.swift
//  clusterUser
//
//  Created by DREAMWORLD on 07/08/23.
//

import UIKit
import GoogleMaps
@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    let googleMapsApiKey = "your_map_api_key"
    let locationManager = CLLocationManager()
    var arrTime: [String] = []
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        GMSServices.provideAPIKey(googleMapsApiKey)
       
        locationManager.requestAlwaysAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
//        locationManager.startUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()
        //and then
        
        if launchOptions?[UIApplication.LaunchOptionsKey.location] != nil {
            locationManager.startUpdatingLocation()
            // get the current date and time
            let currentDateTime = Date()

            // initialize the date formatter and set the style
            let formatter = DateFormatter()
            formatter.timeStyle = .medium
            formatter.dateStyle = .long

            if let time = UserDefaults.standard.value(forKey: "lastDateTime") as? [String] {
                self.arrTime = time
            }
            // get the date time String from the date object
            let time = formatter.string(from: currentDateTime) // October 8, 2016 at 10:48:53 PM
            self.arrTime.append(time)
            let stringRepresentation = self.arrTime.joined(separator: "\n")
            UserDefaults.standard.setValue( self.arrTime, forKey: "lastDateTime")
            let data : Data = stringRepresentation.data(using: .utf8) ?? Data()
            self.saveDataToDocuments(data)
        }
        
        return true
    }
    

    
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

extension AppDelegate : CLLocationManagerDelegate{
   
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if (status == CLAuthorizationStatus.authorizedAlways) {
            self.locationManager.startUpdatingLocation()
            self.locationManager.startMonitoringSignificantLocationChanges()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard locations.last != nil else { return }
        
        if let location = locations.last {
            CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in

                guard let placemark = placemarks?.first else {
                    let errorString = error?.localizedDescription ?? "Unexpected Error"
                    print("Unable to reverse geocode the given location. Error: \(errorString)")
                    return
                }

                let reversedGeoLocation = ReversedGeoLocation(with: placemark)
                print(reversedGeoLocation.formattedAddress)
//                let data : Data = "\(reversedGeoLocation.formattedAddress)".data(using: .utf8) ?? Data()
                
          
////                let data : Data = stringRepresentation.data(using: .utf8) ?? Data()
//                self.saveDataToDocuments(data)
                // Apple Inc.,
                // 1 Infinite Loop,
                // Cupertino, CA 95014
                // United States
            }

            print(location)
        }
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
    }
}
