//
//  URLConst.swift
//  MapApp
//
//  Created by Ryan Kanno on 4/28/21.
//

import Foundation

struct URLConst {

   static let realtyMoleRentEstimate = "realtyMoleRentEstimate"
   static let realtyMoleHeaders: [String:String] = [
      "x-rapidapi-key": "1ee40e1078mshf47892cf43b08c9p1bb6b6jsn67c6fbffd29b",
      "x-rapidapi-host": "realty-mole-property-api.p.rapidapi.com"]
   static let realtyMoleURL = "https://realty-mole-property-api.p.rapidapi.com/rentalPrice?compCount=5&address="
   
//   static let uspsURL = "https://us-street.api.smartystreets.com/street-address?auth-id=e4e34a71-81c7-6925-200c-0959054a8680&auth-token=mY3tKUufVM6Dm9eQIXKP"
   
   static let uspsURL = "https://us-street.api.smartystreets.com/street-address?auth-id=e4e34a71-81c7-6925-200c-0959054a8680&auth-token=mY3tKUufVM6Dm9eQIXKP"
   // &street=1017%20NE%20175th%20St&city=Shoreline&state=WA&zipcode=98155
   
   //"https://smartystreets.com/products/apis/us-street-api?auth-id=e4e34a71-81c7-6925-200c-0959054a8680&auth-token=mY3tKUufVM6Dm9eQIXKP
   // &street=1017%20NE%20175th%20St&city=Shoreline&state=WA&zipcode=98155&method=get”
   
   static let mapQuestURLFirstHalf = "https://www.mapquestapi.com/geocoding/v1/address?key="
   static let mapQuestKey = "GTwHSh481QARoqEjChLld2T6WEkgXcpw"
   static let mapQuestURLAfterKey = "&inFormat=kvp&outFormat=json&location="
   static let mapQuestURLAfterLocation = "&thumbMaps=false&maxResults=50"
   
}
