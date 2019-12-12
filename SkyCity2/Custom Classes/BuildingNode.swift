//
//  BuildingNode.swift
//  SkyCity2
//
//  Created by Angela Garrovillas on 12/12/19.
//  Copyright © 2019 Angela Garrovillas. All rights reserved.
//

import UIKit
import SpriteKit

class BuildingNode: SKSpriteNode {
    enum State {
        case empty
        case getStarBits
        case collect
        case layout
    }
    
    //MARK: - Property
    var state: State = .layout
    
    
    //MARK: - Init
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    convenience init(state: State) {
        self.init(texture: nil, color: #colorLiteral(red: 0.8966712356, green: 0.8913411498, blue: 0.9007685781, alpha: 0.8768461045), size: CGSize(width: 80, height: 80))
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.state = state
        isUserInteractionEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Things
    
}
