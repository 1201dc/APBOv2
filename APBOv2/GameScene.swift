//
//  GameScene.swift
//  APBOv2
//
//  Created by 90306670 on 10/20/20.
//  Copyright © 2020 Dhruv Chowdhary. All rights reserved.
//

import SpriteKit
import CoreMotion

let degreesToRadians = CGFloat.pi / 180
let radiansToDegrees = 180 / CGFloat.pi
let maxHealth = 100
let healthBarWidth: CGFloat = 40
let healthBarHeight: CGFloat = 4
let cannonCollisionRadius: CGFloat = 70
let playerCollisionRadius: CGFloat = 10
let shotCollisionRadius: CGFloat = 20

enum CollisionType: UInt32 {
    case player = 1
    case pilot = 16
    case playerWeapon = 2
    case enemy = 4
    case enemyWeapon = 8
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    var backButtonNode: MSButtonNode!
    var pauseButtonNode: MSButtonNode!
    var turnButtonNode: MSButtonNode!
    var shootButtonNode: MSButtonNode!
    var restartButtonNode: MSButtonNode!
    
    let playerHealthBar = SKSpriteNode()
    let cannonHealthBar = SKSpriteNode()
    var playerHP = maxHealth
    var cannonHP = maxHealth
    var isPlayerAlive = true
    var isGameOver = false
    var varisPaused = 1 //1 is false
    var playerShields = 1
    var waveNumber = 0
    var levelNumber = 0
    let turnButton = SKSpriteNode(imageNamed: "button")
    let shootButton = SKSpriteNode(imageNamed: "button")
    //    let turretSprite = SKSpriteNode(imageNamed: "turretshooter")
    //    let cannonSprite = SKSpriteNode(imageNamed: "turretbase")
    let waves = Bundle.main.decode([Wave].self, from: "waves.json")
    let enemyTypes = Bundle.main.decode([EnemyType].self, from: "enemy-types.json")
    let positions = Array(stride(from: -320, through: 320, by: 80))
    let player = SKSpriteNode(imageNamed: "player")
    let pilot = SKSpriteNode(imageNamed: "pilot")
    let shot = SKSpriteNode(imageNamed: "bullet")
    var pilotForward = false
    var pilotDirection = CGFloat(0.000)
    var lastUpdateTime: CFTimeInterval = 0
    var count = 0
    var doubleTap = 0;
    let thruster1 = SKEmitterNode(fileNamed: "Thrusters")
    let rotate = SKAction.rotate(byAngle: -1, duration: 0.5)
    var direction = 0.0
    let dimPanel = SKSpriteNode(color: UIColor.black, size: CGSize(width: 2000, height: 1000) )
    
    let points = SKLabelNode(text: "0")
    var numPoints = 0
    let pointsLabel = SKLabelNode(text: "Points")
    
    var numAmmo = 3
    var regenAmmo = false
    
     let scaleAction = SKAction.scale(to: 2.2, duration: 0.4)
    
    
    let bullet1 = SKSpriteNode(imageNamed: "bullet")
     let bullet2 = SKSpriteNode(imageNamed: "bullet")
     let bullet3 = SKSpriteNode(imageNamed: "bullet")
    
    
    
    override func didMove(to view: SKView) {
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        //size = view.bounds.size
        backgroundColor = SKColor(red: 14.0/255, green: 23.0/255, blue: 57.0/255, alpha: 1)
        if let particles = SKEmitterNode(fileNamed: "Starfield") {
                particles.position = CGPoint(x: frame.midX, y: frame.midY)
        //      particles.advanceSimulationTime(60)
                particles.zPosition = -1
                addChild(particles)
        }
        
        
            addChild(bullet1)
            addChild(bullet2)
            addChild(bullet3)
        
        self.dimPanel.zPosition = 50
        self.dimPanel.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        self.addChild(self.dimPanel)
        self.dimPanel.alpha = 0
                
        points.position = CGPoint(x: frame.midX, y: frame.maxY-135)
        points.zPosition = 2
        points.fontColor = UIColor.white
        points.fontSize = 70
        points.fontName = "Menlo Regular-Bold"
        addChild(points)
        pointsLabel.position = CGPoint(x: frame.midX, y: frame.maxY-70)
        pointsLabel.zPosition = 2
        pointsLabel.fontColor = UIColor.white
        pointsLabel.fontSize = 45
        pointsLabel.fontName = "Menlo Regular-Bold"
        addChild(pointsLabel)
        
        player.name = "player"
        player.position.x = frame.midX-700
        player.position.y = frame.midY-80
        player.zPosition = 1
        addChild(player)

        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.texture!.size())
        player.physicsBody?.categoryBitMask = CollisionType.player.rawValue
        player.physicsBody?.collisionBitMask = CollisionType.enemy.rawValue | CollisionType.enemyWeapon.rawValue
        player.physicsBody?.contactTestBitMask = CollisionType.enemy.rawValue | CollisionType.enemyWeapon.rawValue
        player.physicsBody?.isDynamic = false
        
        pilot.physicsBody = SKPhysicsBody(texture: pilot.texture!, size: pilot.texture!.size())
        pilot.physicsBody?.categoryBitMask = CollisionType.pilot.rawValue
        pilot.physicsBody?.collisionBitMask = CollisionType.enemy.rawValue | CollisionType.enemyWeapon.rawValue
        pilot.physicsBody?.contactTestBitMask = CollisionType.enemy.rawValue | CollisionType.enemyWeapon.rawValue
        pilot.physicsBody?.isDynamic = false

        
        backButtonNode = self.childNode(withName: "backButton") as? MSButtonNode
        backButtonNode.alpha = 0
        backButtonNode.selectedHandlers = {
            /* 1) Grab reference to our SpriteKit view */
            guard let skView = self.view as SKView? else {
                print("Could not get Skview")
                return
            }

            /* 2) Load Menu scene */
            guard let scene = SoloMenu(fileNamed:"SoloMenu") else {
                print("Could not make GameScene, check the name is spelled correctly")
                return
            }

            /* 3) Ensure correct aspect mode */
            scene.scaleMode = .aspectFit

            /* Show debug */
            skView.showsPhysics = false
            skView.showsDrawCount = false
            skView.showsFPS = false

            /* 4) Start game scene */
            skView.presentScene(scene)
        }
        
        restartButtonNode = self.childNode(withName: "restartButton") as? MSButtonNode
        restartButtonNode.alpha = 0
        restartButtonNode.selectedHandlers = {
            /* 1) Grab reference to our SpriteKit view */
            guard let skView = self.view as SKView? else {
                print("Could not get Skview")
                return
            }

            /* 2) Load Menu scene */
            guard let scene = GameScene(fileNamed:"GameScene") else {
                print("Could not make GameScene, check the name is spelled correctly")
                return
            }

            /* 3) Ensure correct aspect mode */
            scene.scaleMode = .aspectFit

            /* Show debug */
            skView.showsPhysics = false
            skView.showsDrawCount = false
            skView.showsFPS = false

            /* 4) Start game scene */
            skView.presentScene(scene)
        }
        
        pauseButtonNode = self.childNode(withName: "pause") as? MSButtonNode
        pauseButtonNode.selectedHandlers = {
            if !self.isGameOver {
                if self.varisPaused == 0 {
                    self.varisPaused = 1
                    self.scene?.view?.isPaused = false
                    self.backButtonNode.alpha = 0
                    self.restartButtonNode.alpha = 0
                    self.dimPanel.alpha = 0

                }
                else {
                    self.backButtonNode.alpha = 1
                    self.restartButtonNode.alpha = 1
                    self.dimPanel.alpha = 0.3
                    self.varisPaused = 0
                    let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { (timer) in
                        if self.backButtonNode.alpha == 1
                        {
                            self.scene?.view?.isPaused = true
                        }
                    }
                }
            }
        }

        
        turnButtonNode = self.childNode(withName: "turnButton") as? MSButtonNode
        turnButtonNode.selectedHandler = {
            if self.varisPaused==1 && self.isPlayerAlive {
                self.turnButtonNode.alpha = 0.6
                self.count = 1
                self.direction = -0.08
            
                if (self.doubleTap==1) {
                    self.player.zRotation = self.player.zRotation - 1.5708;
                    let movement = SKAction.moveBy(x: 55 * cos(self.player.zRotation), y: 55 * sin(self.player.zRotation), duration: 0.2)
                    self.player.run(movement)
                    self.thruster1?.particleColorSequence = nil
                    self.thruster1?.particleColorBlendFactor = 1.0
                    
          
                            self.thruster1?.particleColor = UIColor(red: 240.0/255, green: 50.0/255, blue: 53.0/255, alpha:1)
                                
                    
                    self.doubleTap = 0
                    }
                    else {
                        self.doubleTap = 1
                       //  self.thruster1?.particleColor = UIColor(red: 67/255, green: 181/255, blue: 169/255, alpha:1)
                        let timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { (timer) in
                            self.doubleTap = 0
                        }
                    }
            
            } else if !self.isPlayerAlive {
                self.direction = -0.08
            }
        }
        turnButtonNode.selectedHandlers = {
            
            self.turnButtonNode.alpha = 0.8
            let timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { (timer) in
          self.thruster1?.particleColor = UIColor(red: 67/255, green: 181/255, blue: 169/255, alpha:1)
            }
            if self.varisPaused == 1 {
                self.direction = 0
            }
        }
        
        
        shootButtonNode = self.childNode(withName: "shootButton") as? MSButtonNode
        shootButtonNode.selectedHandler = {
            
            self.shootButtonNode.alpha = 0.6
            
            if self.varisPaused==1 && self.isPlayerAlive {
                if self.isPlayerAlive {
                    if self.numAmmo > 0 {
                    
                        
                        if self.numAmmo == 3 {
                                    self.bullet1.removeFromParent()
                                    }
                                    else if self.numAmmo == 2 {
                                          self.bullet2.removeFromParent()
                                    }
                                    else if self.numAmmo == 1 {
                                        self.bullet3.removeFromParent()
                                    }
                        
                        let shot = SKSpriteNode(imageNamed: "bullet")
                        shot.name = "playerWeapon"
                        shot.position = CGPoint(x: self.player.position.x + cos(self.player.zRotation)*40, y: self.player.position.y + sin(self.player.zRotation)*40)
                        shot.physicsBody = SKPhysicsBody(rectangleOf: shot.size)
                        shot.physicsBody?.categoryBitMask = CollisionType.playerWeapon.rawValue
                        shot.physicsBody?.collisionBitMask = CollisionType.enemy.rawValue | CollisionType.enemyWeapon.rawValue
                        shot.physicsBody?.contactTestBitMask = CollisionType.enemy.rawValue | CollisionType.enemyWeapon.rawValue
                        self.addChild(shot)
                    
                        let movement = SKAction.moveBy(x: 1500 * cos(self.player.zRotation), y: 1500 * sin(self.player.zRotation), duration: 2.6)
                        let sequence = SKAction.sequence([movement, .removeFromParent()])
                        shot.run(sequence)
                        
                        self.numAmmo = self.numAmmo - 1
                    
                        let recoil = SKAction.moveBy(x: -8 * cos(self.player.zRotation), y: -8 * sin(self.player.zRotation), duration: 0.01)
                    
                        self.player.run(recoil)
                
                    /*
 self.player.position = CGPoint(x:self.player.position.x - cos(self.player.zRotation) * 50 ,y:self.player.position.y - sin(self.player.zRotation) * 50)
                    
                    */
                    
                        self.sceneShake(shakeCount: 1, intensity: CGVector(dx: 1.2*cos(self.player.zRotation), dy: 1.2*sin(self.player.zRotation)), shakeDuration: 0.04)
                        
                    }
                }
            } else {
                self.pilotForward = true
            }
        }
        
        shootButtonNode.selectedHandlers = {
            self.pilotDirection = self.pilot.zRotation
            self.shootButtonNode.alpha = 0.8
            self.pilotForward = false
        }
        
        thruster1?.position = CGPoint(x: -30, y: 0)
        thruster1?.targetNode = self.scene
        player.addChild(thruster1!)
      
        let turnTimer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { (timer) in
            self.player.zRotation = self.player.zRotation + 1.2 * CGFloat(self.direction)
            self.pilot.zRotation = self.pilot.zRotation + 1.2 * CGFloat(self.direction)
        }
}

    
 
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (isGameOver) {
           if let newScene = SKScene(fileNamed: "GameScene") {
            newScene.scaleMode = .aspectFit
            self.dimPanel.alpha = 0
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            view?.presentScene(newScene, transition: reveal)
            }
        }
        guard isGameOver else { return }

        let touch = touches.first
        let positionInScene = touch!.location(in: self)
        let touchedNode = self.atPoint(positionInScene)

        
        /*
         
        
        if let name = touchedNode.name {
            if name == "btn" {
                let fadeAlpha = SKAction.fadeAlpha(to: 0.8 , duration: 0.1)
                turnButton.run(fadeAlpha)
                count = 1
                direction = 0.1
                if (doubleTap == 1) {
                    self.player.zRotation = self.player.zRotation + 1.0;
                    let movement = SKAction.moveBy(x: 55 * cos(player.zRotation), y: 55 * sin(player.zRotation), duration: 0.2)
                               player.run(movement)
                    doubleTap = 0
                }
                else {
                    doubleTap = 1
                }
            }
            else {
         //       count = 0
            }
       }
        if let name = touchedNode.name {
            if name == "shoot" {
                let fadeAlpha = SKAction.fadeAlpha(to: 0.8 , duration: 0.1)
                    shootButton.run(fadeAlpha)
        
                let shot = SKSpriteNode(imageNamed: "bullet")
                shot.name = "playerWeapon"
                shot.position = player.position
                shot.physicsBody = SKPhysicsBody(rectangleOf: shot.size)
                shot.physicsBody?.categoryBitMask = CollisionType.playerWeapon.rawValue
                shot.physicsBody?.collisionBitMask = CollisionType.enemy.rawValue | CollisionType.enemyWeapon.rawValue
                shot.physicsBody?.contactTestBitMask = CollisionType.enemy.rawValue | CollisionType.enemyWeapon.rawValue
                addChild(shot)
                let movement = SKAction.moveBy(x: 1024 * cos(player.zRotation), y: 1024 * sin(player.zRotation), duration: 1.8432)
                let sequence = SKAction.sequence([movement, .removeFromParent()])
                    shot.run(sequence)
            }
        }
 */
    }
 
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let fadeAlpha = SKAction.fadeAlpha(to: 1.0 , duration: 0.1)
        let squishNormal = SKAction.scale(to: 1.0, duration: 0.05)
        turnButton.run(fadeAlpha)
        turnButton.run(squishNormal)
        shootButton.run(fadeAlpha)
        shootButton.run(squishNormal)
    }
    
    override func update(_ currentTime: TimeInterval) {
        if isPlayerAlive {
            player.position = CGPoint(x:player.position.x + cos(player.zRotation) * 3.5 ,y:player.position.y + sin(player.zRotation) * 3.5)
            pilotDirection = player.zRotation - 3.141592/2
            let revolve1 = SKAction.moveBy(x: -CGFloat(50 * cos(2 * currentTime )), y: -CGFloat(50 * sin(2 * currentTime)), duration: 0.000001)
               
            let revolve2 = SKAction.moveBy(x: -CGFloat(50 * cos(2 * currentTime + 2.0944)), y: -CGFloat(50 * sin(2 * currentTime + 2.0944)), duration: 0.000001)
               
            let revolve3 = SKAction.moveBy(x: -CGFloat(50 * cos(2 * currentTime + 4.18879)), y: -CGFloat(50 * sin(2 * currentTime + 4.18879)), duration: 0.000001)
               
            bullet1.run(revolve1)
            bullet2.run(revolve2)
            bullet3.run(revolve3)
               
            bullet1.position = player.position
            bullet2.position = player.position
            bullet3.position = player.position
        
            if player.position.y < frame.minY + 35 {
                player.position.y = frame.minY + 35
            } else if player.position.y > frame.maxY - 35 {
                player.position.y = frame.maxY - 35
            }
            if player.position.x < frame.minX + 35  {
                player.position.x = frame.minX + 35
            } else if player.position.x > frame.maxX - 35 {
                player.position.x = frame.maxX - 35
            }
        
            if self.numAmmo < 3 {
                if !self.regenAmmo {
                    self.regenAmmo = true
                    let ammoTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { (timer) in
                    self.numAmmo = self.numAmmo + 1
                     
                        if self.numAmmo == 1 {
                             self.addChild(self.bullet3)
                        }
                        else if self.numAmmo == 2 {
                             self.addChild(self.bullet2)
                        }
                        else if self.numAmmo == 3 {
                             self.addChild(self.bullet1)
                        }
                   
                        self.regenAmmo = false
                    }
                }
            }
        } else {
            bullet1.removeFromParent()
            bullet2.removeFromParent()
            bullet3.removeFromParent()
            
            if self.pilotForward {
                pilot.position = CGPoint(x:pilot.position.x + cos(pilot.zRotation+3.141592/2) * 2 ,y:pilot.position.y + sin(pilot.zRotation+3.141592/2) * 2)
            } else {
                pilot.position = CGPoint(x:pilot.position.x + cos(pilotDirection + 3.141592/2) * 0.5 ,y:pilot.position.y + sin(pilotDirection + 3.141592/2) * 0.5)
            }
            
            if pilot.position.y < frame.minY + 20 {
                pilot.position.y = frame.minY + 20
            } else if pilot.position.y > frame.maxY - 20 {
                pilot.position.y = frame.maxY - 20
            }
            if pilot.position.x < frame.minX + 20  {
                pilot.position.x = frame.minX + 20
            } else if player.position.x > frame.maxX - 20 {
                pilot.position.x = frame.maxX - 20
            }
        }
                for child in children {
                    if child.frame.maxX < 0 {
                        if !frame.intersects(child.frame) {
                            child.removeFromParent()
                        }
                    }
                }
                
                let activeEnemies = children.compactMap { $0 as? EnemyNode }
                if activeEnemies.isEmpty {
                    createWave()
                }
                
                for enemy in activeEnemies {
                    guard frame.intersects(enemy.frame) else { continue }
                    
                    if enemy.lastFireTime + 1 < currentTime {
                        enemy.lastFireTime = currentTime
                        
                        if Int.random(in: 0...2) == 0 || Int.random(in: 0...2) == 1 {
                            enemy.fire()
                        }
                    }
                }
        
     /*
        let deltaTime = max(1.0/30, currentTime - lastUpdateTime)
        lastUpdateTime = currentTime
        
        updatePlayer(deltaTime)
        updateTurret(deltaTime)
        checkShipCannonCollision()
        checkShotCannonCollision()
     */
    
   /*
    func updatePlayer(_ dt: CFTimeInterval) {
        
        player.position = CGPoint(x:player.position.x + cos(player.zRotation) * 2.5 ,y:player.position.y + sin(player.zRotation) * 2.5)
       
        
        if player.position.y < frame.minY + 35 {
            player.position.y = frame.minY + 35
        } else if player.position.y > frame.maxY-35 {
            player.position.y = frame.maxY - 35
        }
        
        if player.position.x < frame.minX + 80 {
            player.position.x = frame.minX + 80
        } else if player.position.x > frame.maxX-80 {
            player.position.x = frame.maxX - 80

                    }
      */
        
      //  thruster1?.position = CGPoint(x:player.position.x + 25 , y:player.position.y - 25 )
    
      //  thruster1?.zRotation = player.zRotation
        //hi2
    
    }
    
    func createWave() {
        guard !isGameOver else { return }
        
        if waveNumber == waves.count {
            levelNumber += 1
            waveNumber = 0
        }
        
        let currentWave = waves[waveNumber]
        waveNumber += 1
        
        let maximumEnemyType = min(enemyTypes.count, levelNumber + 1)
        let enemyType = Int.random(in: 0..<maximumEnemyType)
        
        let enemyOffsetX: CGFloat = 100
        let enemyStartX = 800
        
        if currentWave.enemies.isEmpty {
            for(index, position) in positions.shuffled().enumerated() {
                let enemy = EnemyNode(type: enemyTypes[enemyType], startPosition: CGPoint(x: enemyStartX, y: position), xOffset: enemyOffsetX * CGFloat(index * 3), moveStright: true)
                addChild(enemy)
            }
        } else {
            for enemy in currentWave.enemies {
                let node = EnemyNode(type: enemyTypes[enemyType], startPosition: CGPoint(x: enemyStartX, y: positions[enemy.position]), xOffset: enemyOffsetX * enemy.xOffset, moveStright: enemy.moveStraight)
                addChild(node)
            }
        }
    }
   
 /*   func updateTurret(_ dt: CFTimeInterval) {
      let deltaX = player.position.x - turretSprite.position.x
      let deltaY = player.position.y - turretSprite.position.y
      let angle = atan2(deltaY, deltaX)
      
      turretSprite.zRotation = angle - 270 * degreesToRadians
    }
    
    func updateHealthBar(_ node: SKSpriteNode, withHealthPoints hp: Int) {
      let barSize = CGSize(width: healthBarWidth, height: healthBarHeight);
      
      let fillColor = UIColor(red: 113.0/255, green: 202.0/255, blue: 53.0/255, alpha:1)
      let borderColor = UIColor(red: 35.0/255, green: 28.0/255, blue: 40.0/255, alpha:1)
      
      // create drawing context
      UIGraphicsBeginImageContextWithOptions(barSize, false, 0)
      guard let context = UIGraphicsGetCurrentContext() else { return }
      
      // draw the outline for the health bar
      borderColor.setStroke()
      let borderRect = CGRect(origin: CGPoint.zero, size: barSize)
      context.stroke(borderRect, width: 1)
      
      // draw the health bar with a colored rectangle
      fillColor.setFill()
      let barWidth = (barSize.width - 1) * CGFloat(hp) / CGFloat(maxHealth)
      let barRect = CGRect(x: 0.5, y: 0.5, width: barWidth, height: barSize.height - 1)
      context.fill(barRect)
      
      // extract image
      guard let spriteImage = UIGraphicsGetImageFromCurrentImageContext() else { return }
      UIGraphicsEndImageContext()
      
      // set sprite texture and size
      node.texture = SKTexture(image: spriteImage)
      node.size = barSize
    }
    
    func checkShipCannonCollision() {
       let deltaX = player.position.x - turretSprite.position.x
       let deltaY = player.position.y - turretSprite.position.y
       
       let distance = sqrt(deltaX * deltaX + deltaY * deltaY)
       guard distance <= cannonCollisionRadius + playerCollisionRadius else { return }
      
       
       let offsetDistance = cannonCollisionRadius + playerCollisionRadius - distance
       let offsetX = deltaX / distance * offsetDistance
       let offsetY = deltaY / distance * offsetDistance
       player.position = CGPoint(
         x: player.position.x + offsetX,
         y: player.position.y + offsetY
       )
       
  

       updateHealthBar(cannonHealthBar, withHealthPoints: cannonHP)
  
     }
    func checkShotCannonCollision() {
         let deltaX = shot.position.x - turretSprite.position.x
         let deltaY = shot.position.y - turretSprite.position.y
         
         let distance = sqrt(deltaX * deltaX + deltaY * deltaY)
         guard distance <= cannonCollisionRadius + shotCollisionRadius else { return }
        
         
         let offsetDistance = cannonCollisionRadius + shotCollisionRadius - distance
         let offsetX = deltaX / distance * offsetDistance
         let offsetY = deltaY / distance * offsetDistance
         shot.position = CGPoint(
           x: shot.position.x + offsetX,
           y: shot.position.y + offsetY
         )
   
         cannonHP = max(0, cannonHP - 20)

         updateHealthBar(cannonHealthBar, withHealthPoints: cannonHP)
        
          shot.removeFromParent()
    
       }
  */
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        let sortedNodes = [nodeA, nodeB].sorted { $0.name ?? "" < $1.name ?? "" }
        
        let firstNode = sortedNodes[0]
        let secondNode = sortedNodes[1]
        
        if secondNode.name == "player" {
            guard !isGameOver else { return }
            
            
            playerShields -= 1
            if playerShields == 0 {
                isPlayerAlive = false
                if let explosion = SKEmitterNode(fileNamed: "ShipExplosion") {
                    explosion.position = player.position
                    addChild(explosion)
                }
                pilot.name = "pilot"
                pilot.size = CGSize(width: 40, height: 40)
                pilot.zRotation = player.zRotation - 3.141592/2
                pilot.position = player.position
                pilot.zPosition = 1
                addChild(pilot)
    //            gameOver()
                secondNode.removeFromParent()
            }
            
            firstNode.removeFromParent()
        } else if secondNode.name == "pilot" {
            if let explosion = SKEmitterNode(fileNamed: "Explosion") {
                explosion.position = pilot.position
                addChild(explosion)
            }
            gameOver()
            secondNode.removeFromParent()
        }
            
            else if let enemy = firstNode as? EnemyNode {
            enemy.shields -= 1
            
            if enemy.shields == 0 {
                if let explosion = SKEmitterNode(fileNamed: "Explosion") {
                    explosion.position = enemy.position
                    addChild(explosion)
                }
                enemy.removeFromParent()
                numPoints += enemy.scoreinc
                points.text = "\(numPoints)"
            }
            if let explosion = SKEmitterNode(fileNamed: "Explosion") {
                explosion.position = enemy.position
                addChild(explosion)
            }
            secondNode.removeFromParent()
        } else {
            if let explosion = SKEmitterNode(fileNamed: "Explosion") {
                explosion.position = secondNode.position
                addChild(explosion)
            }
            firstNode.removeFromParent()
            secondNode.removeFromParent()
        }
    }
    
    func sceneShake(shakeCount: Int, intensity: CGVector, shakeDuration: Double) {
      let sceneView = self.scene!.view! as UIView
      let shakeAnimation = CABasicAnimation(keyPath: "position")
      shakeAnimation.duration = shakeDuration / Double(shakeCount)
      shakeAnimation.repeatCount = Float(shakeCount)
      shakeAnimation.autoreverses = true
      shakeAnimation.fromValue = NSValue(cgPoint: CGPoint(x: sceneView.center.x - intensity.dx, y: sceneView.center.y - intensity.dy))
      shakeAnimation.toValue = NSValue(cgPoint: CGPoint(x: sceneView.center.x + intensity.dx, y: sceneView.center.y + intensity.dy))
      sceneView.layer.add(shakeAnimation, forKey: "position")
    }
    
    func gameOver() {
        isPlayerAlive = false
        isGameOver = true
        self.sceneShake(shakeCount: 2, intensity: CGVector(dx: 2, dy: 2), shakeDuration: 0.1)
        
        let playAgain = SKLabelNode(text: "Tap to Play Again")
        playAgain.position = CGPoint(x: frame.midX, y: frame.midY - 250)
        playAgain.zPosition = 100
        playAgain.fontColor = UIColor.white
        playAgain.fontName = "AvenirNext-Bold"
        playAgain.fontSize = 60
        addChild(playAgain)
        
        self.pauseButtonNode.alpha = 0
        self.turnButtonNode.alpha = 0
        self.shootButtonNode.alpha = 0
        self.backButtonNode.alpha = 1
        self.bullet1.alpha = 0
        self.bullet2.alpha = 0
        self.bullet3.alpha = 0
        
        let gameOver = SKSpriteNode(imageNamed: "gameOver")
        self.dimPanel.alpha = 0.3
        gameOver.zPosition = 100
        gameOver.run(scaleAction)
        gameOver.position = CGPoint(x: frame.midY, y: frame.midY)
        gameOver.size = CGSize(width: 619, height: 118)
            addChild(gameOver)
    }

}
