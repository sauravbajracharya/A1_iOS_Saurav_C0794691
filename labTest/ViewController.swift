//
//  ViewController.swift
//  labTest
//
//  Created by Saurav Bajracharya on 2021-05-16.
//  Copyright © 2021 Saurav Bajracharya. All rights reserved.
//

import UIKit
import MapKit


class ViewController: UIViewController, CLLocationManagerDelegate{

    
    
    @IBOutlet weak var map: MKMapView!
    
    @IBOutlet weak var directionBtn: UIButton!
    
    var places : [CLLocationCoordinate2D] = []
     var polygon: MKPolygon?
    
    var longitude: CLLocationDegrees = 0.0
    var latitude: CLLocationDegrees = 0.0
    
    // create location manager
    var locationMnager = CLLocationManager()
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        map.delegate = self
        
        directionBtn.isHidden = true
        
        
        // we assign the delegate property of the location manager to be this class
        locationMnager.delegate = self
        
        // we define the accuracy of the location
        locationMnager.desiredAccuracy = kCLLocationAccuracyBest
        
        // rquest for the permission to access the location
        locationMnager.requestWhenInUseAuthorization()
        
        // start updating the location
        locationMnager.startUpdatingLocation()
        
        
         addTrippleTap()

    }
    
    
//    func addAnnotationforPlaces() {
//        map.addAnnotations(customPlaces as! [MKAnnotation])
//
//        let overlays = customPlaces.map
//    }

       func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
   
            let userLocation = locations[0]
            
            latitude = userLocation.coordinate.latitude
            longitude = userLocation.coordinate.longitude
            
        
        displayLocation(latitude: latitude, longitude: longitude, title: "Your location", subtitle: "you are here")
        }
    
    
    
    
   func displayLocation(latitude: CLLocationDegrees,
                          longitude: CLLocationDegrees,
                          title: String,
                          subtitle: String) {
    
    
         // 2nd step - define span
         let latDelta: CLLocationDegrees = 0.05
         let lngDelta: CLLocationDegrees = 0.05
         
         let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lngDelta)
    
         // 3rd step is to define the location
         let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
         // 4th step is to define the region
         let region = MKCoordinateRegion(center: location, span: span)
         
         // 5th step is to set the region for the map
         map.setRegion(region, animated: true)
         
         // 6th step is to define annotation
         let annotation = MKPointAnnotation()
         annotation.title = title
         annotation.subtitle = subtitle
         annotation.coordinate = location
         map.addAnnotation(annotation)
     }

    
    //MARK: - double tap func
     func addTrippleTap() {
         let doubleTap = UITapGestureRecognizer(target: self, action: #selector(trippleTapAction))
         doubleTap.numberOfTapsRequired = 3
         map.addGestureRecognizer(doubleTap)
         
     }
    
      @objc func trippleTapAction(sender: UITapGestureRecognizer) {
            
            // add annotation
            let touchPoint = sender.location(in: map)
            let coordinate = map.convert(touchPoint, toCoordinateFrom: map)
           
    
            let annotation = MKPointAnnotation()
        
        if places.count == 1{
            annotation.title = "A"
            annotation.coordinate = coordinate
            map.addAnnotation(annotation)
        
            places.append(coordinate)
        } else if places.count == 2 {
            annotation.title = "B"
            annotation.coordinate = coordinate
            map.addAnnotation(annotation)
                  
            places.append(coordinate)
        } else {
            annotation.title = "C"
            annotation.coordinate = coordinate
            map.addAnnotation(annotation)
                  
            places.append(coordinate)
        }

        if places.count == 3 {
            addPolygon()
        }
        
        if places.count == 4{
            map.removeOverlays(map.overlays)
            map.removeAnnotations(map.annotations)
           places = []
        
        }
            directionBtn.isHidden = false
        }
     
    
    func addPolygon() {
        print(places.count)
        print(places)
        let coordinates = places.map{$0};
        let polygon = MKPolygon(coordinates: coordinates, count: coordinates.count)
        map.addOverlay(polygon)
        
    }
    
    func removeAllMarkers()
       {
           self.directionBtn.isHidden = true
           removeMarkers()
           removeOverlays()
       }
    
    
    func removeMarkers() {
           for annotation in map.annotations {
               map.removeAnnotation(annotation)
           }
       }
    
    func removeOverlays() {
        for overlay in map.overlays
        {
            map.removeOverlay(overlay)
        }
    }
    
    @IBAction func drawRoute(_ sender: UIButton) {
        
        removeOverlays()
        
        self.directionBtn.isHidden = true


           for place in places{
               
               let sourcePlaceMark = MKPlacemark(coordinate: CLLocationCoordinate2D.init(latitude:places[0].latitude, longitude:places[0].longitude))
               let destinationPlaceMark = MKPlacemark(coordinate: CLLocationCoordinate2D.init(latitude:place.latitude, longitude:place.longitude))
               
               // request a direction
               let directionRequest = MKDirections.Request()
               
               // assign the source and destination properties of the request
               directionRequest.source = MKMapItem(placemark: sourcePlaceMark)
               directionRequest.destination = MKMapItem(placemark: destinationPlaceMark)
               
               // transportation type
               directionRequest.transportType = .automobile
               
               // calculate the direction
               let directions = MKDirections(request: directionRequest)
                   directions.calculate { (response, error) in
                   guard let directionResponse = response else {return}
                   // create the route
                   let route = directionResponse.routes[0]
                   // drawing a polyline
                   self.map.addOverlay(route.polyline, level: .aboveRoads)
                   
                    
                 
                   // define the bounding map rect
                   let rect = route.polyline.boundingMapRect
                   self.map.setVisibleMapRect(rect, edgePadding: UIEdgeInsets(top: 100, left: 100, bottom: 100, right: 100), animated: true)
                    
                    
              
                  }
            }
        
    }
    
}

extension ViewController: MKMapViewDelegate {
    
    

    //MARK: - viewFor annotation method
      func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

          if annotation is MKUserLocation {
              return nil
          }

          switch annotation.title {
          case "my location":
              let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "MyMarker")
              annotationView.markerTintColor = UIColor.blue
              return annotationView
          case "A":
              let annotationView = map.dequeueReusableAnnotationView(withIdentifier: "customPin") ?? MKPinAnnotationView()
              annotationView.image = UIImage(named: "ic_place_2x")
              annotationView.canShowCallout = true
              annotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
              return annotationView
         case "B":
            let annotationView = map.dequeueReusableAnnotationView(withIdentifier: "customPin") ?? MKPinAnnotationView()
            annotationView.image = UIImage(named: "ic_place_2x")
            annotationView.canShowCallout = true
            annotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            return annotationView
         case "C":
            let annotationView = map.dequeueReusableAnnotationView(withIdentifier: "customPin") ?? MKPinAnnotationView()
            annotationView.image = UIImage(named: "ic_place_2x")
            annotationView.canShowCallout = true
            annotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            return annotationView
          default:
              return nil
          }
      }

    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
//        guard let annotation = view.annotation as? place, let title = annotation.title else { return }
        
        let userlocation = CLLocation(latitude: latitude, longitude: longitude)
                  
    
        let locA = CLLocation(latitude: places[0].latitude, longitude: places[0].longitude)
        let locB = CLLocation(latitude: places[1].latitude, longitude: places[1].longitude)
        let locC = CLLocation(latitude: places[2].latitude, longitude: places[2].longitude)
   
        guard let annotation = view.annotation else {return}
        
        let distanceA = locA.distance(from: userlocation)
        let distanceB = locB.distance(from: userlocation)
        let distanceC = locC.distance(from: userlocation)
        
        
        switch annotation.title {
        case "A":
            let alertController = UIAlertController(title: "DISTANCE FROM A to user location", message: "\(distanceA) meters ", preferredStyle: .alert)
                      let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                      alertController.addAction(cancelAction)
                      present(alertController, animated: true, completion: nil)
        case "B":
            let alertController = UIAlertController(title: "DISTANCE FROM B to user location", message: "\(distanceB) meters", preferredStyle: .alert)
                           let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                           alertController.addAction(cancelAction)
                           present(alertController, animated: true, completion: nil)
        case "C":
            let alertController = UIAlertController(title: "DISTANCE FROM C to user location", message: "\(distanceC) meters", preferredStyle: .alert)
                               let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                               alertController.addAction(cancelAction)
                               present(alertController, animated: true, completion: nil)
        default:
            print("default")
            
        }
         
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            let rendrer = MKCircleRenderer(overlay: overlay)
            rendrer.fillColor = UIColor.black.withAlphaComponent(0.5)
            rendrer.strokeColor = UIColor.green
            rendrer.lineWidth = 2
            return rendrer
        } else if overlay is MKPolyline {
            let rendrer = MKPolylineRenderer(overlay: overlay)
            rendrer.strokeColor = UIColor.blue
            rendrer.lineWidth = 3
            return rendrer
        } else if overlay is MKPolygon {
            let rendrer = MKPolygonRenderer(overlay: overlay)
            rendrer.fillColor = UIColor.red.withAlphaComponent(0.6)
            rendrer.strokeColor = UIColor.yellow
            rendrer.lineWidth = 2
            return rendrer
        }
        return MKOverlayRenderer()
    }








}
