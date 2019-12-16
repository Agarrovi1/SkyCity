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
    
    init(from user: User) {
        self.email = user.email
        self.uid = user.uid
    }
    
    init?(from dict: [String: Any], id: String) {
        guard let email = dict["email"] as? String else { return nil }
        self.email = email
        self.uid = id
    }
    
    var fieldsDict: [String: Any] {
        return [
            "email": self.email ?? ""
        ]
    }
}
