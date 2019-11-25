//
//  LandMapNode.swift
//  SkyCity2
//
//  Created by Angela Garrovillas on 11/25/19.
//  Copyright © 2019 Angela Garrovillas. All rights reserved.
//

import SpriteKit

class LandMapNode: SKTileMapNode {
    var plots = [PlotNode]()
    private var preLayoutNode = PlotNode(state: .layout)
    var editMode: EditMode = .notEdit {
        didSet {
            switch editMode {
            case .notEdit:
                preLayoutNode.removeFromParent()
            case .edit:
                setPreLayoutNode()
            }
        }
    }
    
    
    override init() {
        let bgTexture = SKTexture(imageNamed: "Grass_Grid_Center")
        
        let bgDefinition = SKTileDefinition(texture: bgTexture, size: CGSize(width: 16, height: 16))
        let bgGroup = SKTileGroup(tileDefinition: bgDefinition)
        let tileSet = SKTileSet(tileGroups: [bgGroup])

        super.init(tileSet: tileSet, columns: 24, rows: 32, tileSize: CGSize(width: 16, height: 16))
        fill(with: bgGroup)
        isUserInteractionEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {return}
        preLayoutNode.position = touch.location(in: self)
        changeOutlineColor()
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        
    }
    
    
    
    func placeNewItem() {
            if let newNode = self.preLayoutNode.copy() as? PlotNode, !checkIfIntersectingFrames() {
                newNode.zPosition = 1
                newNode.position = preLayoutNode.position
                newNode.color = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
                plots.append(newNode)
                self.addChild(newNode)
                print(newNode.frame)
            }
        }
        private func checkIfIntersectingFrames() -> Bool {
            for node in plots {
                if !preLayoutNode.intersects(node) {
                    continue
                } else {
                    return true
                }
            }
            
            return false
        }
        private func changeOutlineColor() {
            if checkIfIntersectingFrames() {
                preLayoutNode.color = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 0.5490956764)
            } else {
                preLayoutNode.color = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 0.5543931935)
            }
        }
    func setPreLayoutNode() {
        preLayoutNode.color = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 0.5543931935)
        preLayoutNode.zPosition = 2
        addChild(preLayoutNode)
    }
    
}
