//
//  PlotNode.swift
//  SkyCity2
//
//  Created by Angela Garrovillas on 11/17/19.
//  Copyright © 2019 Angela Garrovillas. All rights reserved.
//

import SpriteKit
import UIKit

class PlotNode: SKSpriteNode {
    enum State {
        case empty
        case seeds
        case harvest
        case layout
    }
    
    var plantTime: CFAbsoluteTime?
    var mode: EditMode = .notEdit
    
    var state: State = .layout {
        didSet {
            if self.state == .seeds {
                print("planted seeds")
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
    //MARK: Touch Override
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {return}
        print("plot touched")
    }
}
