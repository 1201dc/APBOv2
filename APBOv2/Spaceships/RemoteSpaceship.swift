import Foundation
import SpriteKit
import Firebase

class RemoteSpaceship: SpaceshipBase {
    init(playerID: String) {
        let spaceShipNode = SKSpriteNode(imageNamed: "player");
        spaceShipNode.physicsBody = SKPhysicsBody.init(circleOfRadius: 24)
        spaceShipNode.physicsBody!.categoryBitMask = CollisionType.player.rawValue
        spaceShipNode.physicsBody!.collisionBitMask = CollisionType.enemy.rawValue | CollisionType.pilot.rawValue | CollisionType.player.rawValue | CollisionType.bullet.rawValue
        
        super.init(shipSprite: spaceShipNode, playerId: playerID)
        shipSprite.position.x += CGFloat((300 * Global.gameData.shipsToUpdate.count))
        
        let ref = Database.database().reference().child("Games/\(Global.gameData.gameID)/Players/\(Global.playerData.username)")
        Global.multiplayerHandler.listenForPayload(ref: ref, shipSprite: self.shipSprite as! SKSpriteNode)
    }
    
    override func UniqueUpdateShip(deltaTime: Double) {
        
    }
}

