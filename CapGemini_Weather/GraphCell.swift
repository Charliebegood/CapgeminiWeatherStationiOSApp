//
//  GraphCell.swift
//  CapGemini_Weather
//
//  Created by Aubert Charles on 13/05/2017.
//  Copyright © 2017 Charles. All rights reserved.
//

import Foundation
import UIKit
import Charts

class GraphCell: UITableViewCell {

    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var lineChartView: LineChartView!
    @IBOutlet weak var dateLeftLabel: UILabel!
    @IBOutlet weak var dateRightLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func loadTextLabel(type: String, dateFrom: String, dateTo: String) {
        typeLabel.text = type
        dateLeftLabel.text = dateFrom
        dateRightLabel.text = dateTo
    }
}
