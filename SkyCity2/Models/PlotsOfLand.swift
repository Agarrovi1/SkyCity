//
//  PlotsOfLand.swift
//  SkyCity2
//
//  Created by Angela Garrovillas on 12/16/19.
//  Copyright © 2019 Angela Garrovillas. All rights reserved.
//

import Foundation
struct PlotsOfLand {
    let id: String
    let x: Double?
    let y: Double?
    let plantTime: Double?
    let maxAmountTime: Int?
    let state: String?
    
    init(x:Double, y:Double, plantTime: Double, maxAmountTime: Int, state: String) {
        self.id = UUID.init().description
        self.x = x
        self.y = y
        self.plantTime = plantTime
        self.maxAmountTime = maxAmountTime
        self.state = state
    }
    
    init?(from dict: [String: Any], id: String) {
        guard let x = dict["x"] as? Double,
        let y = dict["y"] as? Double,
        let plantTime = dict["plantTime"] as? Double,
        let maxAmountTime = dict["maxAmountTime"] as? Int,
        let state = dict["state"] as? String else { return nil }
        self.id = id
        self.x = x
        self.y = y
        self.plantTime = plantTime
        self.maxAmountTime = maxAmountTime
        self.state = state
    }
    
    var fieldsDict: [String: Any] {
        return [
            "x": self.x ?? 0.0,
            "y": self.y ?? 0.0,
            "plantTime": self.plantTime ?? 0.0,
            "maxAmountTime": self.maxAmountTime ?? 0,
            "state": self.state ?? ""
            
        ]
    }
    
}
