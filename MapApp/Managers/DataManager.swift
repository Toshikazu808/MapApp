//
//  DataManager.swift
//  MapApp
//
//  Created by Ryan Kanno on 4/28/21.
//

import Foundation

protocol DataManagerDelegate {
   func pinSearchOnMap()
}

struct DataManager {
   var delegate: DataManagerDelegate?
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
      print("\n\(#function)")
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
   
   func removeComma(addressElement: String) -> String {
      print("\n\(#function)")
      var element:String = addressElement
      print(element)
      var count = 0
      for char in element {
         if char == "," {
            let strIndex = element.index(element.startIndex, offsetBy: count)
            element.remove(at: strIndex)
         }
         count += 1
      }
      print(element)
      return element
   } //: removeComma()
   
   func removeSpaces(addressElement: String) -> String {
      print("\n\(#function)")
      var element:String = addressElement
      print(element)
      var count = 0
      for char in element {
         if char == " " {
            let strIndex = element.index(element.startIndex, offsetBy: count)
            element.remove(at: strIndex)
         }
         count += 1
      }
      print(element)
      return element
   } //: removeSpaces()
   
   private func scanToURL(addressString: String) -> String {
      print("\n\(#function)")
      var tempString:String = addressString
      var count = 0
      for char in addressString {
         switch char {
         case ",":
            let strIndex = tempString.index(tempString.startIndex, offsetBy: count)
            tempString.remove(at: strIndex)
            tempString.insert(contentsOf: "%2C", at: strIndex)
            count += 2
            break
         case " ":
            let strIndex = tempString.index(tempString.startIndex, offsetBy: count)
            tempString.remove(at: strIndex)
            tempString.insert(contentsOf: "%20", at: strIndex)
            count += 2
            break
         case "#":
            let strIndex = tempString.index(tempString.startIndex, offsetBy: count)
            tempString.remove(at: strIndex)
            tempString.insert(contentsOf: "%23", at: strIndex)
            count += 2
            break
         default:
            break
         }
         count += 1
      }
      return tempString
   } //: scanString()
   
   private func scanStreetForUSPS(street: String) -> String {
      print("\n\(#function)")
      var tempString:String = street
      var count = 0
      for char in street {
         if char == " " {
            let strIndex = tempString.index(tempString.startIndex, offsetBy: count)
            tempString.remove(at: strIndex)
            tempString.insert(contentsOf: "%20", at: strIndex)
            count += 2
         }
         count += 1
      }
      return tempString
   } //: scanStreetForUSPS()
   
   private func scanToMQ(addressString: String) -> String {
      print("\n\(#function)")
      var tempString:String = addressString
      var count = 0
      for char in addressString {
         switch char {
         case ",":
            let strIndex = tempString.index(tempString.startIndex, offsetBy: count)
            tempString.remove(at: strIndex)
            tempString.insert(contentsOf: "%2C", at: strIndex)
            count += 2
            break
         case " ":
            let strIndex = tempString.index(tempString.startIndex, offsetBy: count)
            tempString.remove(at: strIndex)
            tempString.insert(contentsOf: "+", at: strIndex)
            break
         case "#":
            let strIndex = tempString.index(tempString.startIndex, offsetBy: count)
            tempString.remove(at: strIndex)
            tempString.insert(contentsOf: "%23", at: strIndex)
            count += 2
            break
         default:
            break
         }
         count += 1
      }
      return tempString
   } //: scanToMQ()
   
   func attemptCleanSearch(street: String, city: String, state: String, zipcode: String) {
      print("\n\(#function)")
//      let scannedStreet = scanStreetForUSPS(street: street)
//      let uspsURL = "\(URLConst.uspsURL)&street=\(scannedStreet)&city=\(city)&state=\(state)&zipcode=\(zipcode)&method=get"
//      uspsValidateAddress(url: uspsURL/*, street: street, city: city, state: state, zipcode: zipcode*/)
      // variable:
      
//      let rmAddress = scanToURL(addressString: "\(street) \(city) \(state) \(zipcode)")
//      getRealtyMoleCoordinates(address: rmAddress)
      
      let mqaddress = scanToMQ(addressString: "\(street) \(city) \(state) \(zipcode)")
      let mqURL = "\(URLConst.mapQuestURLFirstHalf)\(URLConst.mapQuestKey)\(URLConst.mapQuestURLAfterKey)\(mqaddress)\(URLConst.mapQuestURLAfterLocation)"
      getMQCoordinates(url: mqURL)
      
   } //: attemptSearch
   
   private func getMQCoordinates(url: String) -> Void {
      print("\n\(#function)")
      performRequest(urlString: url, returnType: MapQuestModel.self) { result in
         switch result {
         case .failure(let error):
            print(error)
         case .success(let success):            
            DataManager.lat = success.results[0].locations[0].displayLatLng.lat
            DataManager.long = success.results[0].locations[0].displayLatLng.lng
            delegate?.pinSearchOnMap()
         }
      }
   } //: getMQCoordinates
   
   private func uspsValidateAddress(url: String/*, street: String, city: String, state: String, zipcode: String*/) -> Void {
      print("\n\(#function)")
      performRequest(urlString: url, returnType: [USPSAddressModel].self) { result in
         switch result {
         case .failure(let error):
            print(error)
         case .success(let success):
            print("\nUSPS API call was successful: \(success)")
            let parsedAddress = "\(success[0].delivery_line_1) \(success[0].last_line)"
            let rmAddress = scanToURL(addressString: parsedAddress)
            getRealtyMoleCoordinates(address: rmAddress)
         }
      }
   } //: uspsValidateAddress()
   
   private func getRealtyMoleCoordinates(address: String) {
      print("\n\(#function)")
      performCallWithHeaders(
         url: "\(URLConst.realtyMoleURL)\(address)",
         headers: URLConst.realtyMoleHeaders,
         expectingReturnType: RealtyMole.self) { (result) in
         switch result {
         case .failure(let error):
            print(error)
         case .success(let success):
            DataManager.lat = success.latitude
            DataManager.long = success.longitude
            delegate?.pinSearchOnMap()
         }
      }
   } //: getRealtyMoleRentEstimate()
   
   private func performCallWithHeaders<T: Codable>(
      url: String,
      headers: [String:String],
      expectingReturnType: T.Type,
      completion: @escaping (Result<T, Error>) -> Void ) {
      print("\n\(#function)")
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
   
   private func performCallNoHeader<T: Codable>(
      url: String,
      returnType: T.Type,
      completion: @escaping (Result<T, Error>) -> Void ) {
      print("\n\(#function)")
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
               with: data, options: .mutableContainers) // .allowFragments
            print(json)
            
            let decodedData = try JSONDecoder().decode(T.self, from: data)
            completion(.success(decodedData))
         } catch let decodingErr {
            completion(.failure(decodingErr))
         }
      }
      task.resume()
   } //: performCallNoHeader
   
   private func performRequest<T: Codable>(urlString: String, returnType: T.Type, completion: @escaping (Result<T, Error>) -> Void ) {
      print("\n\(#function)")
      if let url = URL(string: urlString) {
         let session = URLSession(configuration: .default)
         let task = session.dataTask(with: url) { (data, response, error) in
            let httpResponse = response as? HTTPURLResponse
            print(httpResponse as Any)
            if let error = error {
               completion(.failure(error))
               return
            } else {
               let httpResponse = response as? HTTPURLResponse
               print(httpResponse as Any)
            }
            guard let data = data else { return }
            let decoder = JSONDecoder()
            do {
               let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
               print(json)
               let decodedData = try decoder.decode(T.self, from: data)
               completion(.success(decodedData))
            } catch let decodingErr {
               completion(.failure(decodingErr))
            }
         }
         task.resume()
      } else {
         print("something went wrong with the url")
      }
   } //: performRequest()
   
} //: DataManager
