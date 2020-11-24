//
//  MainMenu.swift
//  APBOv2
//
//  Created by 90306670 on 11/18/20.
//  Copyright © 2020 Dhruv Chowdhary. All rights reserved.
//

import SpriteKit

class MainMenu: SKScene {

/* UI Connections */
var buttonPlay: MSButtonNode!
let title = SKLabelNode(text: "APBO")
    
    override func didMove(to view: SKView) {
        /* Setup your scene here */
        title.position = CGPoint(x: frame.midX, y: frame.midY + 200)
        title.fontColor = UIColor.white
    //    title.fontName =
        title.fontSize = 200
        addChild(title)
        
        if let particles = SKEmitterNode(fileNamed: "Starfield") {
                particles.position = CGPoint(x: frame.midX, y: frame.midY)
        //      particles.advanceSimulationTime(60)
                particles.zPosition = -1
                addChild(particles)
        }
        /* Set UI connections */
        buttonPlay = self.childNode(withName: "soloButton") as? MSButtonNode
        buttonPlay.selectedHandler = {
            self.loadSoloMenu()
        }
 /*
        buttonPlay = self.childNode(withName: "onlineButton") as? MSButtonNode
        buttonPlay.selectedHandler = {
           // Add new screen for online and load here
        }
 */
    }
    
    func loadSoloMenu() {
        /* 1) Grab reference to our SpriteKit view */
        guard let skView = self.view as SKView? else {
            print("Could not get Skview")
            return
        }

        /* 2) Load Game scene */
        guard let scene = SKScene(fileNamed:"SoloMenu") else {
            print("Could not make GameScene, check the name is spelled correctly")
            return
        }

        /* 3) Ensure correct aspect mode */
        scene.scaleMode = .aspectFit

        /* Show debug */
        skView.showsPhysics = false
        skView.showsDrawCount = true
        skView.showsFPS = true

        /* 4) Start game scene */
        skView.presentScene(scene)
    }
}
