//
//  PlotNode.swift
//  SkyCity2
//
//  Created by Angela Garrovillas on 11/17/19.
//  Copyright © 2019 Angela Garrovillas. All rights reserved.
//

import SpriteKit

class PlotNode: SKShapeNode {
    private var state: State = .empty
    enum State {
        case empty
        case seeds
        case harvest
        case layout
    }
    override init() {
        super.init()
    }
    convenience init(state: State) {
        self.init(rect: CGRect(origin: .zero, size: CGSize(width: 60, height: 60)), cornerRadius: 10)
        self.state = state
        strokeColor = .white
        lineWidth = 4
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var plantTime: CFAbsoluteTime?
}
