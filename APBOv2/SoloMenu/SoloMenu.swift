//
//  SoloMenu.swift
//  APBOv2
//
//  Created by 90306670 on 11/23/20.
//  Copyright © 2020 Dhruv Chowdhary. All rights reserved.
//

import SpriteKit

class SoloMenu: SKScene {

/* UI Connections */
var buttonPlay: MSButtonNode!

    
    override func didMove(to view: SKView) {
        /* Setup your scene here */
        
        if let particles = SKEmitterNode(fileNamed: "Starfield") {
                particles.position = CGPoint(x: frame.midX, y: frame.midY)
        //      particles.advanceSimulationTime(60)
                particles.zPosition = -1
                addChild(particles)
        }
 
        /* Set UI connections */
        buttonPlay = self.childNode(withName: "back") as? MSButtonNode
        buttonPlay.selectedHandlers = {
            self.loadMainMenu()
     //       skView.presentScene(scene)
        }
        
        buttonPlay = self.childNode(withName: "endlessButton") as? MSButtonNode
        buttonPlay.selectedHandlers = {
            self.loadGame()
        }
 
    }
    
    func loadGame() {
        /* 1) Grab reference to our SpriteKit view */
        guard let skView = self.view as SKView? else {
            print("Could not get Skview")
            return
        }

        /* 2) Load Game scene */
        guard let scene = GameScene(fileNamed:"GameScene") else {
            print("Could not make GameScene, check the name is spelled correctly")
            return
        }

        /* 3) Ensure correct aspect mode */
        scene.scaleMode = .aspectFill

        /* Show debug */
        skView.showsPhysics = true
        skView.showsDrawCount = true
        skView.showsFPS = true

        /* 4) Start game scene */
        skView.presentScene(scene)
    }
    
    func loadMainMenu() {
        /* 1) Grab reference to our SpriteKit view */
        guard let skView = self.view as SKView? else {
            print("Could not get Skview")
            return
        }

        /* 2) Load Menu scene */
        guard let scene = GameScene(fileNamed:"MainMenu") else {
            print("Could not make GameScene, check the name is spelled correctly")
            return
        }

        /* 3) Ensure correct aspect mode */
        scene.scaleMode = .aspectFill

        /* Show debug */
        skView.showsPhysics = true
        skView.showsDrawCount = true
        skView.showsFPS = true

        /* 4) Start game scene */
        skView.presentScene(scene)
    }
}
