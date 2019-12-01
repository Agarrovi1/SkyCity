//
//  PlotNode.swift
//  SkyCity2
//
//  Created by Angela Garrovillas on 11/17/19.
//  Copyright © 2019 Angela Garrovillas. All rights reserved.
//

import SpriteKit
import UIKit
import UserNotifications

class PlotNode: SKSpriteNode {
    enum State {
        case empty
        case seeds
        case harvest
        case layout
    }
    
    //MARK: - Properties
    var plantTime: CFAbsoluteTime?
    var maxTime: Int = 0
    var maxTimeAmount = 10
    var foodValue: Int = 100
    var mode: EditMode = .notEdit
    var delegate: NotificationDelegate?
    var gameSceneDelegate: LabelDelegate?
    
    var state: State = .layout {
        didSet {
            switch state {
            case .seeds:
                color = #colorLiteral(red: 0.5738074183, green: 0.5655357838, blue: 0, alpha: 1)
                plantTime = CFAbsoluteTimeGetCurrent()
                delegate?.makeNotification(title: "SkyCity", message: "Your harvest is ready", timeInterval: Double(maxTimeAmount))
                print("planted seeds")
            case .harvest:
                color = #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)
            case .empty:
                color = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
            default:
                return
            }
            
        }
    }
    
    
//    override init() {
//        super.init()
//    }
//    convenience init(state: State) {
//        self.init(rect: CGRect(origin: .zero, size: CGSize(width: 60, height: 60)), cornerRadius: 10)
//        self.state = state
//        strokeColor = .blue
//        lineWidth = 4
//    }
    
    //MARK: - Init
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    convenience init(state: State) {
        self.init(texture: nil, color: #colorLiteral(red: 0.8966712356, green: 0.8913411498, blue: 0.9007685781, alpha: 0.8768461045), size: CGSize(width: 60, height: 60))
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.state = state
        isUserInteractionEnabled = true
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //MARK: - Touch Override
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard touches.first != nil else {return}
        handleSwitchOnMode()
    }
    
    
    //MARK: - Functions
    func harvestUpdate() {
        guard let plantTime = plantTime else {return}
        let currentTimeAbsolute = CFAbsoluteTimeGetCurrent()
        
        let timePassed = currentTimeAbsolute - plantTime
        switch state {
        case .seeds:
            maxTime = min(Int(Float(timePassed) / 1), maxTimeAmount)
            if maxTime == maxTimeAmount {
                state = .harvest
            }
        default:
            break
        }
    }
    private func handleSwitchOnMode() {
        switch mode {
        case .plant:
            state = .seeds
        case .notEdit:
            if state == .harvest {
                gameSceneDelegate?.updateFoodLabel(amount: foodValue)
                state = .empty
            }
        default:
            return
        }
    }
    

    
    //MARK: TODO: refactor this to make an updating label?
    /*
     func updateStockingTimerText() {
       let stockingTimeTotal = CFTimeInterval(Float(maxAmount) * stockingSpeed)
       let currentTime = CFAbsoluteTimeGetCurrent()
       let timePassed = currentTime - lastStateSwitchTime
       let stockingTimeLeft = stockingTimeTotal - timePassed
       stockingTimer.text = String(format: "%.0f", stockingTimeLeft)
     }

     */
    
}
