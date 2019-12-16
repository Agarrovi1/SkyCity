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
    
    //MARK: - Objects
    var logInBackground: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "loginBackground")
        return view
    }()
    var emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter Email"
        textField.font = UIFont(name: "Verdana", size: 14)
        textField.backgroundColor = .white
        textField.borderStyle = .roundedRect
        textField.autocorrectionType = .no
        return textField
    }()
    lazy var passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter Password"
        textField.font = UIFont(name: "Verdana", size: 14)
        textField.backgroundColor = .white
        textField.borderStyle = .roundedRect
        textField.autocorrectionType = .no
        textField.isSecureTextEntry = true
        //textField.addTarget(self, action: #selector(tryLogIn), for: .primaryActionTriggered)
        return textField
    }()
    lazy var loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Login", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont(name: "Verdana-Bold", size: 14)
        button.backgroundColor = #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1)
        button.layer.cornerRadius = 5
        //button.addTarget(self, action: #selector(tryLogIn), for: .touchUpInside)
        return button
    }()
    var createAccountButton: UIButton = {
        let button = UIButton(type: .system)
        let attributedTitle = NSMutableAttributedString(string: "Dont have an account?  ",attributes: [
            NSAttributedString.Key.font: UIFont(name: "Verdana", size: 14)!,
            NSAttributedString.Key.foregroundColor: UIColor.black])
        attributedTitle.append(NSAttributedString(string: "Sign Up",
                                                  attributes: [NSAttributedString.Key.font: UIFont(name: "Verdana-Bold", size: 14)!,
                                                               
                                NSAttributedString.Key.foregroundColor:  UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)]))
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 10
               // button.addTarget(self, action: #selector(displayForm), for: .touchUpInside)
        return button
    }()
    var logoLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = "SkyCity"
        label.font = UIFont(name: "Baskerville-SemiBoldItalic", size: 50)
        label.textColor = UIColor.white
        label.backgroundColor = .clear
        label.textAlignment = .center
        return label
    }()
    
    
    var signInEmail: UITextField?
    var signInPassword: UITextField?
    
    //MARK: TODO: make login/SignIn here?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = #colorLiteral(red: 0.2800978124, green: 0.2492664158, blue: 0.5517837405, alpha: 1)
        askForNotificationPermission()
        setupLogInUI()
        
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
    
    func setupGameScene() {
        let scene = GameScene(size: view.frame.size)
        let skView = view as! SKView
        skView.showsNodeCount = true
        skView.showsFPS = true
        skView.presentScene(scene)
        scene.landNode.delegate = self
    }
    
    //MARK: - Constraints
    func setupLogInUI() {
        setBackroundImageConstraints()
        setEmailTextFieldConstraints()
        setPasswordTextFieldConstraints()
        setSignInButtonConstraints()
        setLogoLabelConstraints()
    }
    func setBackroundImageConstraints() {
        view.addSubview(logInBackground)
        logInBackground.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            logInBackground.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            logInBackground.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            logInBackground.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            logInBackground.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)])
    }
    func setEmailTextFieldConstraints() {
        logInBackground.addSubview(emailTextField)
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            emailTextField.bottomAnchor.constraint(equalTo: logInBackground.centerYAnchor, constant: -150),
            emailTextField.leadingAnchor.constraint(equalTo: logInBackground.leadingAnchor, constant: 20),
            emailTextField.trailingAnchor.constraint(equalTo: logInBackground.trailingAnchor, constant: -20)])
    }
    func setPasswordTextFieldConstraints() {
        logInBackground.addSubview(passwordTextField)
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor,constant: 50),
            passwordTextField.leadingAnchor.constraint(equalTo: emailTextField.leadingAnchor),
            passwordTextField.trailingAnchor.constraint(equalTo: emailTextField.trailingAnchor)])
    }
    func setSignInButtonConstraints() {
        logInBackground.addSubview(createAccountButton)
        createAccountButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            createAccountButton.bottomAnchor.constraint(equalTo: logInBackground.bottomAnchor, constant: -50),
            createAccountButton.centerXAnchor.constraint(equalTo: logInBackground.centerXAnchor)])
    }
    func setLogoLabelConstraints() {
        logInBackground.addSubview(logoLabel)
        logoLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            logoLabel.topAnchor.constraint(equalTo: logInBackground.topAnchor, constant: 70),
            logoLabel.centerXAnchor.constraint(equalTo: logInBackground.centerXAnchor)])
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
