import Foundation
import SpriteKit
import Firebase

class RemoteSpaceship: SpaceshipBase {
    
    init(playerID: String, imageTexture: String) {
        super.init(playerId: playerID)
        spaceShipNode.removeFromParent()
        spaceShipNode = SKSpriteNode(imageNamed: imageTexture);
        spaceShipParent.addChild(spaceShipNode)
        spaceShipNode.addChild(thruster1!)
        spaceShipNode.physicsBody = SKPhysicsBody.init(circleOfRadius: 24)
        spaceShipNode.physicsBody!.categoryBitMask = CollisionType.player.rawValue
        spaceShipNode.physicsBody!.collisionBitMask = CollisionType.enemy.rawValue | CollisionType.pilot.rawValue | CollisionType.player.rawValue | CollisionType.bullet.rawValue | CollisionType.border.rawValue
        
        spaceShipParent.position.x += CGFloat((300 * Global.gameData.shipsToUpdate.count))
        spaceShipNode.zPosition = 5
        
        Global.multiplayerHandler.ListenForPayload(ref: posRef, shipSprite: spaceShipNode)
        Global.multiplayerHandler.ListenForShots(ref: shotsRef, spaceShip: self)
    }
    
    override func UniqueUpdateShip(deltaTime: Double) {
        spaceShipParent.position.x += cos(spaceShipNode.zRotation) * CGFloat(deltaTime) * 250
        spaceShipParent.position.y += sin(spaceShipNode.zRotation) * CGFloat(deltaTime) * 250
    }
}

