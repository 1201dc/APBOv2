import SpriteKit
import StoreKit

class TurretBossMenu: SKScene {
    
    /* UI Connections */
    var buttonPlay: MSButtonNode!
    var backButtonNode: MSButtonNode!
    var useCount = UserDefaults.standard.integer(forKey: "useCount")
    var difficulty = UserDefaults.standard.integer(forKey: "difficulty")
    
    override func didMove(to view: SKView) {
    
        useCount += 1 //Increment the useCount
        UserDefaults.standard.set(useCount, forKey: "useCount")
        if useCount == 1 {
 //           loadTutorial()
        } else {
            if useCount == 6 {
                SKStoreReviewController.requestReview() //Request the review.
            }
            /* Setup your scene here */
            if let particles = SKEmitterNode(fileNamed: "Starfield") {
                particles.position = CGPoint(x: frame.midX, y: frame.midY)
                //      particles.advanceSimulationTime(60)
                particles.zPosition = -1
                addChild(particles)
            }
            Global.sceneShake(shakeCount: 4, intensity: CGVector(dx: 2, dy: 2), shakeDuration: 0.1, sceneview: self.scene!)
            self.run(SKAction.playSoundFileNamed("menuThumpnew", waitForCompletion: false))
            /* Set UI connections */
            backButtonNode = self.childNode(withName: "backButton") as? MSButtonNode
            backButtonNode.selectedHandlers = {
                Global.loadScene(s: "MainMenu")
            }
            
            if UIDevice.current.userInterfaceIdiom != .pad {
                if UIScreen.main.bounds.width < 779 {
                    backButtonNode.position.x = -600
                    backButtonNode.position.y =  300
                }
            }
            
            buttonPlay = self.childNode(withName: "easy") as? MSButtonNode
            buttonPlay.selectedHandlers = {
                self.difficulty = 1
                UserDefaults.standard.set(self.difficulty, forKey: "difficulty")
                self.loadTurretBoss()
            }
            buttonPlay = self.childNode(withName: "medium") as? MSButtonNode
            buttonPlay.selectedHandlers = {
                self.difficulty = 2
                UserDefaults.standard.set(self.difficulty, forKey: "difficulty")
                self.loadTurretBoss()
            }
            buttonPlay = self.childNode(withName: "hard") as? MSButtonNode
            buttonPlay.selectedHandlers = {
                self.difficulty = 3
                UserDefaults.standard.set(self.difficulty, forKey: "difficulty")
                self.loadTurretBoss()
            }
            buttonPlay = self.childNode(withName: "expert") as? MSButtonNode
            buttonPlay.selectedHandlers = {
                self.difficulty = 4
                UserDefaults.standard.set(self.difficulty, forKey: "difficulty")
                self.loadTurretBoss()
            }
        }
    }
    
    func loadTurretBoss() {
        /* 1) Grab reference to our SpriteKit view */
        guard let skView = self.view as SKView? else {
            print("Could not get Skview")
            return
        }

        /* 2) Load Game scene */
        guard let scene = TurretBoss(fileNamed:"TurretBoss") else {
            print("Could not make GameScene, check the name is spelled correctly")
            return
        }

        /* 3) Ensure correct aspect mode */
        scene.scaleMode = .aspectFill

        /* Show debug */
        skView.showsPhysics = false
        skView.showsDrawCount = false
        skView.showsFPS = false

        /* 4) Start game scene */
        skView.presentScene(scene)
    }
    
    func loadTutorial() {
        /* 1) Grab reference to our SpriteKit view */
        guard let skView = self.view as SKView? else {
            print("Could not get Skview")
            return
        }

        /* 2) Load Game scene */
        guard let scene = Tutorial(fileNamed:"Tutorial") else {
            print("Could not make Tutorial, check the name is spelled correctly")
            return
        }

        /* 3) Ensure correct aspect mode */
        scene.scaleMode = .aspectFill

        /* Show debug */
        skView.showsPhysics = false
        skView.showsDrawCount = false
        skView.showsFPS = false

        /* 4) Start game scene */
        skView.presentScene(scene)
    }
}
