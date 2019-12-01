//
//  NotificationDelegate.swift
//  SkyCity2
//
//  Created by Angela Garrovillas on 12/1/19.
//  Copyright © 2019 Angela Garrovillas. All rights reserved.
//

import Foundation
protocol NotificationDelegate {
    func makeNotification(title: String, message: String,timeInterval: Double)
}
