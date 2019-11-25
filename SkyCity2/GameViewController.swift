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

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let scene = GameScene(size: view.frame.size)
        let skView = view as! SKView
        skView.showsNodeCount = true
        skView.showsFPS = true
        skView.presentScene(scene)
    }

//    override var shouldAutorotate: Bool {
//        return true
//    }

//    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
//        if UIDevice.current.userInterfaceIdiom == .phone {
//            return .allButUpsideDown
//        } else {
//            return .all
//        }
//    }

    }
