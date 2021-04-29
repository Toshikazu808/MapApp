//
//  DataManager.swift
//  MapApp
//
//  Created by Ryan Kanno on 4/28/21.
//

import Foundation

struct DataManager {
   static var lat: Double = 0
   static var long: Double = 0
   
   func checkForZip(address: String) -> String {
      let reveresedAddress = address.reversed()
      var reversedZip = ""
      var count = 1
      for char in reveresedAddress {
         if count < 6 {
            reversedZip += String(char)
         } else { break }
         count += 1
      }
      let tempZip = String(reversedZip.reversed())
      if let zip = Int(tempZip) {
         return String(zip)
      } else {
         print("Please include zip code at the end of the address")
         return ""
      }
   } //: checkForZip()
   
   func splitAddressForUSPS(address: String) -> (street: String, city: String, state: String, zip: String) {
      let reversedAddress = address.reversed()
      var reversedZip:String = ""
      var reversedState:String = ""
      var reversedCity:String = ""
      var reversedStreet:String = ""
      var spaceCounter:Int = 0
      for char in reversedAddress {
         switch spaceCounter {
         case 0:
            reversedZip += String(char)
         case 1:
            reversedState += String(char)
         case 2:
            reversedCity += String(char)
         case 3:
            reversedStreet += String(char)
         default:
            break
         }
         if spaceCounter < 3 && char == " " {
            spaceCounter += 1
         }
      } //: LOOP
      let street = String(reversedStreet.reversed())
      let city = String(reversedCity.reversed())
      let state = String(reversedState.reversed())
      let zip = String(reversedZip.reversed())
      return (street, city, state, zip)
   } //: splitAddressForUSPS
   
   func attemptCleanSearch(street: String, city: String, state: String, zipcode: String) {
      uspsValidateAddress(url: URLConst.uspsURL, street: street, city: city, state: state, zipcode: zipcode)
   } //: attemptSearch
   
   private func uspsValidateAddress(url: String, street: String, city: String, state: String, zipcode: String) -> Void {
      performCallNoHeader(
         url: url,
         returnType: USPSAddressModel.self) { (result) in
         switch result {
         case .failure(let error):
            print(error)
         case .success(let success):
            print("\nUSPS API call was successful: \(success)")
            getRealtyMoleCoordinates(
               address: success.delivery_line_1,
               city: success.components.city_name,
               state: success.components.state_abbreviation,
               zipcode: success.components.zipcode)
            // PIN LOCATION
            
         }
      }
   } //: uspsValidateAddress()
   
   private func getRealtyMoleCoordinates(address: String, city: String, state: String, zipcode: String) {
      performCallWithHeaders(
         url: URLConst.realtyMoleURL,
         headers: URLConst.realtyMoleHeaders,
         expectingReturnType: RealtyMole.self) { (result) in
         switch result {
         case .failure(let error):
            print(error)
         case .success(let success):
            DataManager.lat = success.latitude
            DataManager.long = success.longitude
         }
      }
   } //: getRealtyMoleRentEstimate()
   
   private func performCallNoHeader<T: Codable>(
      url: String,
      returnType: T.Type,
      completion: @escaping (Result<T, Error>) -> Void ) {
      let request = NSMutableURLRequest(
         url: NSURL(string: url)! as URL,
         cachePolicy: .useProtocolCachePolicy,
         timeoutInterval: 10.0)
      let task = URLSession.shared.dataTask(
         with: request as URLRequest) { (data, response, error) in
         if let error = error {
            completion(.failure(error))
            return
         } else {
            let httpResponse = response as? HTTPURLResponse
            print(httpResponse as Any)
         }
         guard let data = data else { return }
         do {
            let json = try JSONSerialization.jsonObject(
               with: data, options: .mutableContainers)
            print(json)
            let decodedData = try JSONDecoder().decode(T.self, from: data)
            completion(.success(decodedData))
         } catch let decodingErr {
            completion(.failure(decodingErr))
         }
      }
      task.resume()
   } //: performCallNoHeader
   
   private func performCallWithHeaders<T: Codable>(
      url: String,
      headers: [String:String],
      expectingReturnType: T.Type,
      completion: @escaping (Result<T, Error>) -> Void ) {
      
      let request = NSMutableURLRequest(
         url: NSURL(string: url)! as URL,
         cachePolicy: .useProtocolCachePolicy,
         timeoutInterval: 10.0)
      request.httpMethod = "GET"
      request.allHTTPHeaderFields = headers
      
      let task = URLSession.shared.dataTask(
         with: request as URLRequest) { (data, response, error) in
         if let error = error {
            completion(.failure(error))
            return
         } else {
            let httpResponse = response as? HTTPURLResponse
            print(httpResponse as Any)
         }
         guard let data = data else { return }
         do {
            let json = try JSONSerialization.jsonObject(
               with: data, options: .mutableContainers)
            print(json)
            let decodedData = try JSONDecoder().decode(T.self, from: data)
            completion(.success(decodedData))
         } catch let decodingErr {
            completion(.failure(decodingErr))
         }
      }
      task.resume()
   } //: performAPICall()
   
   
} //: DataManager
