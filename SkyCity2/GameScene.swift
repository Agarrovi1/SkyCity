//
//  GameScene.swift
//  SkyCity2
//
//  Created by Angela Garrovillas on 11/17/19.
//  Copyright © 2019 Angela Garrovillas. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    
//    private var spinnyNode = PlotNode(state: .empty)
//    addChild(spinnyNode)
//    spinnyNode.position = view.center
    //MARK: -Properties
    var editMode: EditMode = .notEdit
    
    
    //MARK: - Objects
    var landNode = LandMapNode()
    
    var editButton = SKNode()
    var foodLabel = SKLabelNode()
    var starBitsLabel = SKLabelNode()
    var buildButton = SKNode()
    
    
    
    //MARK: - Methods
    private func handleEditButtonPressed(_ location: CGPoint) {
           // Check if the location of the touch is within the button's bounds
           if editButton.contains(location) {
               switch editMode {
               case .edit:
                   print("done editing")
                   editMode = .notEdit
                   buildButton.isHidden = true
               case .notEdit:
                   print("editing mode")
                   editMode = .edit
                   buildButton.isHidden = false
               }
            landNode.editMode = editMode
           }
       }
    private func handleBuildButtonPressed(_ location: CGPoint) {
        if buildButton.contains(location) {
            landNode.placeNewItem()
        }
    }
    
    
    //MARK: - SetUp
    func setCloudBgTexture() {
        let bgTexture = SKTexture(imageNamed: "clouds")
        let bgDefinition = SKTileDefinition(texture: bgTexture, size: CGSize(width: 40, height: 40))
        let bgGroup = SKTileGroup(tileDefinition: bgDefinition)
        let tileSet = SKTileSet(tileGroups: [bgGroup])
        let bgNode = SKTileMapNode(tileSet: tileSet, columns: 24, rows: 24, tileSize: CGSize(width: 40, height: 40))
        bgNode.position = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 2)
        bgNode.setScale(1)
        bgNode.fill(with: bgGroup)
        self.addChild(bgNode)

    }
    func makeEditButton() {
        editButton = SKSpriteNode(color: SKColor.red, size: CGSize(width: 100, height: 44))
        editButton.position = CGPoint(x:self.frame.maxX - 70, y:self.frame.maxY - 70)
        self.addChild(editButton)
    }
    func makeFoodLabel() {
        foodLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        foodLabel.fontSize = 17
        foodLabel.position = CGPoint(x: self.frame.minX + 50, y: self.frame.maxY - 70)
        foodLabel.text = "Food: 0"
        foodLabel.zPosition = 1
        foodLabel.fontColor = .black
        foodLabel.color = .black
        self.addChild(foodLabel)
    }
    func makeStarBitsLabel() {
        starBitsLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        starBitsLabel.fontSize = 17
        starBitsLabel.position = CGPoint(x: foodLabel.position.x, y: foodLabel.position.y - 20)
        starBitsLabel.text = "StarBits: 0"
        starBitsLabel.zPosition = 1
        starBitsLabel.fontColor = .black
        self.addChild(starBitsLabel)
    }
    
    func makeBuildButton() {
        buildButton = SKSpriteNode(color: SKColor.systemBlue, size: CGSize(width: 100, height: 44))
        buildButton.position = CGPoint(x:self.frame.maxX - 70, y:self.frame.minY + 70)
        buildButton.isHidden = true
        self.addChild(buildButton)
    }
    func setupGameUI(view: SKView) {
        setCloudBgTexture()
        addChild(landNode)
        landNode.position = view.center
        makeEditButton()
        makeFoodLabel()
        makeStarBitsLabel()
        makeBuildButton()
        
    }
    
    //MARK: - Override Methods
    override func didMove(to view: SKView) {
        setupGameUI(view: view)
        
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches {
            // Get the location of the touch in this scene
            let location = touch.location(in: self)
            handleEditButtonPressed(location)
            handleBuildButtonPressed(location)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
