import SpriteKit
import GameplayKit

let PaddleCategoryName = "paddle"
let GameMessageName = "gameMessage"
let LeftCategoryName = "left"
let RightCategoryName = "right"
let BlockCategoryName = "block"
let WorldCategoryName = "world"

let BottomCategory  : UInt32 = 0x1 << 0
let PaddleCategory  : UInt32 = 0x1 << 1
let BorderCategory  : UInt32 = 0x1 << 2
let BlockCategory   : UInt32 = 0x1 << 3
let WorldCategory   : UInt32 = 0x1 << 4


private var currentPolygonSpawnTime : TimeInterval = 0
private var polygonSpawnRate        : TimeInterval = 3.0
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
        bottom.physicsBody?.friction = 0
        bottom.physicsBody?.mass = 1e6
        
        bottom.physicsBody?.categoryBitMask = BottomCategory
        bottom.physicsBody?.contactTestBitMask = BlockCategory
        bottom.alpha = 0
        
        addChild(bottom)
        
        
        // removes regular gravity from the scene, applying a -0.5j force instead
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -0.5)
        physicsWorld.contactDelegate = self

        let paddle = childNode(withName: PaddleCategoryName) as! SKSpriteNode
        
        paddle.texture = SKTexture(imageNamed: "antLog")
        paddle.physicsBody!.categoryBitMask = PaddleCategory
        borderBody.categoryBitMask = BorderCategory
        
        // buffer so that items aren’t deleted on screen
        var worldFrame = frame
        worldFrame.origin.x -= 100
        worldFrame.origin.y -= 100
        worldFrame.size.height += 200
        worldFrame.size.width += 200
        
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: worldFrame)
        self.physicsBody?.categoryBitMask = WorldCategory
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
            //paddle.physicsBody!.velocity = CGVector(dx: 120, dy: 0)
            paddle.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
            paddle.physicsBody!.applyImpulse(CGVector(dx: 12000, dy: 0))
            
            paddle.texture = SKTexture(imageNamed: "antLogInv")
            print("RIGHT!!!!")
        }
        if isFingerOnLeft {
            let paddle = childNode(withName: "paddle") as! SKSpriteNode
            //paddle.physicsBody!.velocity = CGVector(dx: -120, dy: 0)
            paddle.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
            paddle.physicsBody!.applyImpulse(CGVector(dx: -12000, dy: 0))
            
            paddle.texture = SKTexture(imageNamed: "antLog")
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
        
        print("COLLISION")
        
        if (contact.bodyA.categoryBitMask == BlockCategory) {
//            contact.bodyA.node?.physicsBody?.collisionBitMask = 0
//            contact.bodyA.node?.physicsBody?.categoryBitMask = 0
            
        } else if (contact.bodyB.categoryBitMask == BlockCategory) {
//            contact.bodyB.node?.physicsBody?.collisionBitMask = 0
//            contact.bodyB.node?.physicsBody?.categoryBitMask = 0
        }
        
        if contact.bodyA.categoryBitMask == BottomCategory {
            
            contact.bodyB.node?.physicsBody?.collisionBitMask = 0
            contact.bodyB.node?.physicsBody?.categoryBitMask = 0
            
            
            let alertView = UIAlertController(title: "BOO!",
                                              message: "you lost :(" as String, preferredStyle:.actionSheet)
            let okAction = UIAlertAction(title: "START OVER!", style: .default, handler: nil)
            alertView.addAction(okAction)
            self.view?.window?.rootViewController?.present(alertView, animated: true, completion: nil)
            
            game.IsOver = true
            self.view?.window?.rootViewController?.viewDidLoad()
            
        } else if contact.bodyB.categoryBitMask == BottomCategory {
            
            contact.bodyA.node?.physicsBody?.collisionBitMask = 0
            contact.bodyA.node?.physicsBody?.categoryBitMask = 0
            
            let alertView = UIAlertController(title: "BOO!",
                                              message: "you lost :(" as String, preferredStyle:.actionSheet)
            let okAction = UIAlertAction(title: "START OVER!", style: .default, handler: nil)
            alertView.addAction(okAction)
            self.view?.window?.rootViewController?.present(alertView, animated: true, completion: nil)
            
            game.IsOver = true
            self.view?.window?.rootViewController?.viewDidLoad()
        }
        
        
        // remove nodes after they hit the floor
        if contact.bodyA.categoryBitMask == WorldCategory {
            contact.bodyB.node?.removeFromParent()
            contact.bodyB.node?.physicsBody = nil
            contact.bodyB.node?.removeAllActions()
            
            print("EU HEIN")
        } else if contact.bodyB.categoryBitMask == WorldCategory {
            contact.bodyA.node?.removeFromParent()
            contact.bodyA.node?.physicsBody = nil
            contact.bodyA.node?.removeAllActions()
            
            print("EU HEIN")
        }
        
        
        
        
    }
    
    
    // MARK: - handling time
    
    override func update(_ currentTime: CFTimeInterval) {
        /* Called before rendering each frame */
        
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
        block.zPosition = 3
        block.physicsBody?.restitution = 0.1
        block.physicsBody?.mass = 50
        block.physicsBody?.friction = 1
        block.physicsBody?.angularDamping = 0.9
        block.physicsBody?.linearDamping = 0

        block.physicsBody?.categoryBitMask = BlockCategory
        block.physicsBody?.contactTestBitMask = BottomCategory | WorldCategory
        
        block.alpha = 1
        
        addChild(block)
        
        block.alpha = 1
    }
}
