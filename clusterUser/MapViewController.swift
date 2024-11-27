//
//  MapViewController.swift
//  clusterUser
//
//  Created by DREAMWORLD on 08/08/23.
//

import GoogleMaps
import UIKit
import GooglePlaces
import Alamofire
import SwiftyJSON

class MapViewController: UIViewController {
    
    @IBOutlet weak var viewSearch: UIView!
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var tblPlaces: UITableView!
    
    var arrPlace = [Place]()
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
        setUpSearchTxt()
        for location in locationsArray {
            createClusters(location: location)
        }
        self.setupLocationManager()
        
        getRoute(from: CLLocationCoordinate2D(latitude: 37.785834, longitude: -122.406417), to: CLLocationCoordinate2D(latitude: 37.806643, longitude: -122.475044))
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.locationManager.requestWhenInUseAuthorization()
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
        
        mapView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
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
        view.bringSubviewToFront(viewSearch)
        view.bringSubviewToFront(tblPlaces)
    }
    
    func setUpSearchTxt() {
        txtSearch.autocorrectionType = .no
        txtSearch.addTarget(self, action: #selector(textfieldDidChange), for: .editingChanged)
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
        let clusterIconImage5 = UIImage(named: "clust_5")
        let clusterIconImage10 = UIImage(named: "clust_10")
        let clusterIconImage100 = UIImage(named: "clust_100")
        let imagesArray = [clusterIconImage5, clusterIconImage10, clusterIconImage100]
        let iconGenerator = GMUDefaultClusterIconGenerator(buckets: [5, 10, 100], backgroundImages: imagesArray as! [UIImage])
        let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
        
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

    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if let cluster = marker.userData as? GMUCluster {
            var bounds = GMSCoordinateBounds()
            for item in cluster.items {
                bounds = bounds.includingCoordinate(item.position)
            }
            let update = GMSCameraUpdate.fit(bounds, withPadding: 10)
            mapView.animate(with: update)
            return true
        }
        return true
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

extension MapViewController {
    @objc func textfieldDidChange(_ textfield: UITextField) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.reload), object: nil)
        self.perform(#selector(self.reload), with: nil, afterDelay: 1.0)
    }
    
    @objc func reload() {
        searchPlace(query: txtSearch.text ?? "") { result in
            switch result {
            case .success(let places):
                print("Places Found: \(places)")
                self.arrPlace.removeAll()
                for place in places {
                    self.arrPlace.append(place)
                    print("Name: \(place.name), Address: \(place.formatted_address ?? "No Address")")
                }
                
                DispatchQueue.main.async {
                    self.tblPlaces.isHidden = self.arrPlace.count == 0 ? true : false
                    self.tblPlaces.reloadData()
                }
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    //Google Place Search API
    func searchPlace(query: String, completion: @escaping (Result<[Place], Error>) -> Void) {
        let baseURL = "https://maps.googleapis.com/maps/api/place/findplacefromtext/json"
        let query = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "\(baseURL)?input=\(query)&inputtype=textquery&fields=name,geometry,formatted_address&key=\(googleMapsApiKey)"
        print(urlString)
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "InvalidURL", code: -1, userInfo: nil)))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "NoData", code: -1, userInfo: nil)))
                return
            }
            
            do {
                let result = try JSONDecoder().decode(PlacesResponse.self, from: data)
                completion(.success(result.candidates))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    func getRoute(from origin: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) {
        let originString = "\(origin.latitude),\(origin.longitude)"
        let destinationString = "\(destination.latitude),\(destination.longitude)"
        
        // Construct URL for Google Directions API
        let urlString = "https://maps.googleapis.com/maps/api/directions/json?origin=\(originString)&destination=\(destinationString)&mode=driving&key=\(googleMapsApiKey)"
        
        guard let url = URL(string: urlString) else { return }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error with URLSession data task: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else { return }
            
            do {
                let json = try JSON(data: data)
                let routes = json["routes"].arrayValue
                
                for route in routes {
                    if let overviewPolyline = route["overview_polyline"].dictionary,
                       let points = overviewPolyline["points"]?.string {
                        
                        // Create a GMSPath from the encoded polyline points
                        let path = GMSPath(fromEncodedPath: points)
                        let polyline = GMSPolyline(path: path)
                        
                        // Customize the polyline's appearance
                        polyline.strokeColor = .systemBlue
                        polyline.strokeWidth = 5
                        
                        // Add the polyline to the map
                        DispatchQueue.main.async {
                            polyline.map = self.googleMapsView
                        }
                    }
                }
            } catch {
                print("Error parsing the JSON response with SwiftyJSON: \(error.localizedDescription)")
            }
        }
        task.resume()
    }
}

extension MapViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrPlace.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddressTableViewCell", for: indexPath) as! AddressTableViewCell
        cell.lblAddress.text = "Address :- \(arrPlace[indexPath.row].formatted_address ?? "")"
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
