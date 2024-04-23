//
//  MapViewController.swift
//  clusterUser
//
//  Created by DREAMWORLD on 08/08/23.
//

import GoogleMaps
import UIKit

class MapViewController: UIViewController {

    var googleMapsView: GMSMapView?
    var clusterManager: GMUClusterManager?
    var locationManager = CLLocationManager()
    var locationsArray = [
        CLLocationCoordinate2D(latitude: 37.785834, longitude: -122.406417),
        CLLocationCoordinate2D(latitude: 37.806643, longitude: -122.475044),
        CLLocationCoordinate2D(latitude: 37.822838, longitude: -122.478467),
        CLLocationCoordinate2D(latitude: 37.875995, longitude: -122.511365),
        CLLocationCoordinate2D(latitude: 37.902576, longitude: -122.516120),
        CLLocationCoordinate2D(latitude: 37.958061, longitude: -122.508434),
        CLLocationCoordinate2D(latitude: 37.958332, longitude: -122.503452),
        CLLocationCoordinate2D(latitude: 37.932553, longitude: -122.411284),
        CLLocationCoordinate2D(latitude: 37.867035, longitude: -122.303865),
        CLLocationCoordinate2D(latitude: 37.822374, longitude: -122.318795),
        CLLocationCoordinate2D(latitude: 37.822103, longitude: -122.329102),
        CLLocationCoordinate2D(latitude: 37.814509, longitude: -122.358991),
        CLLocationCoordinate2D(latitude: 37.811255, longitude: -122.365175),
        CLLocationCoordinate2D(latitude: 37.785333, longitude: -122.406074),
        
        
        CLLocationCoordinate2D(latitude: 37.768885, longitude: -122.476695),
        CLLocationCoordinate2D(latitude: 37.750971, longitude: -122.476008),
        CLLocationCoordinate2D(latitude: 37.764015, longitude: -122.461971),
        CLLocationCoordinate2D(latitude: 37.745529, longitude: -122.452653),
        CLLocationCoordinate2D(latitude: 37.739613, longitude: -122.477101),
        CLLocationCoordinate2D(latitude: 37.765401, longitude: -122.484316),
        CLLocationCoordinate2D(latitude: 37.733640, longitude: -122.492217),
        CLLocationCoordinate2D(latitude: 37.738527, longitude: -122.469542),
        CLLocationCoordinate2D(latitude: 37.743686, longitude: -122.455457),
        CLLocationCoordinate2D(latitude: 37.771372, longitude: -122.422819),
        CLLocationCoordinate2D(latitude: 37.668355, longitude: -122.466136),
        CLLocationCoordinate2D(latitude: 37.632104, longitude: -122.460860),
        CLLocationCoordinate2D(latitude: 37.633736, longitude: -122.438185),
        CLLocationCoordinate2D(latitude: 37.623947, longitude: -122.457424),
        
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
        setupClusters()
        
        for location in locationsArray {
            createClusters(location: location)
        }
        self.setupLocationManager()
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.locationManager.requestWhenInUseAuthorization()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
//        if locationManager.authorizationStatus == .authorizedWhenInUse {
//            locationManager.stopUpdatingLocation()
//            locationManager.stopMonitoringSignificantLocationChanges()
//        }
    }
    
    func setupMapView() {
        ///Map View
        ///
        let camera = GMSCameraPosition.camera(withLatitude: 37.7858, longitude: -122.4064, zoom: 12.0)
        googleMapsView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        guard let mapView = googleMapsView else { return }
        self.view.addSubview(mapView)
        
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.isMyLocationEnabled = false
        
        mapView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0).isActive = true
        mapView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
        mapView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).isActive = true
        mapView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
        
        mapView.animate(to: camera)
        
        
        let lastUpdatedlabel = UILabel()
        lastUpdatedlabel.translatesAutoresizingMaskIntoConstraints = false
        lastUpdatedlabel.numberOfLines = 0
        lastUpdatedlabel.lineBreakMode = .byTruncatingHead
        lastUpdatedlabel.textColor = .black
        self.view.addSubview(lastUpdatedlabel)
        lastUpdatedlabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0).isActive = true
        lastUpdatedlabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
        lastUpdatedlabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).isActive = true
        lastUpdatedlabel.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
        
        if let time = UserDefaults.standard.value(forKey: "lastDateTime") as? [String] {
            lastUpdatedlabel.text = time.joined(separator: "\n")
        }
       
        
    }
    
    //Setup Location Manager
    func setupLocationManager() {
        locationManager.requestAlwaysAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.showsBackgroundLocationIndicator = true
        locationManager.pausesLocationUpdatesAutomatically = false
       

    }
    
    func placeMarker(location: CLLocationCoordinate2D) {
        googleMapsView?.clear()
        let marker = GMSMarker(position: CLLocationCoordinate2DMake(location.latitude, location.longitude))
        let icon = UIImage(named: "MapPoint")?.withRenderingMode(.alwaysTemplate)
        let markerView = UIImageView(image: icon)
        marker.iconView = markerView
        marker.tracksViewChanges = true
        marker.map = googleMapsView
    }
    
    
}

extension MapViewController: GMUClusterManagerDelegate, GMSMapViewDelegate, GMUClusterIconGenerator, GMUClusterRendererDelegate {
    func icon(forSize size: UInt) -> UIImage! {
        return UIImage(named: "MapPoint")
    }
    
    func setupClusterManager() {
        // Register self to listen to both GMUClusterManagerDelegate and GMSMapViewDelegate events.
        // Set up the cluster manager with the supplied icon generator and renderer.
        let clusterIconImage5 = UIImage(named: "clust_5")
        let clusterIconImage10 = UIImage(named: "clust_10")
        let clusterIconImage100 = UIImage(named: "clust_100")
        let imagesArray = [clusterIconImage5, clusterIconImage10, clusterIconImage100]
        let iconGenerator = GMUDefaultClusterIconGenerator(buckets: [5, 10, 100], backgroundImages: imagesArray as! [UIImage])
//        let iconGenerator = MapClusterIconGenerator()
        let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
        
        // Generate and add random items to the cluster manager.
        // Call cluster() after items have been added to perform the clustering and rendering on map.
        guard let mapView = googleMapsView else { return }
        let renderer = GMUDefaultClusterRenderer(mapView: mapView, clusterIconGenerator: iconGenerator)
        renderer.delegate = self
        clusterManager = GMUClusterManager(map: mapView, algorithm: algorithm, renderer: renderer)
        clusterManager?.cluster()
    }
    
    func setupClusters() {
        setupClusterManager()
        clusterManager?.setDelegate(self, mapDelegate: self)
    }
    
    func createClusters(location: CLLocationCoordinate2D) {
        let marker = GMSMarker(position: location)
        let item = POIItem(position: location, marker: marker)
        clusterManager?.add(item)
        clusterManager?.cluster()
    }
    
    func renderer(_ renderer: GMUClusterRenderer, willRenderMarker marker: GMSMarker) {
        if marker.userData as? POIItem != nil {
            // Here we can set user's profile by using model
            let icon = UIImage(named: "user")
            marker.iconView = UIImageView(image: icon)
        }
    }
}

//MARK: Location manager delegate
extension MapViewController : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            self.placeMarker(location: location.coordinate)
            clusterManager?.cluster()
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            break
        case .restricted:
            break
        case .denied:
            locationManager.stopUpdatingLocation()
            break
        case .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        case .authorizedAlways:
            locationManager.startUpdatingLocation()
//            locationManager.startMonitoringSignificantLocationChanges()
        default:
            
            break
        }
    }
}


class MapClusterIconGenerator: GMUDefaultClusterIconGenerator {

    
    override func icon(forSize size: UInt) -> UIImage {
        
        let image = textToImage(drawText: String(size) as NSString,
                                inImage: setImage(size: Int(size)) ?? UIImage(),
                                font: UIFont.boldSystemFont(ofSize: 14))
        return image
    }

    private func setImage(size: Int) -> UIImage? {
        if size < 10 {
            return UIImage(named: "clust_5")
        } else if size < 100 && size >= 10{
            return UIImage(named: "clust_10")
        }else if size >= 100{
            return UIImage(named: "clust_100")
        }
        return nil
    }
    private func textToImage(drawText text: NSString, inImage image: UIImage, font: UIFont) -> UIImage {

        UIGraphicsBeginImageContext(image.size)
        image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))

        let textStyle = NSMutableParagraphStyle()
        textStyle.alignment = NSTextAlignment.center
        let textColor = UIColor.white
        let attributes=[
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.paragraphStyle: textStyle,
            NSAttributedString.Key.foregroundColor: textColor]

        // vertically center (depending on font)
        let textH = font.lineHeight
        let textY = ((image.size.height-textH)/2) - 5
        let textRect = CGRect(x: 0, y: textY, width: image.size.width, height: textH)
        text.draw(in: textRect.integral, withAttributes: attributes)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result!
    }

}
