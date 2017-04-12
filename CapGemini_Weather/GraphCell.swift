//
//  GraphCell.swift
//  CapGemini_Weather
//
//  Created by Aubert Charles on 12/04/2017.
//  Copyright © 2017 Charles. All rights reserved.
//

import Foundation
import UIKit

class GraphCell : UITableViewCell {
    
}

class SerialOperationQueue: OperationQueue
{
    override init()
    {
        super.init()
        maxConcurrentOperationCount = 1
    }
}

class GraphModel
{
    func textForCell(_ names: [String], _ indexPath: IndexPath) -> String
    {
        Thread.sleep(forTimeInterval: 1)
        return (names[indexPath.row])
    }
}
