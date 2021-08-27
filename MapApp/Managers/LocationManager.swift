//
//  LocationManager.swift
//  MapApp
//
//  Created by Ryan Kanno on 4/27/21.
//

import Foundation
import CoreLocation
import MapKit

class LocationManager: NSObject, CLLocationManagerDelegate {
   static let shared = LocationManager()
   let manager = CLLocationManager()
   var completion: ((CLLocation) -> Void)?
   static let regionInMeters: Double = 10000
   
   public func getUserLocation(completion: @escaping ((CLLocation) -> Void)) {
      print("\n\(#function)")
      self.completion = completion
      manager.requestWhenInUseAuthorization()
      manager.delegate = self
      manager.startUpdatingLocation()
   } //: getUserLocation()
   
   public func resolveLocationName(with location: CLLocation, completion: @escaping ((String?) -> Void)) {
      print("\n\(#function)")
      let geocoder = CLGeocoder()
      geocoder.reverseGeocodeLocation(location, preferredLocale: .current) { placemarks, error in
         guard let place = placemarks?.first, error == nil else {
            completion(nil)
            return
         }
         print(place)
         var name = ""
         if let locality = place.locality {
            name += locality
         }
         if let adminRegion = place.administrativeArea {
            name += ", \(adminRegion)"
         }
         completion(name)
      }
   } //: resolveLocationName()
   
   public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
      print("\n\(#function)")
      guard let location = locations.first else { return }
      completion?(location)
      manager.stopUpdatingLocation()
   } //: locationManager()
   
   public func centerViewOnUserLocation(mapView: MKMapView) {
      print("\n\(#function)")
      if let location = manager.location?.coordinate {
         let region = MKCoordinateRegion.init(
            center: location,
            latitudinalMeters: LocationManager.regionInMeters,
            longitudinalMeters: LocationManager.regionInMeters)
         mapView.setRegion(region, animated: true)
      }
   } //: centerViewOnUserLocation()
   
   public func addMapPin(with location: CLLocation, mapView: MKMapView) -> CLLocation {
      print("\n\(#function)")
      let pin = MKPointAnnotation()
      pin.coordinate = location.coordinate
      mapView.setRegion(
         MKCoordinateRegion(
            center: location.coordinate,
            span: MKCoordinateSpan(
               latitudeDelta: 0.8,
               longitudeDelta: 0.8)),
         animated: true)
      mapView.addAnnotation(pin)
      
      return location
   } //: addMapPin()
      
} //: LocationManager
