//
//  GameScene.swift
//  FlappyOba
//
//  Created by Obatola Seward-Evans on 6/6/16.
//  Copyright (c) 2016 Obatola Seward-Evans. All rights reserved.
//

import SpriteKit


struct PhysicsCategory {
    static let character: UInt32 = 0x1 << 1
    static let ground: UInt32 = 0x1 << 2
    static let wall: UInt32 = 0x1 << 3
}

class GameScene: SKScene {
    
    // MARK: - Properties
    
    let groundImageName = "Flappy_Ground"
    let characterImageName = "Flappy_Character"
    let wallImageName = "Flappy_Wall"
    
    var ground = SKSpriteNode()
    var character = SKSpriteNode()
    var wallPair = SKNode()
    
    var moveAndRemove = SKAction()
    
    var gameStarted = Bool()
    
    
    // MARK: - View
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        /* GROUND */
        
        // Set up ground image...
        ground = SKSpriteNode(imageNamed: groundImageName)
        ground.setScale(0.5)
        ground.position = CGPoint(x: self.frame.width / 2, y: 0 + ground.frame.height / 2)
        ground.zPosition = 3 // set ground as 3rd layer (foreground)
        
        // Set up ground physics...
        ground.physicsBody = SKPhysicsBody(rectangleOfSize: ground.size) // Size of physics body is size of image.
        ground.physicsBody?.categoryBitMask = PhysicsCategory.ground // Ground is a ground-physics-category.
        ground.physicsBody?.collisionBitMask = PhysicsCategory.character // Detect collision with character.
        ground.physicsBody?.contactTestBitMask = PhysicsCategory.character // Test whether character and ground collided.
        ground.physicsBody?.affectedByGravity = false // Not affected by gravity.
        ground.physicsBody?.dynamic = false // Dont move if hit.
        
        // Add ground to the scene.
        self.addChild(ground)
        
        
        /* CHARACTER */
        
        // Set up character image...
        character = SKSpriteNode(imageNamed: characterImageName)
        character.size = CGSize(width: 60, height: 70)
        character.position = CGPoint(x: self.frame.width / 2 - character.frame.width, y: self.frame.height / 2)
        character.zPosition = 2 // set ghost as second layer (middleground)
        
        // Set up character physics...
        character.physicsBody = SKPhysicsBody(circleOfRadius: character.frame.height / 2)
        character.physicsBody?.categoryBitMask = PhysicsCategory.character
        character.physicsBody?.collisionBitMask = PhysicsCategory.ground | PhysicsCategory.wall
        character.physicsBody?.contactTestBitMask = PhysicsCategory.ground | PhysicsCategory.wall
        character.physicsBody?.affectedByGravity = false // False until game starts.
        character.physicsBody?.dynamic = true
        
        // Add character to the scene:
        self.addChild(character)
        
        /* WALL */
        createWallPair()
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        
        if gameStarted == false {
            // Game is just starting.
            
            // Spawn walls...
            let spawn = SKAction.runBlock({
                () in
                self.createWallPair()
            })
            
            let delay = SKAction.waitForDuration(2.0)
            let spawnDelay = SKAction.sequence([spawn, delay])
            let spawnDelayForever = SKAction.repeatActionForever(spawnDelay)
            self.runAction(spawnDelayForever)
            
            let distance = CGFloat(self.frame.width + wallPair.frame.width)
            let moveWalls = SKAction.moveByX(-distance, y: 0, duration: NSTimeInterval(0.01 * distance))
            let removeWalls = SKAction.removeFromParent()
            moveAndRemove = SKAction.sequence([moveWalls, removeWalls])
            
            character.physicsBody?.affectedByGravity = true
            
            gameStarted = true
            
        } else {
            
        }
        
        character.physicsBody?.velocity = CGVector(dx: 0, dy: 0) // No change in velocity.
        character.physicsBody?.applyImpulse(CGVectorMake(0, 90)) // Jump up by 90.
        
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    
    // MARK: - Helper Functions
    
    func createWallPair() {
        
        wallPair = SKNode()
        let GAP: CGFloat = 350
        
        // Set up images / scale / position...
        let topWall = SKSpriteNode(imageNamed: wallImageName)
        let bottomWall = SKSpriteNode(imageNamed: wallImageName)
        
        topWall.setScale(0.5)
        bottomWall.setScale(0.5)
        
        topWall.position = CGPoint(x: self.frame.width, y: self.frame.height / 2 + GAP)
        bottomWall.position = CGPoint(x: self.frame.width, y: self.frame.height / 2 - GAP)
        
        topWall.zRotation = CGFloat(M_PI) // rotate 180° in radians.
        
        // Set up physics...
        topWall.physicsBody = SKPhysicsBody(rectangleOfSize: topWall.size)
        topWall.physicsBody?.categoryBitMask = PhysicsCategory.wall
        topWall.physicsBody?.collisionBitMask = PhysicsCategory.character
        topWall.physicsBody?.contactTestBitMask = PhysicsCategory.character
        topWall.physicsBody?.affectedByGravity = false
        topWall.physicsBody?.dynamic = false
        
        bottomWall.physicsBody = SKPhysicsBody(rectangleOfSize: bottomWall.size)
        bottomWall.physicsBody?.categoryBitMask = PhysicsCategory.wall
        bottomWall.physicsBody?.collisionBitMask = PhysicsCategory.character
        bottomWall.physicsBody?.contactTestBitMask = PhysicsCategory.character
        bottomWall.physicsBody?.affectedByGravity = false
        bottomWall.physicsBody?.dynamic = false
        
        // Add top and bottom walls to the parent node, wallPair...
        wallPair.addChild(topWall)
        wallPair.addChild(bottomWall)
        
        wallPair.zPosition = 1 // send to the back of the scene
        
        wallPair.runAction(moveAndRemove)
        
        // Add wall pair to screne.
        self.addChild(wallPair)
    }
}
