//
//  LoginVC.swift
//  SkyCity2
//
//  Created by Angela Garrovillas on 1/28/20.
//  Copyright © 2020 Angela Garrovillas. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginVC: UIViewController {
    
    
    //MARK: - Objects
    let logInBackground: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "loginBackground")
        return view
    }()
    let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter Email"
        textField.font = UIFont(name: "Verdana", size: 14)
        textField.backgroundColor = .white
        textField.borderStyle = .roundedRect
        textField.autocorrectionType = .no
        textField.addTarget(self, action: #selector(pressReturnOnEmailTextField), for: .primaryActionTriggered)
        return textField
    }()
    let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter Password"
        textField.font = UIFont(name: "Verdana", size: 14)
        textField.backgroundColor = .white
        textField.borderStyle = .roundedRect
        textField.autocorrectionType = .no
        textField.isSecureTextEntry = true
        textField.addTarget(self, action: #selector(attemptLogin), for: .primaryActionTriggered)
        return textField
    }()
    let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Login", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont(name: "Verdana-Bold", size: 14)
        button.backgroundColor = #colorLiteral(red: 0.2800978124, green: 0.2492664158, blue: 0.5517837405, alpha: 1)
        button.layer.cornerRadius = 5
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 2
        
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        button.addTarget(self, action: #selector(attemptLogin), for: .touchUpInside)
        return button
    }()
    let createAccountButton: UIButton = {
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
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        button.addTarget(self, action: #selector(displayForm), for: .touchUpInside)
        return button
    }()
    let logoLabel: UILabel = {
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
    
    //MARK: - Functions
    
    private func makeAlert(with title: String, and message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }
    
    private func segueToGameVC() {
        let gameVC = GameViewController()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = gameVC
    }
    private func loginCurrentUser() {
        if Auth.auth().currentUser != nil {
            segueToGameVC()
        } else {
            setupLogInUI()
        }
    }
    
    //MARK: Objc Functions
    @objc private func pressReturnOnEmailTextField() {
        emailTextField.resignFirstResponder()
        passwordTextField.becomeFirstResponder()
    }
    
    //MARK: Handling Login
    private func handleLoginResponse(result: (Result<(),Error>)) {
        switch result {
        case .success:
            segueToGameVC()
        case .failure(let error):
            makeAlert(with: "Error, could not log in", and: "\(error)")
        }
    }
    
    @objc private func attemptLogin() {
        guard let email = emailTextField.text, !email.isEmpty, let password = passwordTextField.text, !password.isEmpty else {return}
        FirebaseAuthService.manager.loginUser(email: email.lowercased(), password: password) { (result) in
            self.handleLoginResponse(result: result)
        }
    }
    //MARK: Handling SignIn
    private func handleCreateAccountResponse(with result: Result<User, Error>) {
        DispatchQueue.main.async { [weak self] in
            switch result {
            case .success(let user):
                FirestoreService.manager.createAppUser(user: AppUser(from: user)) { [weak self] newResult in
                    self?.handleCreatedUserInFirestore(result: newResult)
                }
            case .failure(let error):
                self?.makeAlert(with: "Error creating user", and: "An error occured while creating new account \(error)")
            }
        }
    }
    private func handleCreatedUserInFirestore(result: Result<(), Error>) {
        switch result {
        case .success:
            segueToGameVC()
           
        case .failure(let error):
            self.makeAlert(with: "Error creating user", and: "An error occured while creating new account \(error)")
        }
    }
    
    @objc func displayForm(){
        let alert = UIAlertController(title: "Sign In", message: "Create an account", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel" , style: .cancel)
        
        let saveAction = UIAlertAction(title: "Submit", style: .default) { (action) -> Void in
            
            guard let email = self.signInEmail?.text, !email.isEmpty, let password = self.signInPassword?.text, !password.isEmpty else {
                self.makeAlert(with: "Required", and: "Fill both fields")
                return
            }
            FirebaseAuthService.manager.createNewUser(email: email.lowercased(), password: password) { (result) in
                switch result {
                case .failure(let error):
                    self.makeAlert(with: "Couldn't create user", and: "Error: \(error)")
                case .success(let newUser):
                    FirestoreService.manager.createAppUser(user: AppUser.init(from: newUser)) { (result) in
                        self.handleLoginResponse(result: result)
                    }
                    
                }
            }
        }
        
        alert.addAction(cancelAction)
        alert.addAction(saveAction)
        
        alert.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = "Enter email address"
            self.signInEmail = textField
        })
        
        alert.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = "Enter password"
            textField.isSecureTextEntry = true
            self.signInPassword = textField
        })
        
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Constraints
    func setupLogInUI() {
        setBackroundImageConstraints()
        setEmailTextFieldConstraints()
        setPasswordTextFieldConstraints()
        setSignInButtonConstraints()
        setLogoLabelConstraints()
        setLoginButtonConstraints()
    }
    func setBackroundImageConstraints() {
        view.addSubview(logInBackground)
        logInBackground.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            logInBackground.topAnchor.constraint(equalTo: view.topAnchor),
            logInBackground.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            logInBackground.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            logInBackground.bottomAnchor.constraint(equalTo: view.bottomAnchor)])
    }
    func setEmailTextFieldConstraints() {
        view.addSubview(emailTextField)
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            emailTextField.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: -150),
            emailTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            emailTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20)])
    }
    func setPasswordTextFieldConstraints() {
        view.addSubview(passwordTextField)
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor,constant: 50),
            passwordTextField.leadingAnchor.constraint(equalTo: emailTextField.leadingAnchor),
            passwordTextField.trailingAnchor.constraint(equalTo: emailTextField.trailingAnchor)])
    }
    func setSignInButtonConstraints() {
        view.addSubview(createAccountButton)
        createAccountButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            createAccountButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            createAccountButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)])
    }
    func setLogoLabelConstraints() {
        view.addSubview(logoLabel)
        logoLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            logoLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 70),
            logoLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)])
    }
    func setLoginButtonConstraints() {
        view.addSubview(loginButton)
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loginButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 30),
            loginButton.centerXAnchor.constraint(equalTo: passwordTextField.centerXAnchor)])
    }

    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        loginCurrentUser()

    }

}




