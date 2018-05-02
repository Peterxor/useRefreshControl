//
//  MenuCell.swift
//  useRefreshControl
//
//  Created by Peter on 2018/4/28.
//  Copyright © 2018年 Peter. All rights reserved.
//

import Foundation
import UIKit

class MenuCell: UITableViewCell{
    var button: UIButton?
    func addButton(){
        button = UIButton.init(frame: self.frame)
        button?.backgroundColor = UIColor.clear
        self.addSubview(button!)
    }
}
