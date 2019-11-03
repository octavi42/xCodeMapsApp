//
//  MapViewController.swift
//  xCodeMaps
//
//  Created by Cristea Octavian on 11/10/2019.
//  Copyright © 2019 Cristea Octavian. All rights reserved.
//

import UIKit
import MapKit
import SwiftyJSON

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet var navigationBarController: CardViewController!
    @IBOutlet var directionGoOutlet: UIButton!
    
    
    let cardHeight:CGFloat = 70
    let cardWidth:CGFloat = 320
    
    var drawedDriection: Bool = false
    var didSelectAnnotation: Bool = false
    
    var venues = [Venue]()

    func fetchData()
    {
        let fileName = Bundle.main.path(forResource: "Venues", ofType: "json")
        let filePath = URL(fileURLWithPath: fileName!)
        var data: Data?
        do {
            data = try Data(contentsOf: filePath, options: Data.ReadingOptions(rawValue: 0))
        } catch let error {
            data = nil
            print("Report error \(error.localizedDescription)")
        }

        if let jsonData = data {
            if let json = try? JSON(data: jsonData) {
                if let venueJSONs = json["response"]["venues"].array {
                    for venueJSON in venueJSONs {
                        if let venue = Venue.from(json: venueJSON) {
                            self.venues.append(venue)
                        }
                    }
                }
            }
        }
        
        //print(json)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let initialLocation = CLLocation(latitude: 46.2254829, longitude: 24.7946780)
        zoomMapOn(location: initialLocation)
        
        
        
//        let sampleStarbucks = Venue(title: "Starbucks Imagination", locationName: "imagination street", coordinate: CLLocationCoordinate2D(latitude: 46.2254829, longitude: 24.7946780))
//
//        mapView.addAnnotation(sampleStarbucks)
        
        mapView.delegate = self
        
        fetchData()
        mapView.addAnnotations(venues)
        
        //navigationBar.layer.cornerRadius = 28
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        selectAnAnnotation()
        directionToPin()
        
        checkLocationServicesAuthentificationStatus()
    }
    
    private let regionRadius: CLLocationDistance = 100
    
    func zoomMapOn(location: CLLocation){
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius * 2.0, longitudinalMeters: regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    var locationManager = CLLocationManager()
    
    func checkLocationServicesAuthentificationStatus(){
        locationManager.delegate = self
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            mapView.showsUserLocation = true
            locationManager.startUpdatingLocation()
        } else {
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
    }
    
    //selecting annotaion
    
    func selectAnAnnotation() { self.mapView.selectAnnotation(self.mapView.annotations[1], animated: true)
    }
    
    //selecting annotation -
    
    var currentPlacemark: CLPlacemark?
    
    func printSomething() {
        print("printingSomething")
    }
    
    
    @IBAction func goDirections(_ sender: Any) {
        directionToPin()
    }
    
    func directionToPin() {
//
//        print("sbfdskbd")
//        print("drawedDriection\(self.drawedDriection)")
//        print("didSelectAnnotation\(self.didSelectAnnotation)")
        
        guard let currentPlacemark = currentPlacemark else {
            print("Error, the current Placemark is: \(self.currentPlacemark)")
            return
        }
        
        //print("dgvwedsvhjgdfskfbdvfjbvhdfbjvjvbvjdkbhcbvnsd")
        
        let directionRequest = MKDirections.Request()
        let destinationPlacemark = MKPlacemark(placemark: currentPlacemark)
        
        directionRequest.source = MKMapItem.forCurrentLocation()
        directionRequest.destination = MKMapItem(placemark: destinationPlacemark)
        directionRequest.transportType = .walking
        
        //calculate route
        let directions = MKDirections(request: directionRequest)
        directions.calculate{ (directionsResponse, error) in
            guard let directionsResponse = directionsResponse else{
                if let error = error {
                    print("error getting directions: \(error.localizedDescription)")
                }
                return
            }
            
            let route = directionsResponse.routes[0]
            //self.mapView.removeOverlays(self.mapView.overlays)
            
            
            if self.drawedDriection == false{
                self.drawedDriection = true
                if self.didSelectAnnotation == true {
                    self.mapView.addOverlay(route.polyline, level: .aboveRoads)
                    self.navigationBarController.directionButtonOutlet.setImage(UIImage(named: "navigationBarDirectionButtonRed")?.withRenderingMode(.alwaysOriginal), for: .normal)
                            //directionButtonColor = "red"
                            //self.delegateChangeColors?.changeDirectionButtonColor()
                    let routeRect = route.polyline.boundingMapRect
                    self.mapView.setRegion(MKCoordinateRegion(routeRect), animated: true)
                }
            } else {
                self.drawedDriection = false
                self.mapView.removeOverlays(self.mapView.overlays)
                if self.didSelectAnnotation == true {
                    self.navigationBarController.directionButtonOutlet.setImage(UIImage(named: "navigationBarDirectionButtonBlue")?.withRenderingMode(.alwaysOriginal), for: .normal)
                            //directionButtonColor = "blue"
                            //self.delegateChangeColors?.changeDirectionButtonColor()
                } else {
                    self.navigationBarController.directionButtonOutlet.setImage(UIImage(named: "navigationBarDirectionButtonGray")?.withRenderingMode(.alwaysOriginal), for: .normal)
                            //directionButtonColor = "gray"
                            //self.delegateChangeColors?.changeDirectionButtonColor()
                }
            }
        }
    }
    
}

extension MapViewController : CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //let location = locations.last!
        self.mapView.showsUserLocation = true
        //zoomMapOn(location: location)
    }
}

extension MapViewController: MKMapViewDelegate
{
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
    {
        if let annotation = annotation as? Venue{
            let identifier = "pin"
            var view: MKAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView {
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: -5)
                view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure) as UIView
                let rightButton = UIButton(type: .detailDisclosure)
                view.rightCalloutAccessoryView = rightButton
            }
            
            return view
        }
        
        return nil
    }
        
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
//        didSelectAnnotation = true
//        if drawedDriection == false{
//            navigationBarController.directionButtonOutlet.setImage(UIImage(named: "navigationBarDirectionButtonBlue")?.withRenderingMode(.alwaysOriginal), for: .normal)
//                    //directionButtonColor = "blue"
//                    //self.delegateChangeColors?.changeDirectionButtonColor()
//        }
        
        if let location = view.annotation as? Venue {
            print("ahskahukj")
            self.currentPlacemark = MKPlacemark(coordinate: location.coordinate)
            print("current placemark: \(currentPlacemark)")
            print("my current: \(view.annotation as? MKPointAnnotation)")
            print("mapview annotations: \(self.mapView.annotations)")
            
        }
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        
        print("asta era")
        didSelectAnnotation = false
        if drawedDriection == false{
             navigationBarController.directionButtonOutlet.setImage(UIImage(named: "navigationBarDirectionButtonGray")?.withRenderingMode(.alwaysOriginal), for: .normal)
                    //directionButtonColor = "gray"
                    //self.delegateChangeColors?.changeDirectionButtonColor()
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        
        renderer.strokeColor = UIColor(red:0.05, green:0.31, blue:0.50, alpha:1.0)
        renderer.lineWidth = 4.0
        
        return renderer
    }
}

