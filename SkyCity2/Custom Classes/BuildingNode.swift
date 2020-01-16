//
//  BuildingNode.swift
//  SkyCity2
//
//  Created by Angela Garrovillas on 12/12/19.
//  Copyright © 2019 Angela Garrovillas. All rights reserved.
//

import SpriteKit
import UIKit
import UserNotifications
import Foundation

class BuildingNode: SKSpriteNode {
    enum State {
        case empty
        case getStarBits
        case collect
        case layout
    }
    
    //MARK: - Properties
    var plantTime: CFAbsoluteTime?
    var maxTime: Int = 0
    var maxTimeAmount = 10
    var foodValue: Int = 100
    var foodForHarvest: Int = 0
    var mode: Mode = .growing {
        didSet {
            print("changed")
        }
    }
    var delegate: NotificationDelegate?
    var timer: Timer?
    
    var state: State = .layout {
        didSet {
            switch state {
            case .getStarBits:
                color = #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)
                foodForHarvest = foodValue
                plantTime = CFAbsoluteTimeGetCurrent()
                delegate?.makeNotification(title: "SkyCity", message: "Your harvest is ready", timeInterval: Double(maxTimeAmount))
                timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] (_) in
                    self?.handleBuildingUpdates()
                })
                print("planted seeds")
            case .collect:
                color = #colorLiteral(red: 0.9995340705, green: 0.988355577, blue: 0.4726552367, alpha: 1)
                
            case .empty:
                color = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
                plantTime = nil
            default:
                return
            }
            //updatePlotInFirestore()
        }
    }
    
    
    //MARK: - Init
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    convenience init(state: State) {
        self.init(texture: nil, color: #colorLiteral(red: 0.8966712356, green: 0.8913411498, blue: 0.9007685781, alpha: 0.8768461045), size: CGSize(width: 100, height: 100))
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.state = state
        isUserInteractionEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Methods
    private func handleBuildingPressed() {
        if state == .empty {
            state = .getStarBits
        } else if state == .collect {
            NotificationCenter.default.post(name: Notification.Name(NotificationNames.foodIncreased.rawValue), object: self, userInfo: ["foodAmount": foodForHarvest])
            state = .empty
        }
        
    }

    private func handleBuildingUpdates() {
        guard let plantTime = plantTime else {
            return
        }
        let currentTimeAbsolute = CFAbsoluteTimeGetCurrent()
        
        let timePassed = currentTimeAbsolute - plantTime
        switch state {
        case .getStarBits:
            maxTime = min(Int(Float(timePassed) / 1), maxTimeAmount)
            if maxTime == maxTimeAmount {
                state = .collect
                timer?.invalidate()
            }
        default:
            break
        }
    }

}
