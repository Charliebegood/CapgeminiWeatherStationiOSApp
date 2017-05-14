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
    var data = [(String, [Double])]()
    var arrayDataEntries = [[ChartDataEntry]]()
    var station = [String]()
    var load = UIVisualEffectView()
    var activityIndicator = UIActivityIndicatorView()
    var current_date = String()
    var last_date = String()
    var current_date_link = String()
    var last_date_link = String()
    @IBOutlet weak var backgroundView: BackgroundView!
    //# MARK: - END of variables

    
    
    
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        let myFormatter = DateFormatter()
        let date = Date()
        let calendar = Calendar.current
        let past_date = calendar.date(byAdding: .day, value: -7, to: date)

        
        myFormatter.dateFormat = "MM/dd/yyyy"
        current_date = myFormatter.string(from: date)
        myFormatter.dateFormat = "yyyyMMdd-HHmmss"
        current_date_link = myFormatter.string(from: date)
        myFormatter.dateFormat = "MM/dd/yyyy"
        last_date = myFormatter.string(from: past_date!)
        myFormatter.dateFormat = "yyyyMMdd-HHmmss/"
        last_date_link = myFormatter.string(from: past_date!)
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
        
        //TableView settings
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
        //End of TableView settings
        
        //Setup the loading blur view
        blurEffectView.frame = CGRect(x: 0, y: self.backgroundView.frame.origin.y, width: self.view.frame.size.width, height: self.view.frame.size.height - self.backgroundView.frame.size.height * 2)
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
            data = get_all_sensors(id: Int(station[4]))
            for tmp in data {
                if (tmp.1.count > 10) {
                    var dataEntries : [ChartDataEntry] = []
                    for i in 0...tmp.1.count - 1 {
                        let dataEntry = ChartDataEntry(x: Double(i), y: tmp.1[i])
                        dataEntries.append(dataEntry)
                    }
                    arrayDataEntries.append(dataEntries)
                } else {
                    let dataEntries : [ChartDataEntry] = []
                    arrayDataEntries.append(dataEntries)
                }
            }
        } else {
            data = [("Error", [0.0])]
        }
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

    func get_sensor_values(type: String, id: Int?) -> [Double] {
        var full_url = link_sensor + "0" + "type"
        var res = [Double]()
        
        
        if let unwraped_id = id{
            full_url = link_sensor + String(unwraped_id) + "/" + type + "/" + last_date_link + current_date_link
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
                                            res.append(Double(value)!)
                                        }
                                    }
                                }
                            } else {
                                res = [0.0]
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
            res = [0.0]
            print("Error : the url was broken.")
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        return (res)
    }
    
    func get_all_sensors(id : Int?) -> [(String, [Double])] {
        var sensors = [(String, [Double])]()
        
        
        for i in 0...type.count - 1 {
            var sensor = [0.0]
            sensor = get_sensor_values(type: type[i], id: id)
            sensors.append((type[i], sensor))
        }
        return (sensors)
    }
    
    
    
    
    
    //# MARK: - Table settings
    //Filling the table view with content from the app and the data base
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var charDataSet = LineChartDataSet()
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdendifier)! as! GraphCell
        
        
        cell.loadTextLabel(type: self.sensor_types[indexPath.row], dateFrom: last_date, dateTo: current_date)
        if data[indexPath.row].1.count > 10 {
            charDataSet = LineChartDataSet(values: arrayDataEntries[indexPath.row], label: self.type[indexPath.row])
            let chartData: LineChartData?
            charDataSet.circleRadius = 0.5
            chartData = LineChartData(dataSet: charDataSet)
            cell.lineChartView.data = chartData
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
        return data.count
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
