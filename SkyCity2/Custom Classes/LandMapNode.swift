//
//  LandMapNode.swift
//  SkyCity2
//
//  Created by Angela Garrovillas on 11/25/19.
//  Copyright © 2019 Angela Garrovillas. All rights reserved.
//

import SpriteKit
import Foundation

class LandMapNode: SKTileMapNode {
    //MARK: - Properties
    var delegate: NotificationDelegate?
    var plots = [PlotNode]()
    private var preLayoutNode = PlotNode(state: .layout)
    
    //MARK: Init
    override init() {
        let bgTexture = SKTexture(imageNamed: "Grass_Grid_Center")
        
        let bgDefinition = SKTileDefinition(texture: bgTexture, size: CGSize(width: 16, height: 16))
        let bgGroup = SKTileGroup(tileDefinition: bgDefinition)
        let tileSet = SKTileSet(tileGroups: [bgGroup])
        
        super.init(tileSet: tileSet, columns: 24, rows: 32, tileSize: CGSize(width: 16, height: 16))
        fill(with: bgGroup)
        isUserInteractionEnabled = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(handle), name: Notification.Name(NotificationNames.modeChanged.rawValue), object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - Override
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {return}
        movePreLayoutNode(to: touch.location(in: self))
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        changeOutlineColor()
    }
    
    //MARK: Functions
    private func movePreLayoutNode(to location: CGPoint) {
        preLayoutNode.position = location
    }
    
    func placeNewItem() {
        guard checkIfPreLayoutNodeIsValid(), let newNode = self.preLayoutNode.copy() as? PlotNode else {
            return
        }
        newNode.zPosition = 1
        newNode.state = .empty
        newNode.delegate = delegate
        newNode.position = preLayoutNode.position
        newNode.color = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
        plots.append(newNode)
        addChild(newNode)
    }
    
    
    //MARK: Private Functions
    private func checkIfPreLayoutNodeIsValid() -> Bool {
        return !checkIfIntersectingFrames() && checkIfOutOfBounds()
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
    
    private func checkIfOutOfBounds() -> Bool {
        guard let parent = parent else {
            return true
        }
        let preLayoutNodeFrameInParent = CGRect(origin: convert(preLayoutNode.frame.origin, to: parent),
                                                size: preLayoutNode.frame.size)

        return preLayoutNodeFrameInParent.intersection(frame) == preLayoutNodeFrameInParent
    }
    private func changeOutlineColor() {
        preLayoutNode.color = checkIfPreLayoutNodeIsValid() ? #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 0.5543931935) : #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 0.5490956764)
    }
    private func setPreLayoutNode() {
        preLayoutNode.color = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 0.5543931935)
        preLayoutNode.zPosition = 2
        preLayoutNode.isUserInteractionEnabled = false
        addChild(preLayoutNode)
    }
    private func updatePlots(isInteractable: Bool) {
        for plot in plots {
            plot.isUserInteractionEnabled = isInteractable
        }
    }
    
    @objc private func handle(notification: NSNotification) {
        guard let mode = notification.userInfo?["mode"] as? Mode else {
            return
        }
        switch mode {
        case .growing:
            preLayoutNode.removeFromParent()
            updatePlots(isInteractable: true)
        case .plotting:
            setPreLayoutNode()
            updatePlots(isInteractable: false)
        case .planting:
            updatePlots(isInteractable: true)
        }
    }
}
