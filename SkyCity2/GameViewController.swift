//
//  GameViewController.swift
//  SkyCity2
//
//  Created by Angela Garrovillas on 11/17/19.
//  Copyright © 2019 Angela Garrovillas. All rights reserved.
//
import UIKit
import SpriteKit
import GameplayKit
import UserNotifications


class GameViewController: UIViewController {
    
    //MARK: - Properties
    
    private var unNotificationCenter: UNUserNotificationCenter!
    private var scene = GameScene()
    
    //MARK: - Objects
    
    
    //MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        askForNotificationPermission()
        setupGameScene()
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    //MARK: - Functions
    func askForNotificationPermission() {
        unNotificationCenter = UNUserNotificationCenter.current()
        unNotificationCenter.delegate = self
        let options: UNAuthorizationOptions = [.alert, .sound]
        unNotificationCenter.requestAuthorization(options: options) { (granted, error) in
            if !granted {
                print("Something went wrong")
            }
        }
    }
    
    private func setupGameScene() {
        let frame = view.frame
        scene = GameScene(size: view.frame.size)
        self.view = SKView(frame: frame)
        let skView = view as! SKView
        skView.showsNodeCount = true
        skView.showsFPS = true
        skView.presentScene(scene)
        scene.sceneDelegate = self
        scene.landNode.delegate = self
    }
    
    
    
//    private func hideSubViews() {
//        logInBackground.isHidden = true
//        emailTextField.isHidden = true
//        passwordTextField.isHidden = true
//        createAccountButton.isHidden = true
//        logoLabel.isHidden = true
//        loginButton.isHidden = true
//    }

    func makePlantActionSheet() {
        let actionSheet = UIAlertController(title: "What to plant?", message: nil, preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        let stopPlanting = UIAlertAction(title: "Stop Planting", style: .destructive) { [weak self] (_) in
            NotificationCenter.default.post(name: Notification.Name(NotificationNames.modeChanged.rawValue), object: self, userInfo: ["mode": Mode.growing])
            self?.postModeChanged(mode: .growing)
        }
        let apple = UIAlertAction(title: "Apple: 10sec, 100 food", style: .default) { [weak self] (_) in
            self?.postModeChanged(mode: .planting)
            self?.postFoodType(foodAmount: 100, maxTimeAmount: 10)
        }
        let pear = UIAlertAction(title: "Pear: 30min, 500 food", style: .default) { [weak self] (_) in
            self?.postModeChanged(mode: .planting)
            self?.postFoodType(foodAmount: 500, maxTimeAmount: (60 * 30))
        }
        actionSheet.addAction(cancel)
        actionSheet.addAction(stopPlanting)
        actionSheet.addAction(apple)
        actionSheet.addAction(pear)
        present(actionSheet, animated: true, completion: nil)
    }
    private func makeEditActionSheet() {
        let actionSheet = UIAlertController(title: "What to build?", message: nil, preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let stopBuilding = UIAlertAction(title: "Stop building", style: .destructive) { [weak self] (_) in
            self?.postModeChanged(mode: .growing)
        }
        let makePlots = UIAlertAction(title: "Make plots of land", style: .default) { [weak self] (_) in
            self?.postModeChanged(mode: .plotting, resource: "plot")
            self?.scene.mode = .plotting
        }
        let makeBuilding = UIAlertAction(title: "Make house, cost 150 food", style: .default) { [weak self] (_) in
            self?.postModeChanged(mode: .plotting, resource: "house")
            self?.scene.mode = .plotting
        }
        actionSheet.addAction(cancel)
        actionSheet.addAction(stopBuilding)
        actionSheet.addAction(makePlots)
        actionSheet.addAction(makeBuilding)
        present(actionSheet, animated: true, completion: nil)
    }
    //MARK: Notification Center, Post
    private func postModeChanged(mode: Mode, resource: String? = nil) {
        var userInfo: [AnyHashable : Any] = [:]
        userInfo["mode"] = mode
        userInfo["resource"] = resource
        NotificationCenter.default.post(name: Notification.Name(NotificationNames.modeChanged.rawValue), object: self, userInfo: userInfo)
    }
    private func postFoodType(foodAmount: Int, maxTimeAmount: Int) {
        NotificationCenter.default.post(name: Notification.Name(NotificationNames.foodType.rawValue), object: self, userInfo: ["foodAmount": foodAmount, "maxTimeAmount": maxTimeAmount])
    }
    
}


extension GameViewController: NotificationDelegate {
    func makeNotification(title: String, message: String,timeInterval: Double) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = message
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let request = UNNotificationRequest(identifier: "SkyCityAlarm", content: content, trigger: trigger)
        unNotificationCenter.add(request) { (error) in
            if let error = error {
                print("Notification Error: \(error)")
            }
        }
    }
}

extension GameViewController: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert,.sound])
    }
}


extension GameViewController: GameSceneDelegate {
    func buttonPressed(senderId: String) {
        if senderId == "plant" {
            makePlantActionSheet()
        } else if senderId == "edit" {
            makeEditActionSheet()
        }
    }
}
