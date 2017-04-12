//
//  Annotation.swift
//  CapGemini_Weather
//
//  Created by Charles AUBERT on 11/02/2017.
//  Copyright © 2017 Charles. All rights reserved.
//

import Foundation
import MapKit

class RaspBerryPi: NSObject, MKAnnotation {
    let title: String?
    let temperature: String
    let tag: Int
    let pressure: String
    let humidity: String
    let coordinate: CLLocationCoordinate2D
    var view: CustomInformation?
    
    
    init(title: String, temperature: String, pressure: String, humidity: String, coordinate: CLLocationCoordinate2D, tag: Int) {
        self.title = title
        self.tag = tag
        self.temperature = temperature
        self.pressure = pressure
        self.humidity = humidity
        self.coordinate = coordinate
        self.view = CustomInformation(frame: CGRect(x: 0, y: 0, width: 110, height: 90))
        self.view?.add_text(temperature: temperature, humidity: humidity, pressure: pressure)
        super.init()
    }
}

class CustomInformation: UIView {
    var temperatureLabel: UILabel?
    var pressureLabel: UILabel?
    var humidityLabel: UILabel?
    var temperatureImage: UIImageView?
    var pressureImage: UIImageView?
    var humidityImage: UIImageView?
    
    
    override init(frame: CGRect){
        super.init(frame: frame)
        self.temperatureImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 22, height: 22))
        self.temperatureImage?.image = #imageLiteral(resourceName: "temperature.png")
        self.temperatureLabel = UILabel(frame: CGRect(x: 30,y: 1,width: 50,height: 20))
        self.temperatureLabel?.font = UIFont(name: "Avenir Next", size: 12)
        self.pressureImage = UIImageView(frame: CGRect(x: 0, y: 30, width: 22, height: 22))
        self.pressureImage?.image = #imageLiteral(resourceName: "pressure.png")
        self.pressureLabel = UILabel(frame: CGRect(x: 30,y: 31,width: 50,height: 20))
        self.pressureLabel?.font = UIFont(name: "Avenir Next", size: 12)
        self.humidityImage = UIImageView(frame: CGRect(x: 0, y: 60, width: 22, height: 22))
        self.humidityImage?.image = #imageLiteral(resourceName: "humidity.png")
        self.humidityLabel = UILabel(frame: CGRect(x: 30,y: 61,width: 50,height: 20))
        self.humidityLabel?.font = UIFont(name: "Avenir Next", size: 12)
        self.addSubview(temperatureLabel!)
        self.addSubview(temperatureImage!)
        self.addSubview(pressureLabel!)
        self.addSubview(pressureImage!)
        self.addSubview(humidityLabel!)
        self.addSubview(humidityImage!)
    }
    
    func add_text(temperature: String, humidity: String, pressure: String) {
        temperatureLabel?.text = temperature + "°C"
        humidityLabel?.text = humidity + "%"
        pressureLabel?.text = pressure + "mB"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
