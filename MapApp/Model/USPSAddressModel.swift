//
//  USPSAddress.swift
//  MapApp
//
//  Created by Ryan Kanno on 4/28/21.
//

import Foundation

struct USPSAddressModel: Codable {
   let delivery_line_1: String
   let last_line: String
   let components: Components
   let metadata: Metadata
}
struct Components: Codable {
   let primary_number: String
   let street_predirection: String
   let street_name: String
   let street_suffix: String
   let city_name: String
   let default_city_name: String
   let state_abbreviation: String
   let zipcode: String
   let plus4_code: String
}
struct Metadata: Codable {
   let county_name: String
   let latitude: Double
   let longitude: Double
   let time_zone: String
}
