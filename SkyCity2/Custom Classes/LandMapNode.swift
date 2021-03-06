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
    enum Resources: String {
        case plot
        case house
        case none
    }
    
    //MARK: - Properties
    var delegate: NotificationDelegate?
    var plots = [PlotNode]()
    var savedPlots = [PlotsOfLand]() {
        didSet {
            setupSavedPlots()
        }
    }
    var buildings = [BuildingNode]()
    var savedBuildings = [Buildings]() {
        didSet {
            setupSavedBuildings()
        }
    }
    
    private var preLayoutNode = PlotNode(state: .layout)
    private var preLayoutBuildingNode = BuildingNode(state: .layout)
    
    var resourceState = Resources.none
    
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
        LoadPlots()
        loadBuildings()
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
    
    //MARK: - Functions
    private func movePreLayoutNode(to location: CGPoint) {
        switch resourceState {
        case .plot:
            preLayoutNode.position = location
        case .house:
            preLayoutBuildingNode.position = location
        case .none:
            return
        }
    }
    
    public func placeNewItem() {
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
        saveNew(plot: newNode)
    }
    public func placeNewBuilding() {
        guard isPreLayoutBuildingNodeValid(), let newNode = self.preLayoutBuildingNode.copy() as? BuildingNode else {
            return
        }
        newNode.zPosition = 1
        newNode.state = .empty
        newNode.delegate = delegate
        newNode.position = preLayoutBuildingNode.position
        newNode.color = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        buildings.append(newNode)
        addChild(newNode)
        saveNew(building: newNode)
        
        NotificationCenter.default.post(name: Notification.Name(NotificationNames.foodChanged.rawValue), object: self, userInfo: ["foodAmount": -150])
    }
    
    //MARK: - Private Functions
    private func checkIfPreLayoutNodeIsValid() -> Bool {
        return !checkIfIntersectingFrames() && checkIfOutOfBounds()
    }
    private func isPreLayoutBuildingNodeValid() -> Bool {
        return !checkIfBuildingsIntersect() && checkIfBuildingIsOutOfBounds()
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
    private func checkIfBuildingsIntersect() -> Bool {
        for node in buildings {
            if !preLayoutBuildingNode.intersects(node) {
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
    private func checkIfBuildingIsOutOfBounds() -> Bool {
        guard let parent = parent else {
            return true
        }
        let preLayoutNodeFrameInParent = CGRect(origin: convert(preLayoutBuildingNode.frame.origin, to: parent), size: preLayoutBuildingNode.frame.size)
        return preLayoutNodeFrameInParent.intersection(frame) == preLayoutNodeFrameInParent
    }
    private func changeOutlineColor() {
        switch resourceState {
        case .plot:
            preLayoutNode.color = checkIfPreLayoutNodeIsValid() ? #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 0.5543931935) : #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 0.5490956764)
        case .house:
            preLayoutBuildingNode.color = isPreLayoutBuildingNodeValid() ? #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 0.5543931935) : #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 0.5490956764)
        case .none:
            return
        }
    }
    private func setPreLayoutNode() {
        preLayoutNode.color = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 0.5543931935)
        preLayoutNode.zPosition = 2
        preLayoutNode.isUserInteractionEnabled = false
        addChild(preLayoutNode)
    }
    private func setPreLayoutBuildingNode() {
        preLayoutBuildingNode.color = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 0.5543931935)
        preLayoutBuildingNode.zPosition = 2
        preLayoutBuildingNode.isUserInteractionEnabled = false
        addChild(preLayoutBuildingNode)
    }
    
    //MARK: Firestore, Plots
    private func LoadPlots() {
        DispatchQueue.main.async {
            FirestoreService.manager.getPlotsFor(userID: FirebaseAuthService.manager.currentUser?.uid ?? "") { [weak self] (result) in
                switch result {
                case .failure(let error):
                    print(error)
                case .success(let farmLands):
                    self?.savedPlots = farmLands
                }
            }
        }
    }
    
    private func setupSavedPlots() {
        for plot in savedPlots {
            let newPlot = PlotNode(state: .empty)
            newPlot.delegate = delegate
            newPlot.position = CGPoint(x: plot.x ?? 0, y: plot.y ?? 0)
            newPlot.color = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
            if let plantTime = plot.plantTime {
                if plantTime == 0.0 {
                    newPlot.plantTime = nil
                } else {
                    newPlot.plantTime = CFAbsoluteTime.init(plantTime)
                }
            }
            newPlot.maxTimeAmount = plot.maxAmountTime ?? 10
            newPlot.foodValue = plot.foodValue ?? 100
            newPlot.updateState(from: plot.state ?? "")
            plots.append(newPlot)
            addChild(newPlot)
        }
    }
    private func saveNew(plot: PlotNode) {
        let newSave = PlotsOfLand(x: Double(plot.position.x), y: Double(plot.position.y), plantTime: Double(plot.plantTime ?? 0.0), maxAmountTime: plot.maxTimeAmount, state: plot.state.rawValue, createdBy: FirebaseAuthService.manager.currentUser?.uid ?? "", foodValue: plot.foodValue)
        FirestoreService.manager.createPlot(newPlot: newSave) { (result) in
            switch result {
            case .failure(let error):
                print(error)
            case .success:
                print("successfully saved new plot")
            }
        }
    }
    
    //MARK: Firestore, Buildings
    private func saveNew(building: BuildingNode) {
        let newSave = Buildings(x: Double(building.position.x), y: Double(building.position.y), gettingTime: Double(building.starBitsTime ?? 0.0), maxAmountTime: building.maxTimeAmount, state: building.state.rawValue, createdBy: FirebaseAuthService.manager.currentUser?.uid ?? "", starBitValue: building.starBitValue)
        FirestoreService.manager.createBuilding(newBuilding: newSave) { (result) in
            switch result {
            case .failure(let error):
                print(error)
            case .success:
                print("successfully saved new plot")
            }
        }
    }
    private func loadBuildings() {
        DispatchQueue.main.async {
            FirestoreService.manager.getBuildingsFor(userID: FirebaseAuthService.manager.currentUser?.uid ?? "") { [weak self] (result) in
                switch result {
                case .failure(let error):
                    print(error)
                case .success(let buildingsFromFirestore):
                    self?.savedBuildings = buildingsFromFirestore
                }
            }
        }
    }
    
    private func setupSavedBuildings() {
        for building in savedBuildings {
            let newBuilding = BuildingNode(state: .empty)
            newBuilding.position = CGPoint(x: building.x ?? 0, y: building.y ?? 0)
            newBuilding.color = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            if let starBitTime = building.gettingTime {
                if starBitTime == 0.0 {
                    newBuilding.starBitsTime = nil
                } else {
                    newBuilding.starBitsTime = CFAbsoluteTime.init(starBitTime)
                }
            }
            newBuilding.maxTimeAmount = building.maxAmountTime ?? (60 * 5)
            newBuilding.starBitValue = building.starBitValue ?? 500
            newBuilding.updateState(from: building.state ?? "")
            buildings.append(newBuilding)
            addChild(newBuilding)
        }
    }
    
    //MARK: - Objc Func
    @objc private func handle(notification: NSNotification) {
        guard let mode = notification.userInfo?["mode"] as? Mode else {
            return
        }
        switch mode {
        case .growing:
            preLayoutNode.removeFromParent()
            preLayoutBuildingNode.removeFromParent()
            resourceState = .none
        case .plotting:
            guard let resource = notification.userInfo?["resource"] as? String else {
                return
            }
            if resource == "plot" {
                preLayoutBuildingNode.removeFromParent()
                setPreLayoutNode()
                resourceState = .plot
            } else if resource == "house" {
                preLayoutNode.removeFromParent()
                setPreLayoutBuildingNode()
                resourceState = .house
            }
        case .planting:
            break
        }
    }
}
