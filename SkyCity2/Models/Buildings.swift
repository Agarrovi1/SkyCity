//
//  Buildings.swift
//  SkyCity2
//
//  Created by Angela Garrovillas on 1/29/20.
//  Copyright © 2020 Angela Garrovillas. All rights reserved.
//

import Foundation
struct Buildings {
    let id: String
    let x: Double?
    let y: Double?
    let gettingTime: Double?
    let maxAmountTime: Int?
    let state: String?
    let createdBy: String?
    let starBitValue: Int?
    
    init(x:Double, y:Double, gettingTime: Double, maxAmountTime: Int, state: String, createdBy: String, starBitValue: Int) {
        self.id = UUID.init().description
        self.x = x
        self.y = y
        self.gettingTime = gettingTime
        self.maxAmountTime = maxAmountTime
        self.state = state
        self.createdBy = createdBy
        self.starBitValue = starBitValue
    }
    
    init?(from dict: [String: Any], id: String) {
        guard let x = dict["x"] as? Double,
        let y = dict["y"] as? Double,
        let gettingTime = dict["gettingTime"] as? Double,
        let maxAmountTime = dict["maxAmountTime"] as? Int,
        let state = dict["state"] as? String,
        let createdBy = dict["createdBy"] as? String,
        let starBitValue = dict["starBitValue"] as? Int else { return nil }
        self.id = id
        self.x = x
        self.y = y
        self.gettingTime = gettingTime
        self.maxAmountTime = maxAmountTime
        self.state = state
        self.createdBy = createdBy
        self.starBitValue = starBitValue
    }
    
    var fieldsDict: [String: Any] {
        return [
            "x": self.x ?? 0.0,
            "y": self.y ?? 0.0,
            "gettingTime": self.gettingTime ?? 0.0,
            "maxAmountTime": self.maxAmountTime ?? 0,
            "state": self.state ?? "",
            "createdBy": self.createdBy ?? "",
            "starBitValue": self.starBitValue ?? 0
            
        ]
    }
    
}
