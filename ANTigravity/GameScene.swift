import SpriteKit
import GameplayKit

let PaddleCategoryName = "paddle"
let GameMessageName = "gameMessage"
let LeftCategoryName = "left"
let RightCategoryName = "right"

let BottomCategory : UInt32 = 0x1 << 0
let PaddleCategory : UInt32 = 0x1 << 1
let BorderCategory : UInt32 = 0x1 << 2


private var currentPolygonSpawnTime : TimeInterval = 0
private var polygonSpawnRate        : TimeInterval = 2.0
private let random = GKARC4RandomSource()


// this represents the slowest speed at which our shapes will travel
let TickLengthLevelOne = TimeInterval(600) // ms
// == every 6/10ths of a second, our shape should descend


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // textures used on blocks
    let ovalTexture = SKTexture(imageNamed: "Oval")
    let squareTexture = SKTexture(imageNamed: "Square")
    
    
    // closure!!
    var tick : (() -> ())?
    
    // GameScene current tick length
    var tickLengthMillis = TickLengthLevelOne
    var lastTick : NSDate?
    
    var isFingerOnLeft = false
    var isFingerOnRight = false
    
    //var firstBlock : BlockProperties = BlockProperties(color: BlockColor.random(), shape: BlockShape.random())
    
    private var lastUpdateTime : TimeInterval = 0
    
    override func sceneDidLoad() {
        self.lastUpdateTime = 0
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        let borderBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        borderBody.friction = 0
        self.physicsBody = borderBody
        
        // creates an edge-based body that spans the bottom of the screen
        let bottomRect = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.width, height: 1)
        let bottom = SKNode()
        bottom.physicsBody = SKPhysicsBody(edgeLoopFrom: bottomRect)
        addChild(bottom)

        
        // removes gravity from the scene, applying a -2j force instead
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -2.0)
        
        physicsWorld.contactDelegate = self

        //let block = childNode(withName: firstBlock.BlockCategoryName) as! SKSpriteNode
        let paddle = childNode(withName: PaddleCategoryName) as! SKSpriteNode
        
        
        bottom.physicsBody!.categoryBitMask = BottomCategory
        //block.physicsBody!.categoryBitMask = firstBlock.BlockCategory
        paddle.physicsBody!.categoryBitMask = PaddleCategory
        borderBody.categoryBitMask = BorderCategory
        
//        block.physicsBody!.contactTestBitMask = BottomCategory
//        
//        block.physicsBody!.contactTestBitMask = PaddleCategory
//        
//        block.physicsBody!.affectedByGravity = true
//        block.alpha = 1

    }

    
    // MARK: - touch handler
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let touchLocation = touch!.location(in: self)
        
        // TESTING THE WATERS
        //spawnPolygon()
        
        if let body = physicsWorld.body(at: touchLocation) {
            //print(body.node!.name)
            if body.node!.name == RightCategoryName {
                print("Began touch on paddle")
                isFingerOnRight = true
            }
        }
        if let body = physicsWorld.body(at: touchLocation) {
            //print(body.node!.name)
            if body.node!.name == LeftCategoryName {
                print("Began touch on paddle")
                isFingerOnLeft = true
            }
        }

        if isFingerOnRight {
            let paddle = childNode(withName: "paddle") as! SKSpriteNode
            paddle.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
            paddle.physicsBody!.applyImpulse(CGVector(dx: 7, dy: 0))
            print("RIGHT!!!!")
        }
        if isFingerOnLeft {
            let paddle = childNode(withName: "paddle") as! SKSpriteNode
            paddle.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
            paddle.physicsBody!.applyImpulse(CGVector(dx: -7, dy: 0))
            print("LEFT!!!!!!")
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        if isFingerOnRight {
//           let paddle = childNode(withName: "paddle") as! SKSpriteNode
//            paddle.physicsBody!.applyImpulse(CGVector(dx: 2, dy: 0))
//            print("RIGHT!!!!")
//        }
//        if isFingerOnLeft {
//            let paddle = childNode(withName: "paddle") as! SKSpriteNode
//            paddle.physicsBody!.applyImpulse(CGVector(dx: -2, dy: 0))
//            print("LEFT!!!!!!")
//        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isFingerOnRight = false
        isFingerOnLeft = false
    }
    
    
    // MARK: - collision handler
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody

        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        print("HAHHAHAHAHA")
//        if firstBody.categoryBitMask == firstBlock.BlockCategory && secondBody.categoryBitMask == BottomCategory {
//            print("Hit bottom. First contact has been made.")
//        }
//        
//        if firstBody.categoryBitMask == firstBlock.BlockCategory && secondBody.categoryBitMask == PaddleCategory {
//            
//            //let ball2 = childNode(withName: Ball2CategoryName) as! SKSpriteNode
//            print("OIOIOIOIOIOIOI")
//            //ball2.alpha = 1
//            //  ball2.physicsBody?.affectedByGravity = true
//            
//        }
    }
    
    
    // MARK: - handling time
    
    override func update(_ currentTime: CFTimeInterval) {
        /* Called before rendering each frame */
        
        // GUARD: if let lastTick != lastTick, the else block is executed
//        guard let lastTick = lastTick else {
//            // game is in a paused state == not reporting elapsed ticks
//            return
//        }
//        
//        let timePassed = lastTick.timeIntervalSinceNow * -1000.0 // *-1000 so the result is positive
//        
//        
//        // checks if the time passed is bigger than the time period we established at the beginning
//        if timePassed > tickLengthMillis {
//            
//            // if it is, we report a tick!
//            self.lastTick = NSDate()
//            tick?()
//        }
        
        // Initialize _lastUpdateTime if it has not already been
        if (self.lastUpdateTime == 0) {
            self.lastUpdateTime = currentTime
        }
        
        // Calculate time since last update
        let dt = currentTime - self.lastUpdateTime
        self.lastUpdateTime = currentTime
        
        // Update the Spawn Timer
        currentPolygonSpawnTime += dt
        
        if currentPolygonSpawnTime > polygonSpawnRate {
            currentPolygonSpawnTime = 0
            spawnPolygon()
        }
    }
//    
//    func startTicking() {
//        lastTick = NSDate()
//    }
//    
//    func stopTicking() {
//        lastTick = nil
//    }
//    
    
    // MARK: - block randomizer
    
    func spawnPolygon() {
        
        let blockProperties: BlockProperties = BlockProperties(color: BlockColor.random(), shape: BlockShape.random())
        
        var block: SKSpriteNode
        
        if blockProperties.shape.spriteName == "rectangle" {
            block = SKSpriteNode(texture: squareTexture, size: CGSize(width: 100, height: 29))
            block.physicsBody = SKPhysicsBody(texture: squareTexture, size: block.size)
        }
        else if blockProperties.shape.spriteName == "oval" {
            block = SKSpriteNode(texture: ovalTexture, size: CGSize(width: 29, height: 29))
            block.physicsBody = SKPhysicsBody(texture: ovalTexture, size: block.size)
        }
        else if blockProperties.shape.spriteName == "square" {
            block = SKSpriteNode(texture: squareTexture, size: CGSize(width: 29, height: 29))
            block.physicsBody = SKPhysicsBody(texture: squareTexture, size: block.size)
        }
        else if blockProperties.shape.spriteName == "line" {
            block = SKSpriteNode(texture: squareTexture, size: CGSize(width: 70, height: 5))
            block.physicsBody = SKPhysicsBody(texture: squareTexture, size: block.size)
        }
        else {
            print("ALGO ERRADO COM O TIPO DO BLOCO")
            exit(2)
        }
        
        var randomPosition = abs(CGFloat(random.nextInt()).truncatingRemainder(dividingBy: size.width))
        
        // 87 é a largura do botao que move a plataforma
        while (randomPosition - block.size.width / 2) < 87 || (randomPosition + block.size.width / 2) > UIScreen.main.bounds.width - 87 {
            randomPosition = abs(CGFloat(random.nextInt()).truncatingRemainder(dividingBy: size.width))
        }
        
        block.position = CGPoint(x: randomPosition, y: size.height)
        
        block.physicsBody?.restitution = 0.2
        block.physicsBody?.mass = 0.0005
        block.physicsBody?.friction = 0.98
        
        
        addChild(block)
        
        block.alpha = 1
    }
}
