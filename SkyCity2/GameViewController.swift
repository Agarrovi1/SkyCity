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
    
    private var unNotificationCenter: UNUserNotificationCenter!
    
    //MARK: TODO: make login/SignIn here?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let scene = GameScene(size: view.frame.size)
        let skView = view as! SKView
        skView.showsNodeCount = true
        skView.showsFPS = true
        skView.presentScene(scene)
        askForNotificationPermission()
        scene.landNode.delegate = self
    }
    
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
    
    
}

extension GameViewController: NotificationDelegate {
    func makeNotification(title: String, message: String,timeInterval: Double) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = message
        content.sound = .default
        //TODO: inser podcast image into the notification
//        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//        let imageId = "image.png"
//        let filePath = documentsDirectory.appendingPathComponent(imageId)
//        let imageData = currentImage.pngData()
//        do {
//            try imageData?.write(to: filePath)
//            let imageAttachment = try UNNotificationAttachment(identifier: imageId, url: filePath, options: nil)
//            content.attachments = [imageAttachment]
//        } catch {
//            print(error)
//        }
        
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
