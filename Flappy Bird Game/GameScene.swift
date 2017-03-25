//
//  GameScene.swift
//  Flappy Bird Game
//
//  Created by Vaibhav Kumar Singh on 24/03/17.
//  Copyright © 2017 Vaibhav Kumar Singh. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var bird = SKSpriteNode()
    var bg = SKSpriteNode()
    var scoreLabel = SKLabelNode()
    var gameOverLabel = SKLabelNode()
    var timer = Timer()
     var gameOver = false
    var  score  = 0
    
    enum colliderType : UInt32{
        
        case bird = 1
        case object = 2
        case gap = 4
        
    }
    
   
    func makePipes(){
        
        let movingPipes = SKAction.move(by: CGVector(dx: -2 * self.frame.width ,dy: 0 ), duration: TimeInterval(self.frame.width/100))
        let removePipes = SKAction.removeFromParent()
        let moveANdRemovePipes = SKAction.sequence([movingPipes,removePipes])
        
        
        let movementAmount = arc4random() % UInt32(self.frame.height/2)
        let pipeOffset = CGFloat(movementAmount) - self.frame.height/4
        
        let gapHeight = bird.size.height * 4
        let pipeTexture = SKTexture(imageNamed: "pipe1.png")
        let pipe1 = SKSpriteNode(texture: pipeTexture)
        pipe1.position = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY + pipeTexture.size().height/2 + gapHeight/2 + pipeOffset)
        
        pipe1.physicsBody = SKPhysicsBody(rectangleOf: pipeTexture.size())
        pipe1.run(moveANdRemovePipes)
        pipe1.physicsBody?.isDynamic = false
       
        pipe1.physicsBody!.contactTestBitMask = colliderType.object.rawValue
        pipe1.physicsBody!.categoryBitMask = colliderType.object.rawValue
        pipe1.physicsBody!.collisionBitMask = colliderType.object.rawValue
        pipe1.zPosition = -1
        
        self.addChild(pipe1)
        
        
        let pipeTexture2 = SKTexture(imageNamed: "pipe2.png")
        let pipe2 = SKSpriteNode(texture: pipeTexture2)
        pipe2.position = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY - pipeTexture.size().height/2 - gapHeight/2 + pipeOffset)
        pipe2.physicsBody = SKPhysicsBody(rectangleOf: pipeTexture2.size())
        pipe2.run(moveANdRemovePipes)
        pipe2.physicsBody?.isDynamic = false
        
        pipe2.physicsBody!.contactTestBitMask = colliderType.object.rawValue
        pipe2.physicsBody!.categoryBitMask = colliderType.object.rawValue
        pipe2.physicsBody!.collisionBitMask = colliderType.object.rawValue
        pipe2.zPosition = -1
        self.addChild(pipe2)
        
        
        let gap = SKNode()
        
        gap.position = CGPoint(x: self.frame.midX + self.frame.width , y: self.frame.midY + pipeOffset )
        gap.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: pipeTexture.size().width  , height: gapHeight))
        gap.physicsBody?.isDynamic = false
        gap.run(moveANdRemovePipes)
        
        gap.physicsBody!.contactTestBitMask = colliderType.bird.rawValue
        gap.physicsBody!.categoryBitMask = colliderType.gap.rawValue
        gap.physicsBody!.collisionBitMask = colliderType.gap.rawValue
        
        self.addChild(gap)
        
        
    }
    
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self

        setupGame()

    }
    
    
    
    
    func setupGame(){
        
        
        
        timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(makePipes), userInfo: nil, repeats: true)
        
        
        let bgTexture = SKTexture(imageNamed: "bg.png")
        let moveBgAnimation = SKAction.move(by: CGVector(dx: -bgTexture.size().width, dy: 0), duration: 7)
        let shiftBgAnimation = SKAction.move(by: CGVector(dx: bgTexture.size().width, dy: 0), duration: 0 )
        let repeatBackground = SKAction.repeatForever(SKAction.sequence([moveBgAnimation,shiftBgAnimation]))
        
        
        var i : CGFloat = 0
        
        while i<3{
            bg = SKSpriteNode(texture: bgTexture)
            
            bg.position = CGPoint(x: bgTexture.size().width * i, y: self.frame.midY )
            
            bg.size.height = self.frame.height
            bg.run(repeatBackground)
            bg.zPosition = -2
            self.addChild(bg)
            i += 1
            
            
        }
        let birdTexture = SKTexture(imageNamed: "flappy1.png")
        let birdTexture2 = SKTexture(imageNamed: "flappy2.png")
        bird = SKSpriteNode(texture: birdTexture)
        
        
        
        let animation = SKAction.animate(with: [birdTexture,birdTexture2], timePerFrame: 0.1)
        let makeBirdFlap = SKAction.repeatForever(animation)
        
        bird.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        
        bird.physicsBody = SKPhysicsBody(circleOfRadius: birdTexture.size().height/2)
        bird.physicsBody?.isDynamic = false
        
        
        bird.run(makeBirdFlap)
        bird.physicsBody!.contactTestBitMask = colliderType.object.rawValue
        bird.physicsBody!.categoryBitMask = colliderType.bird.rawValue
        bird.physicsBody!.collisionBitMask = colliderType.bird.rawValue
        self.addChild(bird)
        
        
        
        let  ground = SKNode()
        ground.position = CGPoint(x: self.frame.midX, y: -self.frame.height/2)
        ground.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.width, height: 1))
        ground.physicsBody?.isDynamic = false
        
        ground.physicsBody!.contactTestBitMask = colliderType.object.rawValue
        ground.physicsBody!.categoryBitMask = colliderType.object.rawValue
        ground.physicsBody!.collisionBitMask = colliderType.object.rawValue
        self.addChild(ground)
        
       
        scoreLabel.fontName = "Helvetica"
        scoreLabel.fontSize = 60
        scoreLabel.text = "0"
        
        scoreLabel.position = CGPoint(x: self.frame.midX ,y: self.frame.height/2 - 70)
        
        self.addChild(scoreLabel)
      
    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        if gameOver == false{
        
        if contact.bodyA.categoryBitMask == colliderType.gap.rawValue || contact.bodyA.categoryBitMask == colliderType.gap.rawValue{
            
            score += 1
            scoreLabel.text = String(score)
            bird.run(SKAction.playSoundFileNamed("score.wav", waitForCompletion: true))
    
        
        }
        
        
        else{
            bird.run(SKAction.playSoundFileNamed("hurt.wav", waitForCompletion: true))
       
            gameOver = true
            timer.invalidate()
      
            self.speed = 0
            
            
            gameOverLabel.fontName = "Helvetica"
            gameOverLabel.fontSize = 30
            gameOverLabel.text = " Game Over !! Tap to play again "
            
            gameOverLabel.position = CGPoint(x: self.frame.midX ,y: self.frame.midY)
            
            self.addChild(gameOverLabel)
        
            }
        }
    }
   
   
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if gameOver == false{
         

        bird.physicsBody?.isDynamic = true
        bird.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
        bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 68))
        bird.run(SKAction.playSoundFileNamed("flap.wav", waitForCompletion: false))
        }
        
        else{
            
            
            gameOver = false
            score = 0
            self.speed = 1
            self.removeAllChildren()
            
            
            setupGame()
            
            
            
        }
 
    }

    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
