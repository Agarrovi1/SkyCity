//
//  AppUser.swift
//  SkyCity2
//
//  Created by Angela Garrovillas on 12/16/19.
//  Copyright © 2019 Angela Garrovillas. All rights reserved.
//

import Foundation
import FirebaseAuth

struct AppUser {
    let email: String?
    let uid: String
    let food: Int?
    let starBits: Int?
    
    init(from user: User) {
        self.email = user.email
        self.uid = user.uid
        food = 0
        starBits = 0
    }
    
    init?(from dict: [String: Any], id: String) {
        guard let email = dict["email"] as? String,
        let food = dict["food"] as? Int,
        let starBits = dict["starBits"] as? Int else { return nil }
        self.email = email
        self.uid = id
        self.food = food
        self.starBits = starBits
    }
    
    var fieldsDict: [String: Any] {
        return [
            "email": self.email ?? "",
            "food": self.food ?? 0,
            "starBits": self.starBits ?? 0
        ]
    }
}
