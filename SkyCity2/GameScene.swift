//
//  GameScene.swift
//  SkyCity2
//
//  Created by Angela Garrovillas on 11/17/19.
//  Copyright © 2019 Angela Garrovillas. All rights reserved.
//

import SpriteKit
import GameplayKit
import Foundation

enum NotificationNames: String {
    case modeChanged
    case foodChanged
    case showActionSheet
    case foodType
    case isInteractable
    case starBitIncreased
    case editType
    case hideBuildButton
}

protocol GameSceneDelegate: class {
    func buttonPressed(senderId: String)
}

class GameScene: SKScene {
    weak var sceneDelegate: GameSceneDelegate?
    //MARK: -Properties
    var mode: Mode = .growing {
        didSet {
            switch mode {
            case .plotting:
                buildButton.isHidden = false
                plantButton.isHidden = true
                postToPlots(isInteractive: false)
            case .growing:
                buildButton.isHidden = true
                plantButton.isHidden = false
                postToPlots(isInteractive: false)
            case .planting:
                postToPlots(isInteractive: true)
            }
            postToLandModeChanged()
        }
    }
    var foodAmount: Int = 0 {
        didSet {
            foodLabel.text = "Food: \(foodAmount)"
        }
    }
    var starBitsAmount: Int = 0
    var currentAppUser: AppUser? {
        didSet {
            foodAmount = currentAppUser?.food ?? 0
        }
    }

    
    //MARK: - Objects
    var landNode = LandMapNode()
    var editButton = SKNode()
    var foodLabel = SKLabelNode()
    var starBitsLabel = SKLabelNode()
    var buildButton = SKNode()
    var plantButton = SKNode()
    
    
    
    //MARK: - Methods
    private func handleEditButtonPressed() {
        postShowActionSheet(pressed: "edit")
    }
    
    private func handleBuildButtonPressed() {
        switch landNode.resourceState {
        case .house:
            landNode.placeNewBuilding()
        case .plot:
            landNode.placeNewItem()
        case .none:
            return
        }
    }
    private func handlePlantButtonPressed() {
        postShowActionSheet(pressed: "plant")
    }
    private func getAppUser() {
        FirestoreService.manager.getAppUser(id: FirebaseAuthService.manager.currentUser?.uid ?? "") { [weak self] (result) in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let firestoreUser):
                self?.currentAppUser = firestoreUser
            }
        }
    }
    //MARK: Notification Center, Post
    private func postToPlots(isInteractive: Bool) {
        NotificationCenter.default.post(name: Notification.Name(NotificationNames.isInteractable.rawValue), object: self, userInfo: ["isInteractable": isInteractive])
    }
    private func postToLandModeChanged() {
        NotificationCenter.default.post(name: Notification.Name(NotificationNames.modeChanged.rawValue), object: self, userInfo: ["mode": mode])
    }
    private func postShowActionSheet(pressed: String) {
        sceneDelegate?.buttonPressed(senderId: pressed)
    }
    
    //MARK: - Objc Func
    @objc private func handle(notification: Notification) {
        guard let amount = notification.userInfo?["foodAmount"] as? Int else {
            return
        }
        foodAmount += amount
        DispatchQueue.global(qos: .background).async {
            FirestoreService.manager.updateAppUser(id: FirebaseAuthService.manager.currentUser?.uid ?? "", newFoodAmount: self.foodAmount, newStarBitsAmount: self.starBitsAmount) { (result) in
                switch result {
                case .failure(let error):
                    print("Error on GameScene: \(error)")
                case .success:
                    print("updated user")
                }
            }
        }
    }
    
    //MARK: - SetUp
    private func setCloudBgTexture() {
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
    private func makeEditButton() {
        editButton = SKSpriteNode(color: SKColor.red, size: CGSize(width: 100, height: 44))
        editButton.position = CGPoint(x:self.frame.maxX - 70, y:self.frame.maxY - 70)
        self.addChild(editButton)
    }
    private func makePlantButton() {
        plantButton = SKSpriteNode(color: SKColor.green, size: CGSize(width: 100, height: 44))
        plantButton.position = CGPoint(x:self.frame.minX + 70, y:self.frame.minY + 70)
        self.addChild(plantButton)
    }
    private func makeFoodLabel() {
        foodLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        foodLabel.fontSize = 17
        foodLabel.position = CGPoint(x: self.frame.minX + 50, y: self.frame.maxY - 70)
        foodLabel.text = "Food: 0"
        foodLabel.zPosition = 1
        foodLabel.fontColor = .black
        foodLabel.color = .black
        self.addChild(foodLabel)
    }
    private func makeStarBitsLabel() {
        starBitsLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        starBitsLabel.fontSize = 17
        starBitsLabel.position = CGPoint(x: foodLabel.position.x, y: foodLabel.position.y - 20)
        starBitsLabel.text = "StarBits: 0"
        starBitsLabel.zPosition = 1
        starBitsLabel.fontColor = .black
        self.addChild(starBitsLabel)
    }
    
    private func makeBuildButton() {
        buildButton = SKSpriteNode(color: SKColor.systemBlue, size: CGSize(width: 100, height: 44))
        buildButton.position = CGPoint(x:self.frame.maxX - 70, y:self.frame.minY + 70)
        buildButton.isHidden = true
        self.addChild(buildButton)
    }
    private func setupGameUI(view: SKView) {
        setCloudBgTexture()
        addChild(landNode)
        landNode.position = view.center
        makeEditButton()
        makeFoodLabel()
        makeStarBitsLabel()
        makeBuildButton()
        makePlantButton()
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - Override Methods
    override func didMove(to view: SKView) {
        setupGameUI(view: view)
         NotificationCenter.default.addObserver(self, selector: #selector(handle), name: Notification.Name(NotificationNames.foodChanged.rawValue), object: nil)
        
        getAppUser()
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches {
            let location = touch.location(in: self)
            if editButton.contains(location) {
                handleEditButtonPressed()
            } else if buildButton.contains(location) {
                handleBuildButtonPressed()
            } else if plantButton.contains(location) {
                handlePlantButtonPressed()
            }
        }
    }
}
