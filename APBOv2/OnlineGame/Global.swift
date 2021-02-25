import SceneKit
import Foundation
import SpriteKit

public struct Global {
    public static var playerData = PlayerData()
    public static var gameData = GameData()
    public static let multiplayerHandler = MultiplayerHandler()
    
    static func loadScene(s: String) {
            
            /* 2) Load Game scene */
            guard let scene = SKScene(fileNamed: s) else {
                print("Could not make \(s), check the name is spelled correctly")
                return
            }
            /* 3) Ensure correct aspect mode */
            if UIDevice.current.userInterfaceIdiom == .pad {
                scene.scaleMode = .aspectFit
            } else {
                scene.scaleMode = .aspectFill
            }
            
            // Run in main thread
            /* 4) Start game scene */
        gameData.skView.presentScene(scene)
        
        }
    }
