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
import Foundation

class PlotNode: SKSpriteNode {
    enum State: String {
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
            case .seeds:
                color = #colorLiteral(red: 0.5738074183, green: 0.5655357838, blue: 0, alpha: 1)
                plantTime = CFAbsoluteTimeGetCurrent()
                delegate?.makeNotification(title: "SkyCity", message: "Your harvest is ready", timeInterval: Double(maxTimeAmount))
                timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] (_) in
                    self?.handleHarvestUpdates()
                })
                print("planted seeds")
            case .harvest:
                color = #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)
            case .empty:
                color = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
                plantTime = nil
            default:
                return
            }
            updatePlotInFirestore()
        }
    }
    
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
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - Touch Override
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard touches.first != nil else {return}
        handlePlotPressed()
    }
    
    //MARK: - Public Functions
    func updateState(from firestoreState: String) {
        switch firestoreState {
        case State.empty.rawValue:
            state = .empty
        case State.seeds.rawValue:
            state = .seeds
        case State.harvest.rawValue:
            state = .harvest
        case State.layout.rawValue:
            state = .layout
        default:
            state = .empty
        }
    }
    
    //MARK: - Private Functions
    private func handlePlotPressed() {
        if state == .empty {
            state = .seeds
        } else if state == .harvest {
            NotificationCenter.default.post(name: Notification.Name(NotificationNames.foodIncreased.rawValue), object: self, userInfo: ["foodAmount": foodValue])
            state = .empty
        }
        
    }

    private func handleHarvestUpdates() {
        guard let plantTime = plantTime else {
            return
        }
        let currentTimeAbsolute = CFAbsoluteTimeGetCurrent()
        
        let timePassed = currentTimeAbsolute - plantTime
        switch state {
        case .seeds:
            maxTime = min(Int(Float(timePassed) / 1), maxTimeAmount)
            if maxTime == maxTimeAmount {
                state = .harvest
                timer?.invalidate()
            }
        default:
            break
        }
    }

    private func updatePlotInFirestore() {
        DispatchQueue.global(qos: .default).async {
            FirestoreService.manager.findIdOfPlot(x: Double(self.position.x), y: Double(self.position.y), userId: FirebaseAuthService.manager.currentUser?.uid ?? "") { (result) in
                FirestoreService.manager.updatePlot(plot: self, result: result) { (newResult) in
                    switch newResult {
                    case .failure(let error):
                        print("Error on PlotNode: \(error)")
                    case .success:
                        print("successful update on plot")
                    }
                }
            }
            
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
