import Firebase
import SpriteKit

class LobbyMenu: SKScene {
    var backButtonNode: MSButtonNode!
    var startButtonNode: MSButtonNode!
    
    var lobbyLabelText = SKLabelNode(text: "Lobby")
    
    
    var codeLabel = SKLabelNode(text: "00000")
    var playercountLabel = SKLabelNode(text: "1/6")
    var playerLabel = SKNode()
    var playerLabelParent = SKNode()
    var user1 = SKLabelNode(text: "user1")
    var randInt = 0
    
    var modeImageButtonNode: MSButtonNode!
    let modeArray = ["ffa", "astroball", "infection"]
    var i = 0
    
    var mapImageButtonNode: MSButtonNode!
    var mapArray = ["OnlineCubis", "OnlineTrisen", "OnlineHex"]
    var j = 0
    
    var colorButtonNode: MSButtonNode!
    var colorIndex = 0
    var kickButtonNode: MSButtonNode!
    var list: [String] = []
    
    
    let cameraNode =  SKCameraNode()
    var previousCameraPoint = CGPoint.zero
    let panGesture = UIPanGestureRecognizer()
    var currentHandler = {}
    
    let intToColor: Dictionary = [
        0: "player",
        1: "apboBlue",
        2: "apboBlack",
        3: "apboGreen",
        4: "apboOrange",
        5: "apboPink",
        6: "apboPurple",
        7: "apboWhite",
        8: "apboYellow",
    ]
    let intToColorInfection: Dictionary = [
        0: "apboGreen",
        1: "apboWhite",
    ]
    
    
    override func didMove(to view: SKView) {
        DataPusher.PushData(path: "Games/\(Global.gameData.gameID)/Cosmetics/PlayerSkin/\(Global.playerData.playerID)", Value: Global.gameData.selectedSkin.rawValue)
        DataPusher.PushData(path: "Games/\(Global.gameData.gameID)/Cosmetics/PlayerTrail/\(Global.playerData.playerID)", Value: Global.gameData.selectedTrail.rawValue)
        Global.gameData.gameState = GameStates.LobbyMenu
        
        MultiplayerHandler.ref.child("Games/\(Global.gameData.gameID)/PlayerList").observeSingleEvent(of: .value) { snapshot in
            var playerList: [String] = []
            for child in snapshot.children {
                let e = child as! DataSnapshot
                if e.value as! String == "PePeNotGone"{
                    playerList.append(e.key)
                }
            }
            self.setPlayerList(playerList: playerList)
        }
        
        
        
        panGesture.addTarget(self, action: #selector(panGestureAction(_:)))
        view.addGestureRecognizer(panGesture)
        
        
        
        addChild(cameraNode)
        camera = cameraNode
        camera?.zPosition = 100
        
        
        if let particles = SKEmitterNode(fileNamed: "Starfield") {
            particles.position = CGPoint(x: frame.midX, y: frame.midY)
            //      particles.advanceSimulationTime(60)
            particles.zPosition = -1
            addChild(particles)
        }
        self.sceneShake(shakeCount: 4, intensity: CGVector(dx: 2, dy: 2), shakeDuration: 0.1)
        self.run(SKAction.playSoundFileNamed("menuThumpnew", waitForCompletion: false))
        
        backButtonNode = self.childNode(withName: "backButton") as? MSButtonNode
        backButtonNode?.removeFromParent()
        camera?.addChild(backButtonNode!)
        
        backButtonNode?.zPosition = 2
        backButtonNode.selectedHandlers = {
            self.view!.removeGestureRecognizer(self.panGesture)
            // if host give host to someone else || if no one destroy lobby/code || if not host just leave
            Global.gameData.ResetGameData(toLobby: false)
            Global.loadScene(s: "OnlineMenu")
        }
        if UIDevice.current.userInterfaceIdiom != .pad {
            if UIScreen.main.bounds.width < 779 {
                backButtonNode.position.x = -600
                backButtonNode.position.y =  300
            }
        }
        
        
     
        
        user1.position = CGPoint(x: frame.midX - 140, y: frame.midY)
        user1.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        setupLabel(label: user1)
        user1.fontSize = 90
        
        
        
        
        
        
        
        let effect = SKEffectNode()
        camera?.addChild(effect)
        
        let effectBackground = SKEffectNode()
        camera?.addChild(effectBackground)
//
//        effect.zPosition = 11

        let backgroundSpace = SKShapeNode()
        
        let backgroundwidth = 2000
        let backgroundheight = 2000
        backgroundSpace.path = UIBezierPath(roundedRect: CGRect(x: -backgroundwidth/2, y: -backgroundheight/2, width: backgroundwidth, height: backgroundheight), cornerRadius: 40).cgPath
        backgroundSpace.position = CGPoint(x: frame.midX, y: frame.midY)
        backgroundSpace.fillColor = UIColor.black
        backgroundSpace.zPosition = -420
        
        effectBackground.addChild(backgroundSpace)
        
        
        let backgroundholewidth = 1150
        let backgroundholeheight = 580
        let backgroundHole = SKShapeNode()
     
        backgroundHole.path = UIBezierPath(roundedRect: CGRect(x: -backgroundholewidth/2, y: -backgroundholeheight/2, width: backgroundholewidth, height: backgroundholeheight), cornerRadius: 40).cgPath
        backgroundHole.position = CGPoint(x: frame.midX, y: frame.midY + 70)
        backgroundHole.fillColor = UIColor.white
        backgroundHole.alpha = 0.001
        backgroundHole.blendMode = .replace
        backgroundSpace.addChild(backgroundHole)
        
        
        
        let borderShape = SKShapeNode()

        let borderwidth = backgroundholewidth
        let borderheight = backgroundholeheight
        
        borderShape.path = UIBezierPath(roundedRect: CGRect(x: -backgroundholewidth/2, y: -backgroundholeheight/2, width: backgroundholewidth, height: backgroundholeheight), cornerRadius: 40).cgPath
        borderShape.position =  backgroundHole.position
        borderShape.fillColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha:1)
        borderShape.strokeColor = UIColor(red: 0/255, green: 0/255, blue: 128/255, alpha:1)
        borderShape.lineWidth = 14
        borderShape.name = "border"
        borderShape.zPosition = -100
        
        
        effect.addChild(borderShape)
        


        let holewidth = backgroundholewidth - 60
        let holeheight = backgroundholeheight - 100
        let rectangleHole = SKShapeNode()
        rectangleHole.name = "rectanglehole"
        rectangleHole.path = UIBezierPath(roundedRect: CGRect(x: -holewidth/2, y: -holeheight/2, width: holewidth, height: holeheight), cornerRadius: 0).cgPath
        rectangleHole.position = CGPoint(x: backgroundHole.position.x, y: backgroundHole.position.y - 80)
        rectangleHole.fillColor = UIColor.white
            rectangleHole.alpha = 0.001
        rectangleHole.blendMode = .replace
        borderShape.addChild(rectangleHole)
        
        

        let rectangleFill = SKShapeNode()
        rectangleFill.name = "rectangleFill"
        rectangleFill.path = UIBezierPath(roundedRect: CGRect(x: -holewidth/2, y: -holeheight/2, width: holewidth, height: holeheight), cornerRadius: 0).cgPath
        rectangleFill.position = CGPoint(x: rectangleHole.position.x, y: backgroundHole.position.y - 10)
        rectangleFill.fillColor = UIColor.white
        rectangleFill.strokeColor = UIColor.white
        rectangleFill.lineWidth = 10
        rectangleFill.zPosition = -200
        camera?.addChild(rectangleFill)
        
        let lobbyLabel = SKShapeNode()

        let lobbyLabelwidth = backgroundholewidth
        let lobbyLabelheight = 160
        
        lobbyLabel.path = UIBezierPath(roundedRect: CGRect(x: -backgroundholewidth/2, y: -lobbyLabelheight/2, width: backgroundholewidth, height: lobbyLabelheight), cornerRadius: 40).cgPath
        lobbyLabel.position =  CGPoint(x: frame.midX, y: frame.midY + 280)
        lobbyLabel.fillColor = UIColor(red: 0/255, green: 0/255, blue: 128/255, alpha:1)
        lobbyLabel.strokeColor = UIColor.clear
        lobbyLabel.lineWidth = 14
        lobbyLabel.name = "border"
        lobbyLabel.zPosition = 200
        camera?.addChild(lobbyLabel)
        
        codeLabel.position = CGPoint(x: frame.midX, y: frame.midY - 340)
     //   startButtonNode.position.y = codeLabel.position.y + startButtonNode.size.height/4
        codeLabel.text = String(Global.gameData.gameID)
        setupLabel(label: codeLabel)
        
        playercountLabel.position = CGPoint(x: -480, y: frame.midY - 340)
        setupLabel(label: playercountLabel)
        
        setupLabel(label: lobbyLabelText)
//
        
        
        
        
        colorButtonNode = self.childNode(withName: "redPlayer") as? MSButtonNode
        kickButtonNode = self.childNode(withName: "kickButton") as? MSButtonNode
        
        if Global.gameData.mode == modeArray[0] {
            i = 0
        } else if Global.gameData.mode == modeArray[1] {
            i = 1
        } else {
            i = 2
        }
        
        startButtonNode = self.childNode(withName: "startButton") as? MSButtonNode
        
        startButtonNode?.removeFromParent()
        camera?.addChild(startButtonNode!)
        
        
        startButtonNode.position = CGPoint(x: frame.midX + 400 , y: borderShape.position.y - 370)
        
        startButtonNode.selectedHandlers = {
            
            DataPusher.PushData(path: "Games/\(Global.gameData.gameID)/Status", Value: "Game")
            //====================================
        }
        if Global.gameData.isHost {
            startButtonNode.alpha = 1
        }
        
        
        modeImageButtonNode = self.childNode(withName: "modeImage") as? MSButtonNode
        
        modeImageButtonNode?.removeFromParent()
        camera?.addChild(modeImageButtonNode!)
        
        
        modeImageButtonNode.position = CGPoint(x: frame.midX - 320 , y: borderShape.position.y - 370)
        
        self.modeImageButtonNode.texture = SKTexture(imageNamed: Global.gameData.mode)
        if Global.gameData.isHost {
            modeImageButtonNode.selectedHandlers = {
                self.view!.removeGestureRecognizer(self.panGesture)
                if self.i == self.modeArray.endIndex - 1 {
                    self.i = 0
                } else {
                    self.i = self.i+1
                }
                self.modeImageButtonNode.alpha = 1
                Global.gameData.mode = self.modeArray[self.i]
                Global.gameData.ModeChange()
                self.modeImageButtonNode.texture = SKTexture(imageNamed: Global.gameData.mode)
            }
        } else {
            modeImageButtonNode.selectedHandler = {
                self.modeImageButtonNode.alpha = 1
            }
        }
        
        if Global.gameData.map == mapArray[0] {
            j = 0
        } else if Global.gameData.map == mapArray[1] {
            j = 1
        } else {
            j = 2
        }
        mapImageButtonNode = self.childNode(withName: "mapImage") as? MSButtonNode
        
        mapImageButtonNode?.removeFromParent()
        camera?.addChild(mapImageButtonNode!)
        
        
        mapImageButtonNode.position = CGPoint(x: frame.midX + 90 , y: borderShape.position.y - 370)
        self.mapImageButtonNode.texture = SKTexture(imageNamed: Global.gameData.map)
        if Global.gameData.isHost {
            mapImageButtonNode.selectedHandlers = {
                if self.j == self.mapArray.endIndex - 1 {
                    self.j = 0
                } else {
                    self.j = self.j+1
                }
                self.mapImageButtonNode.alpha = 1
                Global.gameData.map = self.mapArray[self.j]
                Global.gameData.MapChange()
                self.mapImageButtonNode.texture = SKTexture(imageNamed: Global.gameData.map)
            }
        } else {
            mapImageButtonNode.selectedHandler = {
                self.mapImageButtonNode.alpha = 1
            }
        }
        
        user1.name = "user1"
        colorButtonNode.name = "colorButtonNode"
        kickButtonNode.name = "kickButtonNode"
        user1.removeFromParent()
        colorButtonNode.removeFromParent()
        kickButtonNode.removeFromParent()
        
        playerLabel.addChild(user1)
        playerLabel.addChild(colorButtonNode)
        if Global.gameData.isHost {
            playerLabel.addChild(kickButtonNode)
        }
        addChild(playerLabelParent)
        playerLabelParent.name = "pepe"
        
        Global.multiplayerHandler.listenForGuestChanges()
        Global.multiplayerHandler.ListenForGameStatus()
        Global.multiplayerHandler.ListenForMapChanges()
        Global.multiplayerHandler.ListenForModeChanges()
        Global.multiplayerHandler.ListenForColorChanges()
        Global.multiplayerHandler.ListenForColorChangesLobby()
    }
    
    
    func setPlayerList(playerList: [String]) {
        list = playerList
        playerLabelParent.removeAllChildren()
        print(playerList)
        for player in playerList {
            let newuser = playerLabel.copy() as! SKNode
            newuser.name = player
            let userLabel = newuser.childNode(withName: "user1") as! SKLabelNode
            userLabel.text = player
            let index = playerList.firstIndex(of: player)!

            
            if Global.gameData.isHost {
                let userKick = newuser.childNode(withName: "kickButtonNode") as! MSButtonNode
                userKick.selectedHandlers = {
                    //kick em
                    DataPusher.PushData(path: "Games/\(Global.gameData.gameID)/PlayerList/\(userKick.parent!.name!)", Value: "PePeKicked")

                    
                }
                userKick.position.x = frame.midX + 430
                
                userKick.position.y += newuser.position.y - 10 + 12
            }
            let userColor = newuser.childNode(withName: "colorButtonNode") as! MSButtonNode
            if player == Global.playerData.playerID {
                setUpColors(userColor: userColor, isPlayer: true, index: index)
            } else {
                setUpColors(userColor: userColor, isPlayer: false, index: index)
            }
            
            
            newuser.position.x = frame.midX - 100
            newuser.position.y += CGFloat(80 - index*100)
            playerLabelParent.addChild(newuser)
            playercountLabel.text = "\(playerList.count)/6"
            
            let playerCell = SKShapeNode()

            let playerCellwidth = 840
            let playerCellheight = 130
            
            playerCell.path = UIBezierPath(roundedRect: CGRect(x: -playerCellwidth/2, y: -playerCellheight/2, width: playerCellwidth, height: playerCellheight), cornerRadius: 40).cgPath
            playerCell.position.x = frame.midX
            
            playerCell.position.y += newuser.position.y + 20 + 12
            playerCell.fillColor = UIColor(red: 0/255, green: 0/255, blue: 128/255, alpha:1)
            playerCell.strokeColor = UIColor.clear
            playerCell.lineWidth = 14
            playerCell.zPosition = 1
            
            playerLabelParent.addChild(playerCell)
            
        }
    }
    
    func StartGame(){
        self.view!.removeGestureRecognizer(self.panGesture)
        Global.multiplayerHandler.PullTrailChanges()
        Global.multiplayerHandler.PullSkinChanges()
        if list.count > 1 {
            randInt = Global.gameData.gameID % (list.count)
        }
        for s in self.list {
            var spaceship: SpaceshipBase
            if s == Global.playerData.playerID {
                switch Global.gameData.mode {
                case "infection":
                    if list.firstIndex(of: s) == randInt {
                        DataPusher.PushData(path: "Games/\(Global.gameData.gameID)/InfectedList/\(Global.playerData.playerID)", Value: "true")
                        DataPusher.PushData(path: "Games/\(Global.gameData.gameID)/Cosmetics/PlayerColor/\(Global.playerData.playerID)", Value: "apboGreen")
                        spaceship = LocalSpaceship(imageTexture: intToColorInfection[0]!)
                        Global.playerData.color = "apboGreen"
                    } else {
                        DataPusher.PushData(path: "Games/\(Global.gameData.gameID)/Cosmetics/PlayerColor/\(Global.playerData.playerID)", Value: "apboWhite")
                        spaceship = LocalSpaceship(imageTexture: intToColorInfection[1]!)
                        Global.playerData.color = "apboWhite"
                    }
                case "ffa":
                    spaceship = LocalSpaceship(imageTexture: intToColor[colorIndex]!)
                    Global.playerData.color = intToColor[colorIndex]!
                case "astroball":
                    spaceship = LocalSpaceship(imageTexture: intToColor[colorIndex]!)
                    Global.playerData.color = intToColor[colorIndex]!
                default:
                    spaceship = LocalSpaceship(imageTexture: intToColor[colorIndex]!)
                }
                Global.gameData.playerShip = spaceship as? LocalSpaceship
            } else {
                switch Global.gameData.mode {
                case "infection":
                    if list.firstIndex(of: s) == randInt {
                        spaceship = RemoteSpaceship(playerID: s, imageTexture: intToColorInfection[0]!)
                    } else {
                        spaceship = RemoteSpaceship(playerID: s, imageTexture: intToColorInfection[1]!)
                    }
                case "ffa":
                    spaceship = RemoteSpaceship(playerID: s, imageTexture: intToColor[list.firstIndex(of: s)! % 9]!)
                case "astroball":
                    spaceship = RemoteSpaceship(playerID: s, imageTexture: intToColor[list.firstIndex(of: s)! % 2]!)
                default:
                    spaceship = RemoteSpaceship(playerID: s, imageTexture: intToColor[list.firstIndex(of: s)! % 9]!)
                }
            }
            Global.gameData.shipsToUpdate.append(spaceship)
        }
        
        switch Global.gameData.mode {
        case "ffa":
            Global.gameData.gameState = GameStates.FFA
            Global.loadScene(s: "GameSceneOnline")
        case "astroball":
            Global.gameData.gameState = GameStates.AstroBall
            Global.loadScene(s: "AstroBall")
        case "infection":
            Global.gameData.gameState = GameStates.Infection
            Global.loadScene(s: "Infection")
        default:
            Global.gameData.gameState = GameStates.FFA
            Global.loadScene(s: "GameSceneOnline")
        }
    }
    
    func setupLabel(label: SKLabelNode) {
        label.zPosition = 2
        label.fontColor = UIColor.white
        label.fontSize = 120
        label.fontName = "AvenirNext-Bold"
        camera?.addChild(label)
    }
    
    func setUpColors(userColor: MSButtonNode, isPlayer: Bool, index: Int){
        switch Global.gameData.mode {
        case "infection":
            userColor.alpha = 0
        case "ffa":
            userColor.texture = SKTexture(imageNamed: intToColor[index % 9]!)
            colorIndex = index
            if isPlayer {
                DataPusher.PushData(path: "Games/\(Global.gameData.gameID)/Cosmetics/PlayerColor/\(Global.playerData.playerID)", Value: self.intToColor[self.colorIndex]!)
                userColor.selectedHandlers = {
                    if self.colorIndex == 8 {
                        self.colorIndex = 0
                    } else {
                        self.colorIndex = self.colorIndex + 1
                    }
                    userColor.texture = SKTexture(imageNamed: self.intToColor[self.colorIndex]!)
                    DataPusher.PushData(path: "Games/\(Global.gameData.gameID)/Cosmetics/PlayerColor/\(Global.playerData.playerID)", Value: self.intToColor[self.colorIndex]!)
                    userColor.alpha = 1
                }
            } else {
                userColor.selectedHandler = {
                    userColor.alpha = 1
                }
            }
        case "astroball":
            userColor.texture = SKTexture(imageNamed: intToColor[index % 2]!)
            colorIndex = index
            if isPlayer {
                DataPusher.PushData(path: "Games/\(Global.gameData.gameID)/Cosmetics/PlayerColor/\(Global.playerData.playerID)", Value: self.intToColor[self.colorIndex%2]!)
                userColor.selectedHandlers = {
                    if self.colorIndex == 1 {
                        self.colorIndex = 0
                    } else {
                        self.colorIndex = 1
                    }
                    userColor.texture = SKTexture(imageNamed: self.intToColor[self.colorIndex%2]!)
                    DataPusher.PushData(path: "Games/\(Global.gameData.gameID)/Cosmetics/PlayerColor/\(Global.playerData.playerID)", Value: self.intToColor[self.colorIndex%2]!)
                    userColor.alpha = 1
                }
            } else {
                userColor.selectedHandler = {
                    userColor.alpha = 1
                }
            }
        default:
            userColor.texture = SKTexture(imageNamed: intToColor[index % 9]!)
            colorIndex = index
            DataPusher.PushData(path: "Games/\(Global.gameData.gameID)/Cosmetics/PlayerColor/\(Global.playerData.playerID)", Value: self.intToColor[self.colorIndex]!)
            userColor.selectedHandlers = {
                if self.colorIndex == 8 {
                    self.colorIndex = 0
                } else {
                    self.colorIndex = self.colorIndex + 1
                }
                userColor.texture = SKTexture(imageNamed: self.intToColor[self.colorIndex]!)
                DataPusher.PushData(path: "Games/\(Global.gameData.gameID)/Cosmetics/PlayerColor/\(Global.playerData.playerID)", Value: self.intToColor[self.colorIndex]!)
                userColor.alpha = 1
            }
        }
    }
    
    func pullMap(){
        print("pulled map")
        MultiplayerHandler.ref.child("Games/\(Global.gameData.gameID)/Map").observeSingleEvent(of: .value) {
            snapshot in
            if (snapshot.exists()) {
                Global.gameData.map = snapshot.value as! String
                self.mapImageButtonNode.texture = SKTexture(imageNamed: Global.gameData.map)
                self.mapImageButtonNode.alpha = 1
            }
        }
    }
    
    func pullMode(){
        print("pulled mode")
        MultiplayerHandler.ref.child("Games/\(Global.gameData.gameID)/Mode").observeSingleEvent(of: .value) {
            snapshot in
            if (snapshot.exists()) {
                Global.gameData.mode = snapshot.value as! String
                self.modeImageButtonNode.texture = SKTexture(imageNamed: Global.gameData.mode)
                self.modeImageButtonNode.alpha = 1
            }
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
    
    @objc func panGestureAction(_ sender: UIPanGestureRecognizer) {
        // The camera has a weak reference, so test it
        guard let camera = self.camera else {
            return
        }
        
        //  let zoomInActionipad = SKAction.scale(to: 1.7, duration: 0.01)
        
        //  camera.run(zoomInActionipad)
        
        // If the movement just began, save the first camera position
        if sender.state == .began {
            previousCameraPoint = camera.position
            currentHandler()
            currentHandler = {}
        }
        // Perform the translation
        let translation = sender.translation(in: self.view)
        
        var newPosition = CGPoint(
            x: previousCameraPoint.x,
            y: previousCameraPoint.y + translation.y * 2
        )
        if newPosition.y > 0 { newPosition.y = 0}
        var bottomlimit = CGFloat(-200)
    
        
        if newPosition.y < bottomlimit { newPosition.y = CGFloat(bottomlimit)}
        
        camera.position = newPosition
        
        
    }

    
    
}


