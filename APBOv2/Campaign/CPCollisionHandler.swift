import Foundation
import SpriteKit

// Collision bitmasks
public struct CPUInt {
    
    static let empty: UInt32 = 0
    static let bullet: UInt32 = (0x1 << 0)
    static let player: UInt32 = (0x1 << 1)
    static let enemy: UInt32 = (0x1 << 2)
    static let object: UInt32 = (0x1 << 3)
    static let immovableObject: UInt32 = (0x1 << 4)
    static let walls: UInt32 = (0x1 << 5)
    static let checkpoint: UInt32 = (0x1 << 31)
}

class CPCollisionHandler {
    var ricoCount = 0
    var sClass: CPLevelBase
    
    init(sceneClass: CPLevelBase){
        sClass = sceneClass
    }
    
    public func collision(nodeA: SKNode, nodeB: SKNode, possibleNodes: [AnyObject] ){
        let classA = possibleNodes[Int(nodeA.name!)!]
        let classB = possibleNodes[Int(nodeB.name!)!]
        
        // Checkpoint testing
        if classA is CPCheckpoint {
            if classB is CPPlayerShip {
                handleCheckpoint(cp: classA as! CPCheckpoint)
            }
        } else if classB is CPCheckpoint{
            if classA is CPPlayerShip {
                handleCheckpoint(cp: classB as! CPCheckpoint)
            }
            
        // Obj testing
        } else if let obj = classA as? CPObject {
            ObjAndUnknown(obj: obj, unknown: classB)
        }
        else if let obj = classB as? CPObject {
            ObjAndUnknown(obj: obj, unknown: classA)
        
        // ship and playership testing
//        } else if let obj = classA as? SpaceshipBase {
//            if !(o is CPPlayerShip) {
//            }
//        }
//        else if let obj = classB as? CPObject {
//            if !(obj is CPPlayerShip) {
//                ObjAndUnknown(obj: obj, unknown: classB)
//            } else {
//
//            }
//        }
        }
        
    }
    
    func ObjAndUnknown(obj: CPObject, unknown: AnyObject){
        if let obj2 = unknown as? CPObject {
            objAndObj(obj1: obj, obj2: obj2)
        }
        if let playership = unknown as? CPPlayerShip {
            objAndPlayer(obj: obj, player: playership)
        }
        if let ship = unknown as? CPSpaceshipBase {
            objAndEnemy(obj: obj, enemy: ship)
        }
    }
    
    func shipAndUnknown(ship: CPSpaceshipBase, unknown: AnyObject){
        
    }
    
    
    
    // The following funcs will handle all collsion
    //=========================================================
    
    func handleCheckpoint(cp: CPCheckpoint){
        Global.loadScene(s: "MainMenu")
    }
    
    func objAndPlayer(obj: CPObject, player: CPPlayerShip){
        switch obj.action {
        case .DamagingExplode:
            sClass.triggerExplosion(origin: obj.node.position, radius: obj.blastRadius)
            break;
            
        case .DirectDamage:
            player.changeHealth(delta: -1)
            break;
            
        case .HarmlessExplode:
            break;
            
        case .None:
            return
            
        case .RewardObject:
            break;
        }
    }
    
    func objAndEnemy(obj: CPObject, enemy: CPSpaceshipBase){
        switch obj.action {
        case .DamagingExplode:
            sClass.triggerExplosion(origin: obj.node.position, radius: obj.blastRadius)
            break;
            
        case .DirectDamage:
            enemy.changeHealth(delta: -1)
            break;
            
        case .HarmlessExplode:
            break;
            
        case .None:
            return
            
        case .RewardObject:
            return;
        }
        
        if (obj.isBreakable) {
            obj.node.removeFromParent()
        }
    }
    
    func objAndObj(obj1: CPObject, obj2: CPObject){
        obj1.changeHealth(delta: -1)
        obj2.changeHealth(delta: -1)
    }
    
    func playerAndEnemy(player: CPPlayerShip, enemy: CPSpaceshipBase) {
        enemy.destroyShip()
        player.changeHealth(delta: -1)
    }
}
