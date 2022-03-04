//
//  LatLngCallService.swift
//  testOBD2
//
//  Created by ธนัท แสงเพิ่ม on 11/2/2565 BE.
//

import Foundation
import CoreLocation
class LatLngCallService : NSObject {
    let locationManager = CLLocationManager()
    static let shared = LatLngCallService()
    var lat: Double?
    var lon: Double?
    private override init() {
        super.init()
        locationManager.delegate = self
        //        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        //        locationManager.distanceFilter = kCLLocationAccuracyHundredMeters
        locationManager.requestAlwaysAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.requestLocation()
    }
    func getDate(){
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        let sec = calendar.component(.second, from: date)
        print("from get Date >> \(hour):\(minutes):\(sec)")
    }
}
extension LatLngCallService: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            lat = nil
            lon = nil
            return
        }
        let coordinate = location.coordinate
        lat = coordinate.latitude
        lon = coordinate.longitude
        print("\n",lat ?? 0)
        print(lon ?? 0)
        getDate()
        locationManager.requestLocation()
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
