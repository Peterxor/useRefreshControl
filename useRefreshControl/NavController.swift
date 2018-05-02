//
//  NavController.swift
//  useRefreshControl
//
//  Created by Peter on 2018/4/26.
//  Copyright © 2018年 Peter. All rights reserved.
//

import Foundation
import UIKit


class NavController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.barStyle = .blackTranslucent
        self.navigationBar.titleTextAttributes = [.foregroundColor:UIColor.red]
        self.pushViewController(MenuController(), animated: true)
    }
}
