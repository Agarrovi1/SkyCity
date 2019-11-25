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
    private var preLayoutNode = PlotNode()
    var editMode: EditMode = .notEdit
    
    
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
        preLayoutNode.run(SKAction.move(to: touch.location(in: self), duration: 0))
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touch land ended")
        print(position)
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        preLayoutNode.run(SKAction.move(to: pos, duration: 0))
        if let n = self.preLayoutNode.copy() as? SKShapeNode {
            n.position = pos
            n.strokeColor = SKColor.blue
            self.addChild(n)
        }
    }
    func touchUp(atPoint pos : CGPoint) {
        preLayoutNode.run(SKAction.move(to: pos, duration: 0))
        if let n = self.preLayoutNode.copy() as? SKShapeNode {
            n.position = pos
            n.strokeColor = SKColor.red
            self.addChild(n)
        }
    }
    
    private func placeNewItem() {
            if let newNode = self.preLayoutNode.copy() as? PlotNode {
                newNode.zPosition = 1
                newNode.position = preLayoutNode.position
                newNode.fillColor = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
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
                preLayoutNode.strokeColor = .red
            } else {
                preLayoutNode.strokeColor = .blue
            }
        }
    func setPreLayoutNode() {
        self.preLayoutNode = PlotNode()
        preLayoutNode.strokeColor = .blue
        preLayoutNode.zPosition = 2
        preLayoutNode.lineWidth = 2.5
        addChild(preLayoutNode)
    }
    
}
