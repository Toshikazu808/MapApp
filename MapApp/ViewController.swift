//
//  ViewController.swift
//  MapApp
//
//  Created by Ryan Kanno on 4/27/21.
//

// REMEMBER: Delete URL keys / headers before uploading!

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, MKMapViewDelegate {
   @IBOutlet weak var mapView: MKMapView!
   @IBOutlet weak var listButton: UIButton!
   @IBOutlet weak var searchButton: UIButton!
   @IBOutlet weak var textField: UITextField!
   
   let locationManager = CLLocationManager()
   var titleText: String = ""
   var dataManager = DataManager()
   
   
   
   override func viewDidLoad() {
      super.viewDidLoad()
      mapView.delegate = self
      dataManager.delegate = self
//      checkLocationServices()
//      checkLocationAuthorization()
//      setupLocationManager()
      
      self.getUserLocation()
      
//      let annotation = MKPointAnnotation()
//      annotation.coordinate = CLLocationCoordinate2D(
//         latitude: 38.8977,
//         longitude: -77.0365)
//      annotation.title = "The White House"
//      annotation.subtitle = "The house of the president"
//      mapView.addAnnotation(annotation)
//      
//      let region = MKCoordinateRegion(
//         center: annotation.coordinate,
//         latitudinalMeters: 500,
//         longitudinalMeters: 500)
//      mapView.setRegion(region, animated: true)
      
   } //: viewDidLoad()
   override func viewWillAppear(_ animated: Bool) {
       super.viewWillAppear(animated)
       print(#function)
   }
   override var shouldAutorotate: Bool {
       return false
   }
   override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
       return .portrait
   }
   override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
       return .portrait
   } // End of initial setup
   
   private func getUserLocation() {
      print("\n\(#function)")
      LocationManager.shared.getUserLocation { [weak self] location in
         DispatchQueue.main.async {
            let pinLocation = LocationManager.shared.addMapPin(with: location, mapView: self!.mapView)
            LocationManager.shared.resolveLocationName(with: pinLocation) { [weak self] locationName in
               self?.title = locationName
            }
            self!.mapView.showsUserLocation = true
         }
      }
   } //: getUserLocation()
   
   func  setupLocationManager() {
      print("\n\(#function)")
      locationManager.delegate = self
      locationManager.desiredAccuracy = kCLLocationAccuracyBest
   } //: setupLocationManager()
   
   func checkLocationServices() {
      print("\n\(#function)")
      if CLLocationManager.locationServicesEnabled() == true {
         setupLocationManager()
         checkLocationServices()
      } else {
         showDisabledLocationAlert()
      }
   } //: checkLocationServices()
   
   func checkLocationAuthorization() {
      print("\n\(#function)")
      let manager = CLLocationManager()
      switch manager.authorizationStatus {
      case .notDetermined:
         locationManager.requestWhenInUseAuthorization()
      case .restricted:
         showRestrictedLocationAlert()
      case .denied:
         showDisabledLocationAlert()
      case .authorizedAlways:
         break
      case .authorizedWhenInUse:
         getUserLocation()
         break
      @unknown default:
         break
      }
   } //: checkLocationAuthorization()
   
   func showDisabledLocationAlert() {
      print("\n\(#function)")
      let alert = UIAlertController(
         title: "Location disabled",
         message: "Please allow locations in Settings in order to use.",
         preferredStyle: .alert)
      alert.addAction(
         UIAlertAction(
            title: "Dismiss",
            style: .default,
            handler: nil))
      present(alert, animated: true)
   } //: showDisabledLocationAlert()
   
   func showRestrictedLocationAlert() {
      print("\n\(#function)")
      let alert = UIAlertController(
         title: "Location disabled",
         message: "This devices location is restricted.",
         preferredStyle: .alert)
      alert.addAction(
         UIAlertAction(
            title: "Dismiss",
            style: .default,
            handler: nil))
      present(alert, animated: true)
   } //: showRestrictedLocationAlert()
   
} //: ViewController


extension ViewController: CLLocationManagerDelegate {
   func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
      print("\n\(#function)")
      guard let location = locations.last else { return }
      let center = CLLocationCoordinate2D(
         latitude: location.coordinate.latitude,
         longitude: location.coordinate.longitude)
      let region = MKCoordinateRegion.init(
         center: center,
         latitudinalMeters: LocationManager.regionInMeters,
         longitudinalMeters: LocationManager.regionInMeters)
      mapView.setRegion(region, animated: true)
   } //: didUpdateLocations()
   
   func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
      checkLocationAuthorization()
   }
   
} //: CLLocationManagerDelegate


extension ViewController: UITextFieldDelegate {
   @IBAction func searchButtonTapped(_ sender: UIButton) {
      print("\n\(#function)")
      textField.endEditing(true)
      textField.placeholder = "Address"
      attemptAddressSearch(textFieldText: textField.text ?? "")
   } //: searchButtonTapped()
   
   func textFieldShouldReturn(_ textField: UITextField) -> Bool {
      print("\n\(#function)")
      textField.endEditing(true)
      return true
   } //: textFieldShouldReturn
   
   func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
      print("\n\(#function)")
      if textField.text != "" {
         return true
      } else {
         textField.placeholder = "Address"
         return false
      }
   } //: textFieldShouldEndEditing
   
   func textFieldDidEndEditing(_ textField: UITextField) {
      print("\n\(#function)")
      textField.placeholder = "Address"
      textField.text = ""
      attemptAddressSearch(textFieldText: textField.text ?? "")
   } //: textFieldDidEndEditing
   
   private func attemptAddressSearch(textFieldText: String) {
      print("\n\(#function)")
      if textFieldText != "" {
         let zip = dataManager.checkForZip(address: textFieldText)
         if zip != "" {
            let (tempStreet, tempCity, state, zipcode) = dataManager.splitAddressForUSPS(address: textFieldText)
            let cleanStreet = dataManager.removeComma(addressElement: tempStreet)
            let city = dataManager.removeComma(addressElement: tempCity)
            let cleanCity = dataManager.removeSpaces(addressElement: city)
            let cleanState = dataManager.removeSpaces(addressElement: state)
            let cleanZip = dataManager.removeSpaces(addressElement: zipcode)
            
            dataManager.attemptCleanSearch(
               street: cleanStreet,
               city: cleanCity,
               state: cleanState,
               zipcode: cleanZip)
         } else {
            let alert = UIAlertController(
               title: "Please include zip code",
               message: "",
               preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            present(alert, animated: true)
         }
      } else {
         let alert = UIAlertController(
            title: "Please enter an address",
            message: "",
            preferredStyle: .alert)
         alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
         present(alert, animated: true)
      }
   } //: attempAddressSearch
   
} //: UITextFieldDelegate


extension ViewController: DataManagerDelegate {
   func pinSearchOnMap() {
      print("\n\(#function)")
      DispatchQueue.main.async {
         let location = CLLocation(
            latitude: DataManager.lat,
            longitude: DataManager.long)
         let pinLocation = LocationManager.shared.addMapPin(
            with: location,
            mapView: self.mapView)
         LocationManager.shared.resolveLocationName(with: pinLocation) { [weak self] locationName in
            self?.title = locationName
         }
      }
   } //: pinSearchOnMap()
   
} //: DataManagerDelegate
