//
//  MainMenu.swift
//  APBOv2
//
//  Created by 90306670 on 11/18/20.
//  Copyright © 2020 Dhruv Chowdhary. All rights reserved.
//

import SpriteKit

class Shop: SKScene {
    
    /* UI Connections */
    var backButtonNode: MSButtonNode!
    var trailsButtonNode: MSButtonNode!
    var skinsButtonNode: MSButtonNode!
    var buyButtonNode: MSButtonNode!
    var cancelButtonNode: MSButtonNode!

    var shopLightningBoltButtonNode: MSButtonNode!

    //  var shopLightningBoltButtonNode: MSButtonNode!

    let trailLabel = SKLabelNode(text: "TRAILS")
    
    let polynite = SKSpriteNode(imageNamed: "polynite2")
    let polyniteBox = SKSpriteNode(imageNamed: "polynitebox")
    let polyniteLabel = SKLabelNode(text: "0")
    var shopTab = "skins"
    
    let shopEquip = SKSpriteNode(imageNamed: "shopEquip")
    
    var decalNodes: [MSButtonNode] = []
    
    
    
    var decalStrings: [String] = []
    var decalPrices: [Int] = []
    //var purchasedDecals: [String] = []
    //var equippedDecal = UserDefaults.standard.string(forKey: "equippedDecal")
    
    var trailNodes: [MSButtonNode] = []
    var trailStrings: [String] = []
    var trailPrices: [Int] = []
    //var purchasedTrails: [String] = []
    
    // var equippedTrail = UserDefaults.standard.string(forKey: "equippedTrail")
    
    public var lockerDecals: [String] = []
    public var lockerTrails: [String] = []
    public var equippedDecal: String = "default"
    public var equippedTrail: String = "default"
    
    
    var isBuying = false
    
    override func didMove(to view: SKView) {
        /* Setup your scene here */
        
        Global.gameData.skView = self.view!

        
        //loading shop
        let shopRef = MultiplayerHandler.ref.child("Users/\(UIDevice.current.identifierForVendor!)/ShopStuff")
        shopRef.observeSingleEvent(of:.value, with: { [self] (Snapshot) in
            if !Snapshot.exists(){
                return
            }
            let snapVal = Snapshot.value as! String
            let jsonData = snapVal.data(using: .utf8)
            let payload = try! JSONDecoder().decode(ShopPayload.self, from: jsonData!)
            
            if payload.equippedTrail != nil{
                equippedDecal = payload.equippedDecal
                equippedTrail = payload.equippedTrail
                lockerTrails = payload.lockerTrails
                lockerDecals = payload.lockerDecals
                //   print(equippedDecal)
                
                for i in 0..<decalNodes.count {
                    decalNodes[i].alpha = 1
                    print("hello sir")
                    if decalStrings[i] == equippedDecal {
                        shopEquip.alpha = 1
                        shopEquip.position = decalNodes[i].position
                    }
                }
                
            }
            
        })
        
        
       pushShopStuff()
        
        
        
        
        let buyPopup = SKShapeNode()
        
        
        let buyPopupWidth = 600
        let buyPopupHeight = 600
        
        buyPopup.path = UIBezierPath(roundedRect: CGRect(x: -buyPopupWidth/2, y: -buyPopupHeight/2, width: buyPopupWidth, height: buyPopupHeight), cornerRadius: 40).cgPath
        //borderShape.position = CGPoint(x: frame.midX, y: frame.midY)
        buyPopup.fillColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha:1)
        buyPopup.strokeColor = UIColor(red: 0/255, green: 0/255, blue: 128/255, alpha:1)
        buyPopup.lineWidth = 20
        buyPopup.name = "buyPopup"
        
        buyPopup.zPosition = 20
        buyPopup.alpha = 0
        
        
        addChild(buyPopup)
        
        
        shopEquip.alpha = 0
        shopEquip.xScale = 0.3
        shopEquip.yScale = 0.3
        addChild(shopEquip)
        
        shopEquip.zPosition = 6
        
        Global.gameData.skView = self.view!

        Global.gameData.addPolyniteCount(delta: 900)
        
        if let particles = SKEmitterNode(fileNamed: "Starfield") {
            particles.position = CGPoint(x: frame.midX, y: frame.midY)
            //      particles.advanceSimulationTime(60)
            particles.zPosition = -1
            addChild(particles)
        }
        
        
        let shopDisplay = SKSpriteNode(imageNamed: "shop")
        shopDisplay.position = CGPoint(x: frame.midX, y: frame.midY + 300)
        shopDisplay.size =  CGSize(width: 298.611 / 1.2 , height: 172.222 / 1.2)
        addChild(shopDisplay)
        shopDisplay.zPosition = 5
  
        
        
        
        polyniteBox.size = CGSize(width: 391.466 / 1.5, height: 140.267 / 1.5)
        polyniteBox.position = CGPoint(x: frame.midX + 720, y: frame.midY + 340)
        polyniteBox.zPosition = 9
        addChild(polyniteBox)
        
        polynite.position = CGPoint(x: polyniteBox.position.x - 80 , y: polyniteBox.position.y)
        polynite.zPosition = 10
        polynite.size = CGSize(width: 104 / 1.5, height: 102.934 / 1.5 )
        addChild(polynite)
        
        polyniteLabel.text = "\(Global.gameData.polyniteCount)"
        polyniteLabel.position = CGPoint(x: polyniteBox.position.x , y: polyniteBox.position.y - 20)
        polyniteLabel.fontName = "AvenirNext-Bold"
        polyniteLabel.fontColor = UIColor.black
        polyniteLabel.zPosition = 10
        polyniteLabel.fontSize = 80 / 1.5
        addChild(polyniteLabel)
        
        buyButtonNode = self.childNode(withName: "buttonBuy") as? MSButtonNode
        buyButtonNode.selectedHandlers = {
            self.buyButtonNode.alpha = 0
            self.isBuying = true
        }
        cancelButtonNode = self.childNode(withName: "buttonCancel") as? MSButtonNode
        cancelButtonNode.selectedHandlers = {
            buyPopup.removeAllChildren()
            self.cancelButtonNode.alpha = 0
            buyPopup.alpha = 0
            self.buyButtonNode.alpha = 0
            
        }
        
        buyButtonNode.position = CGPoint(x: frame.midX + 150 , y: buyPopup.position.y - 200)
        cancelButtonNode.position = CGPoint(x: frame.midX - 150, y: buyPopup.position.y - 200)
        buyButtonNode.zPosition = 9
        cancelButtonNode.zPosition = 9
        buyButtonNode.alpha = 0
        cancelButtonNode.alpha = 0
        
        decalNodes =
            [
                MSButtonNode(imageNamed: "decalNodeStripe"), MSButtonNode(imageNamed: "decalNodeSwirl")
            ]
        
        
        
        decalStrings =
            [
                "TIGER", "SWIRLS"
            ]
        
        decalPrices =
            [
                500, 500
            ]
        
        trailNodes =
            [
                MSButtonNode(imageNamed: "trailNodeLightning")
            ]
        
        trailStrings =
            [
                "LIGHTNING"
            ]
        trailPrices =
            [
                100
            ]
        
        for i in 0..<trailNodes.count {
            
            
            
            let node = trailNodes[i]
            node.isUserInteractionEnabled = true
            node.state = .MSButtonStopAlphaChanges
            
            // Scale the node here
            node.xScale = 0.3
            node.yScale = 0.3
            node.alpha = 0
            
            // Position node
            if i != 0 {
                node.position.x = trailNodes[i-1].position.x + 400
                node.position.y = trailNodes[i-1].position.y
            } else {
                node.position.y = frame.midY - 150
                node.position.x = frame.midX - 400
            }
            
            
            node.zPosition = 5
            
            node.selectedHandler = { [self] in
                
                
                // ShadeNode and set handlers
                
                if lockerTrails.contains(trailStrings[i]){
                    //already Purchased! might be equip function
                    shopEquip.alpha = 1
                    shopEquip.position = node.position

                    print("\(trailStrings[i]) equipped")
                    
                    equippedTrail = trailStrings[i]
                    
                    
                    
                    Global.gameData.selectedTrail = SelectedTrail(rawValue: equippedTrail)!

                    

                    
                    
                } else {
                    // purchasing
                    //check if enough creds
                    
                    //if enough then
                    loadPopup(index: i, node: node, type: "trail")
                    
                    //if buy button clicked
                    if isBuying == true {
                    buyingTrail(i: i, node: node)
                    }
                }
                pushShopStuff()
                
            }
            
            ///check stuff
            checkForTrailStuff(node: node, string: trailStrings[i])
            scene?.addChild(node)
        }
        
        
        for i in 0..<decalNodes.count {
            
 
            let node = decalNodes[i]
            node.isUserInteractionEnabled = true
            node.state = .MSButtonStopAlphaChanges
            node.alpha = 1
            // Scale the node here
            node.xScale = 0.3
            node.yScale = 0.3
            
            // Position node
            if i != 0 {
                node.position.x = decalNodes[i-1].position.x + 300
                node.position.y = decalNodes[i-1].position.y
            } else {
                node.position.y = frame.midY - 150
                node.position.x = frame.midX - 150
            }
            
            node.zPosition = 5
            
            node.selectedHandler = { [self] in

                
                if lockerDecals.contains(decalStrings[i]){
                    
                    shopEquip.position = node.position
                    shopEquip.alpha = 1

                //    DataPusher.PushData(path: "Users/\(UIDevice.current.identifierForVendor!)/equippedDecal", Value: decalStrings[i])
                   

                    equippedDecal = decalStrings[i]
                    Global.gameData.selectedSkin = SelectedSkin(rawValue: equippedDecal)!

                    print("\(decalStrings[i]) equipped")
                    
                    
                    
                } else {
                    // purchasing
                    //if enough then
                    loadPopup(index: i, node: node, type: "decal")
                    
                    //else show not enough polynite alert
                    
                    //if buy button clicked
                    if isBuying == true {
                    buyingDecal(i: i, node: node)
                    }
                    
                }
                pushShopStuff()
            }
            
            checkForDecalStuff(node: node, string: decalStrings[i])
            
            scene?.addChild(node)
        }
        
        
        
        
        
        trailsButtonNode = self.childNode(withName: "trailsButtonUnselected") as? MSButtonNode
        trailsButtonNode.selectedHandlers = { [self] in
            shopEquip.alpha = 0
            self.trailsButtonNode.texture = SKTexture(imageNamed: "trailsButtonSelected")
            self.skinsButtonNode.texture = SKTexture(imageNamed: "skinsButtonUnselected")
            self.trailsButtonNode.alpha = 1
            self.shopTab = "trails"
            
            for i in 0..<decalNodes.count {
                decalNodes[i].alpha = 0
            }


            
            for i in 0..<trailNodes.count {
                trailNodes[i].alpha = 1
                checkForTrailStuff(node: trailNodes[i], string: trailStrings[i])

            }
            
        }
        
        trailsButtonNode.selectedHandler = {
            self.trailsButtonNode.alpha = 1
        }
        
        skinsButtonNode = self.childNode(withName: "skinsButtonSelected") as? MSButtonNode
        skinsButtonNode.selectedHandlers = { [self] in
            self.trailsButtonNode.texture = SKTexture(imageNamed: "trailsButtonUnselected")
            self.skinsButtonNode.texture = SKTexture(imageNamed: "skinsButtonSelected")
            self.skinsButtonNode.alpha = 1
            self.shopTab = "skins"
            shopEquip.alpha = 0
            for i in 0..<decalNodes.count {
                decalNodes[i].alpha = 1
     
                checkForDecalStuff(node: decalNodes[i], string: decalStrings[i])

            }

            for i in 0..<trailNodes.count {
                trailNodes[i].alpha = 0
            }
            
            
            
        }
        
        skinsButtonNode.selectedHandler = {
            self.skinsButtonNode.alpha = 1
        }
        
        
        trailsButtonNode.position = CGPoint(x: frame.midX + 150 , y: frame.midY + 100 )
        skinsButtonNode.position = CGPoint(x: frame.midX - 150, y: frame.midY + 100)
        
        
        backButtonNode = self.childNode(withName: "back") as? MSButtonNode
        backButtonNode.selectedHandlers = {
            self.loadMainMenu()
        }
        

        func loadPopup(index: Int, node: MSButtonNode, type: String) {
            var item = SKSpriteNode()
            var itemName = SKLabelNode()
            var prompt = SKLabelNode()
            
            
            
            
            if type == "decal" {
                item = SKSpriteNode(imageNamed: decalStrings[index] + "Purchased")
                itemName = SKLabelNode(text: decalStrings[index])
                prompt = SKLabelNode(text: "PURCHASE " + decalStrings[index] + " FOR " + String(decalPrices[index]) + " POLYNITE?")
            }
            else if type == "trail" {
                item = SKSpriteNode(imageNamed: trailStrings[index] + "Purchased")
                itemName = SKLabelNode(text: trailStrings[index])
                prompt = SKLabelNode(text: "PURCHASE " + trailStrings[index] + " FOR " + String(trailPrices[index]) + " POLYNITE?")
            }
           
            itemName.position = CGPoint(x: frame.midX, y: buyPopup.position.y + 200)
            itemName.zPosition = 5
            itemName.fontColor = UIColor.black
            itemName.fontSize = 65
            itemName.fontName = "AvenirNext-Bold"
            
            prompt.position = CGPoint(x: frame.midX, y: buyPopup.position.y - 110)
            prompt.zPosition = 5
            prompt.fontColor = UIColor(red: 0/255, green: 0/255, blue: 128/255, alpha:1)
            prompt.fontSize = 30
            prompt.fontName = "AvenirNext-Bold"
           // item.size = item.texture.size()
                 item.size = CGSize(width: 300, height: 300)
            item.zPosition = 3
            
            buyPopup.addChild(itemName)
            buyPopup.addChild(prompt)
            buyPopup.addChild(item)
       //     addChild(itemName)
            
            buyPopup.alpha = 1
            buyButtonNode.alpha = 1
            
            cancelButtonNode.alpha = 1
        }
        func buyingTrail(i: Int, node: MSButtonNode) {
            print("bought \(trailStrings[i])")
            Global.gameData.spendPolynite(amountToSpend: trailPrices[i])
            polyniteLabel.text = "\(Global.gameData.polyniteCount)"
            
            
            
            shopEquip.alpha = 1
            shopEquip.position = node.position
            
            // prompt buy menu, if bougt then vvv
            
            lockerTrails.append(trailStrings[i])
            
            node.texture = SKTexture(imageNamed: trailStrings[i] + "Purchased")
            print(trailStrings[i] + "Purchased")
            
            equippedTrail = trailStrings[i]
            Global.gameData.selectedTrail = SelectedTrail(rawValue: equippedTrail)!
            
            
        }
        
        
        func buyingDecal(i: Int, node: MSButtonNode) {
            
            print("bought \(decalStrings[i])")
            // subtract polynite according to price
            Global.gameData.spendPolynite(amountToSpend: decalPrices[i])
            
            lockerDecals.append(decalStrings[i])

            polyniteLabel.text = "\(Global.gameData.polyniteCount)"
            
            shopEquip.alpha = 1

            shopEquip.position = node.position
            node.texture = SKTexture(imageNamed: decalStrings[i] + "Purchased")
            equippedDecal = decalStrings[i]

            Global.gameData.selectedSkin = SelectedSkin(rawValue: equippedDecal)!
            
            
        }
        
        if UIDevice.current.userInterfaceIdiom != .pad {
            if UIScreen.main.bounds.width < 779 {
                backButtonNode.position.x = -600
                backButtonNode.position.y =  300
            }
        }
        if UIDevice.current.userInterfaceIdiom == .pad {
            
        } else if UIScreen.main.bounds.width > 779 {
            
        } else {
            polyniteBox.position.x = frame.midX + 600
            polynite.position.x = polyniteBox.position.x - 80
            polyniteLabel.position.x = polyniteBox.position.x + 50
        }
        
        let borderShape = SKShapeNode()
        
        
        let borderwidth = 1200
        let borderheight = 550
        
        borderShape.path = UIBezierPath(roundedRect: CGRect(x: -borderwidth/2, y: -borderheight/2 - 75, width: borderwidth, height: borderheight), cornerRadius: 40).cgPath
        //borderShape.position = CGPoint(x: frame.midX, y: frame.midY)
        borderShape.fillColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha:1)
        borderShape.strokeColor = UIColor(red: 0/255, green: 0/255, blue: 128/255, alpha:1)
        borderShape.lineWidth = 20
        borderShape.name = "border"

        
        addChild(borderShape)
        
    }
    
    func checkForTrailStuff(node: MSButtonNode, string: String) {
      //  shopEquip.alpha = 0
        if lockerTrails.contains(string) {
            node.texture = SKTexture(imageNamed: string + "Purchased")
        }
        if equippedTrail == string {
            print("equipping \(equippedTrail)")
            shopEquip.position = node.position
            
            shopEquip.alpha = 1
        }
        
    }
    
    func checkForDecalStuff(node: MSButtonNode, string: String) {
   //     shopEquip.alpha = 0
        if lockerDecals.contains(string) {
            node.texture = SKTexture(imageNamed: string + "Purchased")
        }
        if equippedDecal == string {
            shopEquip.alpha = 1
            print("equipping \(equippedDecal)")
            shopEquip.position = node.position
          //  print(equippedDecal)
            
        }
        
    }
    
    func pushShopStuff() {
        let shopPayload = ShopPayload(lockerDecals: lockerDecals, lockerTrails: lockerTrails, equippedDecal: equippedDecal, equippedTrail: equippedTrail)
        let data = try! JSONEncoder().encode(shopPayload)
        let json = String(data: data, encoding: .utf8)!
        DataPusher.PushData(path: "Users/\(UIDevice.current.identifierForVendor!)/ShopStuff", Value: json)
        print(json)
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
        if UIDevice.current.userInterfaceIdiom == .pad {
            scene.scaleMode = .aspectFit
        } else {
            scene.scaleMode = .aspectFill
        }
        
        /* Show debug */
        skView.showsPhysics = false
        skView.showsDrawCount = false
        skView.showsFPS = false
        
        /* 4) Start game scene */
        skView.presentScene(scene)
    }
    
}





