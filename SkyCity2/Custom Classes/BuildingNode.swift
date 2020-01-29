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
    enum State: String {
        case empty
        case getStarBits
        case collect
        case layout
    }
    
    //MARK: - Properties
    var starBitsTime: CFAbsoluteTime?
    var maxTime: Int = 0
    var maxTimeAmount = (60 * 5)
    var foodNeeded = 150
    var starBitValue: Int = 100
    var starBitsForCollecting: Int = 0
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
                starBitsForCollecting = starBitValue
                starBitsTime = CFAbsoluteTimeGetCurrent()
                delegate?.makeNotification(title: "SkyCity", message: "Your harvest is ready", timeInterval: Double(maxTimeAmount))
                timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] (_) in
                    self?.handleBuildingUpdates()
                })
                print("planted seeds")
            case .collect:
                color = #colorLiteral(red: 0.9995340705, green: 0.988355577, blue: 0.4726552367, alpha: 1)
                
            case .empty:
                color = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
                starBitsTime = nil
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
        NotificationCenter.default.addObserver(self, selector: #selector(handleUserInteraction(notification:)), name: NSNotification.Name(NotificationNames.isInteractable.rawValue), object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - Methods
    func updateState(from firestoreState: String) {
        switch firestoreState {
        case State.empty.rawValue:
            state = .empty
        case State.getStarBits.rawValue:
            state = .getStarBits
        case State.collect.rawValue:
            state = .collect
        case State.layout.rawValue:
            state = .layout
        default:
            state = .empty
        }
    }
    
    private func handleBuildingPressed() {
        if state == .empty {
            state = .getStarBits
            postTakeFoodNeed()
        } else if state == .collect {
            postStarBitsIncrease()
            state = .empty
        }
        
    }

    private func handleBuildingUpdates() {
        guard let plantTime = starBitsTime else {
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
    @objc private func handleUserInteraction(notification: NSNotification) {
        guard let isInteractable = notification.userInfo?["isInteractable"] as? Bool else {
            return
        }
        isUserInteractionEnabled = isInteractable
    }
    //MARK: - Notification Center, Post
    private func postStarBitsIncrease() {
        NotificationCenter.default.post(name: Notification.Name(NotificationNames.starBitIncreased.rawValue), object: self, userInfo: ["starBitAmount": starBitsForCollecting])
    }
    private func postTakeFoodNeed() {
        NotificationCenter.default.post(name: Notification.Name(NotificationNames.foodChanged.rawValue), object: self, userInfo: ["foodNeeded": -foodNeeded])
    }
}
