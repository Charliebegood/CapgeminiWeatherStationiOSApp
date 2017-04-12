//
//  ViewController.swift
//  CapGemini_Weather
//
//  Created by Aubert Charles on 08/02/2017.
//  Copyright © 2017 Charles. All rights reserved.
//

import Foundation
import UIKit
import SceneKit
import MapKit

class MainViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UIViewControllerTransitioningDelegate, CAAnimationDelegate{

    //# MARK: - Variables
    struct Station {
        let name: String
        var temperature: Double
        var pressure: Double
        var humidity: Double
        let coordinate: CLLocationCoordinate2D
        let id: Int
    }
    var stations: [Station] = []
    //Start of macro variables
    let link_sensor = "http://tech-toulouse.ovh:8000/sensor/"
    let link_station = "http://tech-toulouse.ovh:8000/station/"
    //End of link variables
    
    //Start of location variables
    var myLocation:CLLocationCoordinate2D?
    var firstLoad = true
    var locAuthorization = false
    let initialLocation = CLLocation(latitude: 43.599389, longitude: 1.444195)
    let regionRadius: CLLocationDistance = 500
    let locationManager = CLLocationManager()
    @IBOutlet weak var refreshButton: UIButton!
    var isRotating = false
    var shouldStopRotating = false
    var timer: Timer!
    @IBOutlet weak var mapView: MKMapView!
    //End of location variables
    
    let transition = CircularTransition()
    var touchPosition = CGPoint()
    var startPosition = CGPoint()
    var temp_button = UIButton()
    //Declare used storyboard with it's id
    let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
    //# MARK: - END of variables

    
    
    
    
    
    
    
    

    //Executed when view is loading
    override func viewDidLoad() {
        super.viewDidLoad()
        //Location initializer
        // Ask for Authorisation from the User.
        if let authorization = UserDefaults.standard.object(forKey: "authorization") as? Bool {
            locAuthorization = authorization
        }
        if locAuthorization == false {
            self.locationManager.requestWhenInUseAuthorization()
        }
        if CLLocationManager.locationServicesEnabled() {
            locAuthorization = true
            UserDefaults.standard.set(locAuthorization, forKey: "authorization")
            UserDefaults.standard.synchronize()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            mapView.showsUserLocation = true
        }
        //Map settings
        touchPosition = CGPoint(x: self.view.frame.size.width / 2, y: self.view.frame.size.height / 2)
        mapView.delegate = self
        mapView.mapType = .standard
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        
        //Refresh button settings
        refreshButton.layer.cornerRadius = 0.5 * refreshButton.bounds.size.width
        let blur = UIVisualEffectView(effect: UIBlurEffect(style:
            UIBlurEffectStyle.light))
        blur.frame = refreshButton.bounds
        blur.isUserInteractionEnabled = false
        blur.layer.cornerRadius = 0.5 * refreshButton.bounds.size.width
        blur.clipsToBounds = true
        refreshButton.insertSubview(blur, belowSubview: refreshButton.imageView!)
        get_data_and_display()
    }
    
    //Executed when view is about to appear
    override func viewWillAppear(_ animated: Bool) {
        //animateTable()
    }
    
    //Executed when view appeared
    override func viewDidAppear(_ animated: Bool) {
    }
    
    //Modify the variable that holds the color of the status bar content
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

    //Executed when Help button was pressed : AboutViewController is going to show up
    @IBAction func present_help(_ sender: Any) {
        //Instanciate view controller
        let help_vc : UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "AboutViewController") as UIViewController
        
        
        //Present the controller which will dismiss its self later on
        self.present(help_vc, animated: true, completion: nil)
    }
    
    
    
    
    
    //# MARK: - Fucntions for the location management and maping
    //Executed everytime location is being refreshed
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        let span = MKCoordinateSpanMake(0.025, 0.025)
        var region = MKCoordinateRegion()
        
        
        myLocation = locValue
        if (firstLoad == true && (myLocation != nil)) {
            firstLoad = false
            region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: (myLocation?.latitude)!, longitude: (myLocation?.longitude)!), span: span)
            mapView.setRegion(region, animated: true)
            mapView.setCenter(locValue, animated: true)
        }
        else if (myLocation == nil){
            let alert = UIAlertController(title: "Error", message: "GPS access is restricted. In order to use tracking, please enable location in the Settings app.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Settings", style: UIAlertActionStyle.cancel, handler: { (alert: UIAlertAction!) in
                UIApplication.shared.open(NSURL(string:UIApplicationOpenSettingsURLString)! as URL)
            }))
            let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in }
            alert.addAction(OKAction)
            self.present(alert, animated: true)
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // If annotation is not of type RestaurantAnnotation (MKUserLocation types for instance), return nil
        if !(annotation is RaspBerryPi){
            return nil
        }
        var annotationView = self.mapView.dequeueReusableAnnotationView(withIdentifier: "Pin")
        if annotationView == nil{
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "Pin")
            annotationView?.canShowCallout = true
        } else {
            annotationView?.annotation = annotation
        }
        let raspAnnotation = annotation as! RaspBerryPi
        let widthConstraint = NSLayoutConstraint(item: (raspAnnotation.view)!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 110)
        (raspAnnotation.view)!.addConstraint(widthConstraint)
        let heightConstraint = NSLayoutConstraint(item: (raspAnnotation.view)!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 90)
        (raspAnnotation.view)!.addConstraint(heightConstraint)
        
        annotationView?.detailCalloutAccessoryView = (raspAnnotation.view)!
        raspAnnotation.view?.frame = CGRect(x: (raspAnnotation.view?.frame.origin.x)!, y: (raspAnnotation.view?.frame.origin.y)!, width: (raspAnnotation.view?.frame.size.width)!, height: (raspAnnotation.view?.frame.size.height)!)
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: (raspAnnotation.view?.frame.size.width)!, height: (raspAnnotation.view?.frame.size.height)!)
        button.setImage(#imageLiteral(resourceName: "information.png"), for: UIControlState.normal)
        button.imageEdgeInsets = UIEdgeInsetsMake(30, (raspAnnotation.view?.frame.size.width)! - 20, 40, 0)
        button.addTarget(self.self.self, action: #selector(MainViewController.callSecondView(_:)), for: .touchUpInside)
        button.tag = raspAnnotation.tag
        temp_button = button
        raspAnnotation.view?.addSubview(button)
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
    }
    
    //Place pins on the map
    func placePins() {
        if (stations.count > 0) {
            for i in 0...stations.count - 1 {
            let raspberry = RaspBerryPi(title: stations[i].name, temperature: String(Int(stations[i].temperature)), pressure: String(Int(stations[i].pressure)), humidity: String(Int(stations[i].humidity)), coordinate: stations[i].coordinate, tag: i)
            mapView.addAnnotation(raspberry)
            }
        }
    }
    
    func callSecondView(_ sender: UIButton!) {
        var summary = [stations[sender.tag].name]
        summary.append(String(stations[sender.tag].temperature))
        summary.append(String(stations[sender.tag].pressure))
        summary.append(String(stations[sender.tag].humidity))
        summary.append(String(stations[sender.tag].id))
        let buttonCenter = CGPoint(x: sender.bounds.origin.x + sender.bounds.size.width / 2, y: sender.bounds.origin.y + sender.bounds.size.height / 2)
        let p = sender.convert(buttonCenter, to: self.self.view)
        
        
        touchPosition = p
        UserDefaults.standard.set(summary, forKey: "pie_name")
        UserDefaults.standard.synchronize()
        //Present the controller which will dismiss its self later on
        let data_vc : UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "DisplayController") as UIViewController
        data_vc.modalPresentationStyle = UIModalPresentationStyle.custom
        data_vc.transitioningDelegate = self
        self.present(data_vc, animated: true, completion: nil)
    }
    
    //Center the map on the user location
    @IBAction func center(_ sender: Any) {
        let span = MKCoordinateSpanMake(0.025, 0.025)
        var region = MKCoordinateRegion()

        
        if (myLocation != nil) {
            region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: (myLocation?.latitude)!, longitude: (myLocation?.longitude)!), span: span)
            mapView.setCenter(myLocation!, animated: true)
            mapView.setRegion(region, animated: true)
        } else {
            let alert = UIAlertController(title: "Error", message: "GPS access is restricted. In order to use tracking, please enable location in the Settings app.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Settings", style: UIAlertActionStyle.cancel, handler: { (alert: UIAlertAction!) in
                UIApplication.shared.open(NSURL(string:UIApplicationOpenSettingsURLString)! as URL)
            }))
            let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in }
            alert.addAction(OKAction)
            self.present(alert, animated: true)
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        var region = mapView.region
        
        
        region.center = (view.annotation?.coordinate)!
        mapView.setRegion(region, animated: true)
        let point = CGPoint(x: view.frame.origin.x, y: view.frame.origin.y)
        touchPosition = point
    }
    //# MARK: - END of functions for the location management
    
    
    
    
    
    
    //# MARK: - Start of custom transition animation
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        startPosition = touchPosition
        transition.transitionMode = .present
        transition.startingPoint = startPosition
        transition.circleColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
        return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .dismiss
        transition.startingPoint = startPosition
        transition.circleColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
        return transition
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        /*if let touch = touches.first {
            let position = touch.location(in: self.view)
            touchPosition = CGPoint(x: position.x, y: position.y)
        }
        */
    }
    //# MARK: - END of custom transition animation
    
    
    //# MARK: - API call
    func get_data_and_display() {
        //get_data_api()
        get_stations_api()
        placePins()
        shouldStopRotating = true
    }
    
    func get_stations_api() {
        //Display network inidcator when reaching data base
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        if let url = URL(string: link_station) {
            do {
                if let data = try? Data(contentsOf: url as URL) {
                    do {
                        let parsedData = try JSONSerialization.jsonObject(with: data as Data, options: []) as! NSArray
                        get_station(array: parsedData)
                    }
                }
                else {
                    print("Error : couldn't load stations.")
                }
            }
            catch {
                let alertController = UIAlertController(title: "Error", message: "No internet connection.", preferredStyle: .alert)
                let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
                }
                alertController.addAction(OKAction)
                self.present(alertController, animated: true) {
                }
                print("Error : no response from data base.")
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
        else {
            print("Error : the url was broken.")
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    func get_station(array: NSArray) {
        /*
         sample parsing
         {
         description = "Station in CapGemini Toulouse AIE";
         id = 3;
         latitude = "43.566626";
         longitude = "1.377419";
         name = "CapGemini Sud";
         }
         */
        var i = 0
        var temp_stations: [Station] = []
        
        
        while i < array.count {
            if let dict = array[i] as? NSDictionary {
                let name = dict["name"] as? String
                let lat = dict["latitude"] as? Double
                let lng = dict["longitude"] as? Double
                let id = dict["id"] as? Int
                let coordinate = CLLocationCoordinate2D(latitude: lat!, longitude: lng!)
                if let values = get_last_values(id: id) {
                    let station = Station(name: name!, temperature: values["temperature"]!, pressure: values["pressure"]!, humidity: values["hygrometry"]!, coordinate: coordinate, id: id!)
                    temp_stations.append(station)
                } else {
                    let station = Station(name: name!, temperature: 0.0, pressure: 0.0, humidity: 0.0, coordinate: coordinate, id: id!)
                    temp_stations.append(station)
                }
            } else {
                print("Error : couldn't load stations.")
            }
            i += 1
        }
        stations = temp_stations
    }
    
    func get_last_values(id: Int?) -> [String : Double]? {
        var full_url = link_sensor + "0/last_values"
        var res: [String : Double]?
        
        
        //Display network inidcator when reaching data base
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        if let unwraped_id = id {
            full_url = link_sensor + String(unwraped_id) + "/last_values"
        }
        if let url = URL(string: full_url) {
            do {
                if let data = try? Data(contentsOf: url as URL) {
                    do {
                        var sensors = ["temperature": 0.0 , "hygrometry": 0.0, "pressure": 0.0] as [String : Double]?
                        if let result = try JSONSerialization.jsonObject(with: data as Data, options: [])
                            as? NSArray {
                            if result.count > 0 {
                                for index in 0...result.count - 1{
                                    if let sensor = result[index] as? NSDictionary {
                                        if let type = sensor["sensor"] as? String {
                                            sensors?[type] = Double(sensor["value"] as! String)
                                        }
                                    }
                                }
                            }
                        } else {
                            print("Error : invalid response.")
                        }
                        res = sensors
                    }
                }
                else {
                    print("Error : invalid url.")
                }
            }
            catch {
                let alertController = UIAlertController(title: "Error", message: "No internet connection.", preferredStyle: .alert)
                let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
                }
                alertController.addAction(OKAction)
                self.present(alertController, animated: true) {
                }
                print("Error : no response from data base.")
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
        else {
            let alertController = UIAlertController(title: "Error", message: "No internet connection.", preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
            }
            alertController.addAction(OKAction)
            self.present(alertController, animated: true) {
            }
            print("Error : no response from data base.")
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        return (res)
    }
    
    @IBAction func refreshAction(_ sender: Any) {
        refreshButton.isUserInteractionEnabled = false
        if isRotating == false {
            refreshButton.rotate360Degrees(completionDelegate: self)
            timer = Timer(duration: 5.0, completionHandler: {
                self.shouldStopRotating = true
            })
            timer.start()
            isRotating = true
            mapView.removeAnnotations(mapView.annotations)
            get_data_and_display()
        }
        refreshButton.isUserInteractionEnabled = true
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if self.shouldStopRotating == false {
            self.refreshButton.rotate360Degrees(completionDelegate: self)
        } else {
            self.reset()
        }
    }
    
    func reset() {
        isRotating = false
        shouldStopRotating = false
    }
    //# MARK: - END API call
}
