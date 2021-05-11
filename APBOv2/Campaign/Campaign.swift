import Foundation
import SpriteKit

class Campaign: SKScene {
    var levelNodes: [MSButtonNode] = []
    var levelStrings: [String] = []
    let linesMaster = SKNode()
    var completedLevels: [Int] = [-1,0]
    let save = UserDefaults.standard
    let cameraNode =  SKCameraNode()
    var previousCameraPoint = CGPoint.zero
    var backButtonNode: MSButtonNode?
    let panGesture = UIPanGestureRecognizer()
    var currentHandler = {}
    let pulsedRed = SKAction.sequence([
        SKAction.colorize(with: .red, colorBlendFactor: 1.0, duration: 0.15),
        SKAction.wait(forDuration: 0.1),
        SKAction.colorize(with: UIColor.black, colorBlendFactor: 0.5, duration: 0.15)
    ])
    var currentSelectedNode: SKSpriteNode?
    var levelsNoLines: [Int] = []
    
    
    override func didMove(to view: SKView) {
        panGesture.addTarget(self, action: #selector(panGestureAction(_:)))
        view.addGestureRecognizer(panGesture)
    }
    
    override func sceneDidLoad() {
        
        
        addChild(cameraNode)
        camera = cameraNode
        camera?.zPosition = 100
        
        if (save.value(forKey: "completedLevels") != nil) {
            completedLevels = save.value(forKey: "completedLevels") as! [Int]
        } else {
            save.setValue (completedLevels, forKey: "completedLevels")
        }
        
        levelNodes =
            [
                MSButtonNode(imageNamed: "levelInfinity"),
                MSButtonNode(imageNamed: "lvl1"),
                MSButtonNode(imageNamed: "lvl2"),
                MSButtonNode(imageNamed: "lvl3"),
                MSButtonNode(imageNamed: "lvl4"),
                MSButtonNode(imageNamed: "lvl5"),
                MSButtonNode(imageNamed: "hard"),
                MSButtonNode(imageNamed: "expert")
            ]
        
        levelStrings =
            [
                "GameScene",
                "CPLevel1",
                "CPLevel2",
                "CPLevel3",
                "CPLevel4",
                "CPLevel5",
                "TurretBoss",
                "TurretBoss"
            ]
        
        
        backButtonNode = self.childNode(withName: "backButton") as? MSButtonNode
        backButtonNode?.removeFromParent()
        camera?.addChild(backButtonNode!)
        
        // Here is where i position the stuff
        if UIDevice.current.userInterfaceIdiom != .pad {
            if UIScreen.main.bounds.width < 779 {
                backButtonNode!.position.x = -600
                backButtonNode!.position.y =  300
            }
        }
        backButtonNode?.zPosition = -10
        
        backButtonNode!.selectedHandlers = {
            self.view!.removeGestureRecognizer(self.panGesture)
            Global.loadScene(s: "MainMenu")
        }
            
        if let particles = SKEmitterNode(fileNamed: "Starfield") {
            particles.position = CGPoint(x: frame.midX, y: frame.midY)
            //      particles.advanceSimulationTime(60)
            particles.zPosition = -1
            addChild(particles)
        }
        
        for i in 0..<levelNodes.count {
            let node = levelNodes[i]
            node.isUserInteractionEnabled = true
            node.state = .MSButtonStopAlphaChanges
            
            // Scale the node here
            
            node.xScale = 0.16
            node.yScale = 0.16
            
            // Position node
            if i != 0 {
                node.position = levelNodes[i-1].position
            } else {
                node.position.x = -300
            }
            
            node.position.y = CGFloat(-250 + 500 * (i % 2))
            node.position.x += CGFloat(400)
            node.zPosition = 5
            
            node.color = UIColor.black
            
            node.selectedHandlers = {
                node.colorBlendFactor = 0
                
                // Set difficuties for turret bosses
                switch i {
                case 4,5,6,7:
                    UserDefaults.standard.setValue(i-3, forKey: "difficulty")
                default:
                    print("ok")
                }
            }
            
            // Shade Node and set handlers
            if completedLevels.contains(i-1){
                node.selectedHandler = { [self] in
                    node.color = UIColor.black
                    node.colorBlendFactor = 0.4
                    currentSelectedNode = node
                }
                node.selectedHandlers = {
                    self.view!.removeGestureRecognizer(self.panGesture)
                    Global.loadScene(s: self.levelStrings[i])
                }
            } else {
                node.colorBlendFactor = 0.5
                node.selectedHandler = {
                    node.run(self.pulsedRed)
                }
            }
            
            // Does this level have Unique Properties? - add it here in the case switch
            switch i {
            case 0:
                node.position.y = 0
                node.position.x = -300
                node.xScale = 0.3
                node.yScale = 0.3
            case 1:
                node.position.x += 150
            case 4,5,6,7:
                node.xScale = 1
                node.yScale = 1
            default:
                print("should be a normal lvl")
            }
            
            scene?.addChild(node)
        }
        drawLines()
    }
    
    func drawLines(){
        for i in 1..<levelNodes.count {
            // The path and shape for new line
            let newLine = SKShapeNode()
            let drawPath = CGMutablePath()
            
            let node0 = levelNodes[i-1]
            let node1 = levelNodes[i]
            
            drawPath.move(to: node0.position)
            drawPath.addLine(to: node1.position)
            newLine.path = drawPath
            newLine.strokeColor = SKColor.white
            newLine.isUserInteractionEnabled = false
            newLine.zPosition = 0
            newLine.lineWidth += 3
            if !completedLevels.contains(i-1){
                newLine.fillColor = UIColor.darkGray
                newLine.strokeColor = UIColor.darkGray
            }
            linesMaster.addChild(newLine)
        }
        linesMaster.zPosition = -10
        addChild(linesMaster)
    }
    
    @objc func panGestureAction(_ sender: UIPanGestureRecognizer) {
        // The camera has a weak reference, so test it
        guard let camera = self.camera else {
            return
        }
        
        //  let zoomInActionipad = SKAction.scale(to: 1.7, duration: 0.01)
        
        //  camera.run(zoomInActionipad)
        
        // If the movement just began, save the first camera position
        if sender.state == .began {
            currentSelectedNode?.colorBlendFactor = 0
            // If the 420 happens we in trouble
            previousCameraPoint = camera.position
            currentHandler()
            currentHandler = {}
        }
        // Perform the translation
        let translation = sender.translation(in: self.view)
        
        var newPosition = CGPoint(
            x: previousCameraPoint.x + translation.x * -2,
            y: previousCameraPoint.y
        )
        if newPosition.x < 0 { newPosition.x = 0}
        camera.position = newPosition
        
        
    }
    
    
    
}
