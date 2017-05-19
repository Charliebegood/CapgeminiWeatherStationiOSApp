//
//  DisplayController.swift
//  CapGemini_Weather
//
//  Created by Aubert Charles on 08/02/2017.
//  Copyright © 2017 Charles. All rights reserved.
//

import Foundation
import UIKit
import Charts

class DisplayViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    //# MARK: - Variables
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var pressureLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var sharedData: [String]?
    let type = ["temperature", "pressure", "hygrometry", "snow"]
    let sensor_types = ["Temperature", "Pressure", "Hygrometry", "Snow"]
    let link_sensor = "http://tech-toulouse.ovh:8000/sensor/"
    let cellReuseIdendifier = "graphCell"
    var arrayDataEntries = [[ChartDataEntry]]()
    struct valueObject {
        var value = Double()
        var date = String()
        var error = Bool()
        
        
        init(value: Double, error: Bool) {
            self.value = value
            self.error = error
        }
    }
    struct sensor {
        var type = String()
        var values = [valueObject]()
    }
    var sensors = [sensor]()
    var station = [String]()
    var load = UIVisualEffectView()
    var activityIndicator = UIActivityIndicatorView()
    var current_date = String()
    var last_date = String()
    var current_date_link = String()
    var last_date_link = String()
    @IBOutlet weak var backgroundView: BackgroundView!
    //Declare used storyboard with it's id
    let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
    //# MARK: - END of variables

    
    
    
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //TableView settings
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
        //End of TableView settings
    }

    override func viewWillAppear(_ animated: Bool) {
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        
        
        if var dateFromtext = UserDefaults.standard.object(forKey: "dateFrom") as? String {
            dateFromtext = dateFromtext.replacingOccurrences(of: "-", with: "")
            dateFromtext = dateFromtext.replacingOccurrences(of: ":", with: "-")
            last_date_link = dateFromtext
        } else {
            last_date_link = "20000101-000000"
        }
        if var dateTotext = UserDefaults.standard.object(forKey: "dateTo") as? String {
            dateTotext = dateTotext.replacingOccurrences(of: "-", with: "")
            dateTotext = dateTotext.replacingOccurrences(of: ":", with: "-")
            current_date_link = dateTotext
        } else {
            current_date_link = "20000101-000000"
        }
        if let pie_name = UserDefaults.standard.object(forKey: "pie_name") as? [String] {
            sharedData = pie_name
            titleLabel.text = pie_name[0]
            temperatureLabel.text = "\(pie_name[1])°C"
            pressureLabel.text = "\(pie_name[2])mB"
            humidityLabel.text = "\(pie_name[3])%"
            station = pie_name
        } else {
            titleLabel.text = "Error"
            temperatureLabel.text = "Error"
            pressureLabel.text = "Error"
            humidityLabel.text = "Error"
            station = ["Error"]
        }
        //Setup the loading blur view
        blurEffectView.frame = CGRect(x: 0, y: self.backgroundView.frame.origin.y, width: self.view.frame.size.width, height: self.view.frame.size.height - self.backgroundView.frame.size.height)
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.alpha = 1
        load = blurEffectView
        self.view.addSubview(load)
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        activityIndicator.center.x = load.center.x
        activityIndicator.center.y = load.center.y - 50
        load.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        //End of the loading view setup
    }
    
    override func viewDidAppear(_ animated: Bool) {
        activityIndicator.stopAnimating()
        if (station[0] != "Error") {
            sensors = get_all_sensors(id: Int(station[4]))
            for tmp in sensors {
                if (tmp.values.count > 10) {
                    var dataEntries : [ChartDataEntry] = []
                    for i in 0...tmp.values.count - 1 {
                        let dataEntry = ChartDataEntry(x: Double(i), y: tmp.values[i].value)
                        dataEntries.append(dataEntry)
                    }
                    arrayDataEntries.append(dataEntries)
                } else {
                    let dataEntries : [ChartDataEntry] = []
                    arrayDataEntries.append(dataEntries)
                }
            }
        }
//        } else {
//            data = [("Error", [0.0])]
//        }
        UIView.animate(withDuration: 0.50, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: [], animations: {
            //Set x position what ever you want
            self.load.alpha = 0
        }, completion: nil)
        animateTable()
    }
    
    //Modify the color of the status bar to light content
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    @IBAction func dismiss(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func settings(_ sender: Any) {
        //Instanciate view controller
        let settings_vc : UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "DateSettingsViewController") as UIViewController
        
        
        //Present the controller which will dismiss its self later on
        self.present(settings_vc, animated: true, completion: nil)
    }
    
    func get_sensor_values(type: String, id: Int?) -> [valueObject] {
        var full_url = link_sensor + "0" + "type"
        var res = [valueObject]()
        var tmpValue = valueObject(value: 0.0, error: true)
        
        
        if let unwraped_id = id{
            full_url = link_sensor + String(unwraped_id) + "/" + type + "/" + last_date_link + "/" + current_date_link
        }
        //Display network inidcator when reaching data base
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        if let url = URL(string: full_url) {
            do {
                if let data = try? Data(contentsOf: url as URL) {
                    do {
                        if let parsedData = try JSONSerialization.jsonObject(with: data as Data, options: []) as? NSArray {
                            if (parsedData.count > 0) {
                                for i in 0...parsedData.count - 1 {
                                    if let sensor = parsedData[i] as? NSDictionary {
                                        if let value = sensor["value"] as? String {
                                            tmpValue.value = Double(value)!
                                        }
                                        if let date = sensor["datetime"] as? String {
                                            tmpValue.date = date
                                        }
                                        tmpValue.error = false
                                        res.append(tmpValue)
                                    }
                                }
                            } else {
                                res.append(valueObject(value: 0.0, error: true))
                            }
                        } else {
                            print("Error : invalid response.")
                        }
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
            res.append(valueObject(value: 0.0, error: true))
            print("Error : the url was broken.")
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        return (res)
    }
    
    func get_all_sensors(id : Int?) -> [sensor] {
        var tmpSensors = [sensor]()
    
        
        for i in 0...type.count - 1 {
            var tmpSensor = sensor()
            tmpSensor.values = get_sensor_values(type: type[i], id: id)
            tmpSensor.type = type[i]
            tmpSensors.append(tmpSensor)
        }
        return (tmpSensors)
    }
    
    
    
    
    
    //# MARK: - Table settings
    //Filling the table view with content from the app and the data base
    func formatDate(date: String) -> [Character] {
        var res = [Character]()
        var i = 0
        
        
        while (date[i] != "T") {
            res.append(date[i])
            i += 1
        }
        return (res)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var charDataSet = LineChartDataSet()
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdendifier)! as! GraphCell
        

        cell.typeLabel.text = self.sensor_types[indexPath.row]
        if sensors[indexPath.row].values.count > 10 && sensors[indexPath.row].values[0].error != true {
            cell.dateLeftLabel.text = String(formatDate(date: sensors[indexPath.row].values[0].date))
            cell.dateRightLabel.text = String(formatDate(date: sensors[indexPath.row].values[sensors[indexPath.row].values.count - 1].date))
            charDataSet = LineChartDataSet(values: arrayDataEntries[indexPath.row], label: self.type[indexPath.row])
            let chartData: LineChartData?
            charDataSet.circleRadius = 0.5
            chartData = LineChartData(dataSet: charDataSet)
            cell.lineChartView.data = chartData
        } else {
            cell.lineChartView.data = nil
            cell.dateLeftLabel.text = ""
            cell.dateRightLabel.text = ""
        }
        cell.lineChartView?.chartDescription = nil
        cell.lineChartView?.xAxis.labelPosition = .bottom
        cell.lineChartView?.rightAxis.enabled = false
        cell.lineChartView?.leftAxis.enabled = true
        cell.lineChartView?.xAxis.drawGridLinesEnabled = false
        cell.lineChartView?.xAxis.enabled = false
        cell.lineChartView?.legend.enabled = false
        return cell
    }

    //Returns the height of each cell
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300
    }
    
    //Function that counts the number of cells to be displayed
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sensors.count
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return  300;
    }

    //Animates table when view appears and when reloading table data.
    func animateTable(){
        tableView.reloadData()
        let cells = tableView.visibleCells
        let tableHeight: CGFloat = tableView.frame.size.height
        var index = 0
        
        
        for i in cells {
            let cell: UITableViewCell = i as UITableViewCell
            cell.transform = CGAffineTransform(translationX: 0, y: tableHeight)
        }
        for a in cells {
            let cell: UITableViewCell = a as UITableViewCell
            UIView.animate(withDuration: 1.5, delay: 0.05 * Double(index), usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: {
                cell.transform = CGAffineTransform(translationX: 0, y: 0);
            }, completion: nil)
            index += 1
        }
    }
    //# MARK: - END of table settings
}
