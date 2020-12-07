import SpriteKit
import CoreMotion

class TurretBossScene: SKScene, SKPhysicsContactDelegate {
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
    var varisPaused = 1
    var playerShields = 1
    var waveNumber = 0
    var levelNumber = 0
    let turnButton = SKSpriteNode(imageNamed: "button")
    let shootButton = SKSpriteNode(imageNamed: "button")
    let turretSprite = SKSpriteNode(imageNamed: "turretshooter")
    let cannonSprite = SKSpriteNode(imageNamed: "turretbase")
    let waves = Bundle.main.decode([Wave].self, from: "waves.json")
    let enemyTypes = Bundle.main.decode([EnemyType].self, from: "enemy-types.json")
    let positions = Array(stride(from: -320, through: 320, by: 80))
    let player = SKSpriteNode(imageNamed: "player")
    let pilot = SKSpriteNode(imageNamed: "pilot")
    var pilotForward = false
    var pilotDirection = CGFloat(0.000)
    let pilotThrust1 = SKEmitterNode(fileNamed: "PilotThrust")
    let spark1 = SKEmitterNode(fileNamed: "Spark")
    let shot = SKSpriteNode(imageNamed: "bullet")
    var lastUpdateTime: CFTimeInterval = 0
    var count = 0
    var doubleTap = 0;
    let thruster1 = SKEmitterNode(fileNamed: "Thrusters")
    let rotate = SKAction.rotate(byAngle: -1, duration: 0.5)
    var rotation = CGFloat(0)
    var direction = 0.0
    let dimPanel = SKSpriteNode(color: UIColor.black, size: CGSize(width: 2000, height: 1000) )

    
    var lastFireTime: Double = 0
    
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

                particles.zPosition = -1
                addChild(particles)
        }
 
        player.name = "player"
        player.position.x = frame.midX-700
        player.position.y = frame.midY-80
        player.zPosition = 1
        addChild(player)
    
        addChild(bullet1)
        addChild(bullet2)
        addChild(bullet3)


        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.texture!.size())
        player.physicsBody?.categoryBitMask = CollisionType.player.rawValue
        player.physicsBody?.collisionBitMask = CollisionType.enemy.rawValue | CollisionType.enemyWeapon.rawValue
        player.physicsBody?.contactTestBitMask = CollisionType.enemy.rawValue | CollisionType.enemyWeapon.rawValue
        player.physicsBody?.isDynamic = false
        
        
        cannonSprite.position = CGPoint(x: frame.midX, y: frame.midY)
        cannonSprite.zPosition = 0
          addChild(cannonSprite)
                
        pilot.size = CGSize(width: 40, height: 40)
        pilot.physicsBody = SKPhysicsBody(texture: pilot.texture!, size: pilot.size)
              pilot.physicsBody?.categoryBitMask = CollisionType.pilot.rawValue
              pilot.physicsBody?.collisionBitMask = CollisionType.enemy.rawValue | CollisionType.enemyWeapon.rawValue
              pilot.physicsBody?.contactTestBitMask = CollisionType.enemy.rawValue | CollisionType.enemyWeapon.rawValue
              pilot.physicsBody?.isDynamic = false
        
        self.dimPanel.zPosition = 50
         self.dimPanel.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
         self.addChild(self.dimPanel)
         self.dimPanel.alpha = 0
        
        turretSprite.name = "turretSprite"
        turretSprite.physicsBody = SKPhysicsBody(texture: turretSprite.texture!, size: turretSprite.texture!.size())

        turretSprite.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(turretSprite)
        turretSprite.zPosition = 4
     
        turretSprite.physicsBody?.categoryBitMask = CollisionType.enemy.rawValue
        turretSprite.physicsBody?.collisionBitMask = CollisionType.player.rawValue | CollisionType.playerWeapon.rawValue | CollisionType.pilot.rawValue
        turretSprite.physicsBody?.contactTestBitMask = CollisionType.player.rawValue | CollisionType.playerWeapon.rawValue | CollisionType.pilot.rawValue
 
 
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
            guard let scene = TurretBossScene(fileNamed:"TurretBoss") else {
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
                    self.children.map{($0 as SKNode).isPaused = false}
                    self.backButtonNode.alpha = 0
                    self.restartButtonNode.alpha = 0
                    self.dimPanel.alpha = 0

            //        self.dimPanel.removeFromParent()
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
                            self.children.map{($0 as SKNode).isPaused = true}
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
                   
                       if (self.doubleTap==1) {
                           self.player.zRotation = self.player.zRotation - 3.141592/2 + self.rotation
                           let movement = SKAction.moveBy(x: 55 * cos(self.player.zRotation), y: 55 * sin(self.player.zRotation), duration: 0.2)
                           self.player.run(movement)
                           self.thruster1?.particleColorSequence = nil
                           self.thruster1?.particleColorBlendFactor = 1.0
                           
                            self.thruster1?.particleColor = UIColor(red: 240.0/255, green: 50.0/255, blue: 53.0/255, alpha:1)
                                       
                        self.rotation = 0
                           self.doubleTap = 0
                           }
                           else {
                        self.direction = -0.08
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
                
            
                    self.sceneShake(shakeCount: 1, intensity: CGVector(dx: 1.2*cos(self.player.zRotation), dy: 1.2*sin(self.player.zRotation)), shakeDuration: 0.04)
                }
                }
            } else {
                           self.pilotForward = true
                           self.pilotThrust1?.particleLifetime = 0.5
                       }
        }
        shootButtonNode.selectedHandlers = {
            self.pilotDirection = self.pilot.zRotation
            self.shootButtonNode.alpha = 0.8
            self.pilotForward = false
            self.pilotThrust1?.particleLifetime = 0
        }
        
        
        thruster1?.position = CGPoint(x: -30, y: 0)
        thruster1?.targetNode = self.scene
        player.addChild(thruster1!)
        
        pilotThrust1?.position = CGPoint(x: 0, y: -20)
              pilotThrust1?.targetNode = self.scene
              pilotThrust1?.particleLifetime = 0
              pilot.addChild(pilotThrust1!)
              
              spark1?.position = CGPoint(x: 0, y: 0)
                    spark1?.targetNode = self.scene
                    spark1?.particleLifetime = 0
              pilot.addChild(spark1!)
      

        addChild(cannonHealthBar)
               cannonHealthBar.position = CGPoint(
                 x: cannonSprite.position.x,
                 y: cannonSprite.position.y - cannonSprite.size.height/2 - 10
               )
               
               updateHealthBar(cannonHealthBar, withHealthPoints: cannonHP)

        let turnTimer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { (timer) in
            self.player.zRotation = self.player.zRotation + 1.2*CGFloat(self.direction)
            self.pilot.zRotation = self.pilot.zRotation + 1.2 * CGFloat(self.direction)
            if self.doubleTap == 1 {
                self.rotation = self.rotation - 1.2 * CGFloat(self.direction)
            } else {
                self.rotation = 0
            }
    }
}


    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isGameOver {
           if let newScene = TurretBossScene(fileNamed: "TurretBoss") {
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

        let deltaTime = max(1.0/30, currentTime - lastUpdateTime)
        lastUpdateTime = currentTime
              
        updateTurret(deltaTime)
            if isPlayerAlive {
        player.position = CGPoint(x:player.position.x + cos(player.zRotation) * 3.5 ,y:player.position.y + sin(player.zRotation) * 3.5)
        
        bullet1.position = player.position
        bullet2.position = player.position
        bullet3.position = player.position
                
        let revolve1 = SKAction.moveBy(x: -CGFloat(50 * cos(2 * currentTime )), y: -CGFloat(50 * sin(2 * currentTime)), duration: 0.000001)
        
         let revolve2 = SKAction.moveBy(x: -CGFloat(50 * cos(2 * currentTime + 2.0944)), y: -CGFloat(50 * sin(2 * currentTime + 2.0944)), duration: 0.000001)
        
        let revolve3 = SKAction.moveBy(x: -CGFloat(50 * cos(2 * currentTime + 4.18879)), y: -CGFloat(50 * sin(2 * currentTime + 4.18879)), duration: 0.000001)
        
        
    
        bullet1.run(revolve1)
        bullet2.run(revolve2)
       bullet3.run(revolve3)
        
           
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
                       pilot.position = CGPoint(x:pilot.position.x + cos(pilotDirection + 3.141592/2) * 0.9 ,y:pilot.position.y + sin(pilotDirection + 3.141592/2) * 0.9)
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
                
        if lastFireTime + 1 < currentTime {
                lastFireTime = currentTime
                if Int.random(in: 0...2) == 0 || Int.random(in: 0...2) == 1 {
                    shootTurret()
                }
        }
                for child in children {
                    if child.frame.maxX < 0 {
                        if !frame.intersects(child.frame) {
                            child.removeFromParent()
                        }
                    }
                }
    }
    
       func updateTurret(_ dt: CFTimeInterval) {
        if !isGameOver {
            if isPlayerAlive {
                let deltaX = player.position.x - turretSprite.position.x
                let deltaY = player.position.y - turretSprite.position.y
                let angle = atan2(deltaY, deltaX)
                turretSprite.zRotation = angle - 270 * degreesToRadians
            } else {
                let deltaX = pilot.position.x - turretSprite.position.x
                let deltaY = pilot.position.y - turretSprite.position.y
                let angle = atan2(deltaY, deltaX)
                turretSprite.zRotation = angle - 270 * degreesToRadians
            }
        }
           }
    
    func shootTurret() {
        if !isGameOver {
            let shot = SKSpriteNode(imageNamed: "enemy2Weapon")
            shot.name = "TurretWeapon"
            shot.zRotation = turretSprite.zRotation
            
            shot.physicsBody = SKPhysicsBody(rectangleOf: shot.size)
            shot.physicsBody?.categoryBitMask = CollisionType.enemyWeapon.rawValue
            shot.physicsBody?.collisionBitMask = CollisionType.player.rawValue
            shot.physicsBody?.contactTestBitMask = CollisionType.player.rawValue
            shot.physicsBody?.mass = 0.001
            shot.zPosition = 1
            shot.position = turretSprite.position
  
            addChild(shot)
            let movement = SKAction.moveBy(x: 1024 * cos(turretSprite.zRotation-90 * degreesToRadians), y: 1024 * sin(turretSprite.zRotation-90 * degreesToRadians), duration: 1.8432)
            let sequence = SKAction.sequence([movement, .removeFromParent()])
            shot.run(sequence)
        }
    }
    
    
    func updateHealthBar(_ node: SKSpriteNode, withHealthPoints hp: Int) {
      let barSize = CGSize(width: 250, height: 20);
      
      let fillColor = UIColor(red: 113.0/255, green: 202.0/255, blue: 73.0/255, alpha:1)
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
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        let sortedNodes = [nodeA, nodeB].sorted { $0.name ?? "" < $1.name ?? "" }
        
        let firstNode = sortedNodes[0]
        let secondNode = sortedNodes[1]
        
        
        if firstNode.name == "player" && secondNode.name == "turretSprite" {
            
            if let explosion = SKEmitterNode(fileNamed: "Explosion") {
                           explosion.position = pilot.position
                           addChild(explosion)
            }
            gameOverScreen()
        }
        if secondNode.name == "player" {
            
            
            playerShields -= 1
            if playerShields == 0 {
                isPlayerAlive = false
                if let explosion = SKEmitterNode(fileNamed: "ShipExplosion") {
                    explosion.position = firstNode.position
                    addChild(explosion)
                }
            }

            pilot.name = "pilot"
            pilot.size = CGSize(width: 40, height: 40)
                         pilot.zRotation = player.zRotation - 3.141592/2
                         pilot.position = player.position
                         pilot.zPosition = 1
                         addChild(pilot)
             //            gameOver()
                            
                            
                          firstNode.removeFromParent()
                         secondNode.removeFromParent()
            
            
                         let timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { (timer) in //5 sec delay
                                              self.spark1?.particleLifetime = 2
                                  let timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { (timer) in
                                     
                                     self.spark1?.particleLifetime = 0
                                    self.player.position = self.pilot.position
                                    self.isPlayerAlive = true
                                     self.addChild(self.player)
                                     self.pilot.removeFromParent()
                                   
                                    self.playerShields += 1
                                }
                                                   }
            
            playerShields -= 1
               
            if playerShields == 0 {
                isPlayerAlive = false
                self.player.removeFromParent()
            }
            
            //firstNode.removeFromParent()
        
        } else if secondNode.name == "pilot" {
            if let explosion = SKEmitterNode(fileNamed: "Explosion") {
                explosion.position = pilot.position
                addChild(explosion)
                //shot.removeFromParent()
            }
            gameOverScreen()
            secondNode.removeFromParent()
        }
        else if secondNode.name == "turretSprite" {
      
            
            if let explosion = SKEmitterNode(fileNamed: "Explosion") {
                explosion.position = firstNode.position
                addChild(explosion)
            }
            cannonHP = max(0, cannonHP - 10)
            updateHealthBar(cannonHealthBar, withHealthPoints: cannonHP)
            shot.removeFromParent()
            firstNode.removeFromParent()
            
            print("hi")
            //gameOverScreen()
        }
        
        if cannonHP == 0 {
                victoryScreen()
        }
        
            /*
        
                  else if let enemy = firstNode as? EnemyNode {
            enemy.shields -= 1
            
            if enemy.shields == 0 {
                if let explosion = SKEmitterNode(fileNamed: "Explosion") {
                    explosion.position = enemy.position
                    addChild(explosion)
                    print("a")
                }
                enemy.removeFromParent()
                print("1")
   
            }
  /*          if let explosion = SKEmitterNode(fileNamed: "Explosion") {
                explosion.position = enemy.position
                addChild(explosion)
                print("b")
            }
            secondNode.removeFromParent()
            print("2")
        } else {
            if isPlayerAlive {
            if let explosion = SKEmitterNode(fileNamed: "Explosion") {
                explosion.position = secondNode.position
                addChild(explosion)
                print("c")
            }
            firstNode.removeFromParent()
         //   secondNode.removeFromParent()
    
            print("d")
        }
        */
        
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
    
    func gameOverScreen() {
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
        self.backButtonNode.alpha = 1
        self.turnButtonNode.alpha = 0
        self.shootButtonNode.alpha = 0
         self.dimPanel.alpha = 0.3
        
        self.bullet1.alpha = 0
        self.bullet2.alpha = 0
        self.bullet3.alpha = 0
        

        let gameOver = SKSpriteNode(imageNamed: "gameOver")
        gameOver.run(scaleAction)
        
        gameOver.position = CGPoint(x: frame.midX, y: frame.midY)
        gameOver.zPosition = 100
        gameOver.size = CGSize(width: 619, height: 118)
            addChild(gameOver)
    }
    func victoryScreen() {
        isPlayerAlive = false
        isGameOver = true
        direction = -0.1
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
         self.dimPanel.alpha = 0.3
        
           self.bullet1.alpha = 0
           self.bullet2.alpha = 0
           self.bullet3.alpha = 0
        
        let victory = SKSpriteNode(imageNamed: "victory")
        victory.run(scaleAction)
        victory.position = CGPoint(x: frame.midX, y: frame.midY)
        victory.zPosition = 100
            addChild(victory)
    }


}
