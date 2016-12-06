import SpriteKit
import GameplayKit

let BallCategoryName = "ball"
//let Ball2CategoryName = "ball2"
//let Ball3CategoryName = "ball3"
let PaddleCategoryName = "paddle"
let BlockCategoryName = "block"
let GameMessageName = "gameMessage"
let LeftCategoryName = "left"
let RightCategoryName = "right"
let BallCategory   : UInt32 = 0x1 << 0
let BottomCategory : UInt32 = 0x1 << 1
let BlockCategory  : UInt32 = 0x1 << 2
let PaddleCategory : UInt32 = 0x1 << 3
let BorderCategory : UInt32 = 0x1 << 4


private var currentRainDropSpawnTime : TimeInterval = 0
private var rainDropSpawnRate : TimeInterval = 0.5
private let random = GKARC4RandomSource()


class GameScene: SKScene, SKPhysicsContactDelegate {
  
    var isFingerOnLeft = false
    var isFingerOnRight = false
    //private var lastUpdateTime : TimeInterval = 0
    
//    override func sceneDidLoad() {
//        self.lastUpdateTime = 0
//    }
    
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

        
        // removes all gravity from the scene
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -2.0)
        
        physicsWorld.contactDelegate = self

        let ball = childNode(withName: BallCategoryName) as! SKSpriteNode
        
        //let ball2 = childNode(withName: Ball2CategoryName) as! SKSpriteNode
        //let ball3 = childNode(withName: Ball3CategoryName) as! SKSpriteNode
        let left = childNode(withName: LeftCategoryName) as! SKSpriteNode
        let right = childNode(withName: RightCategoryName) as! SKSpriteNode
        let paddle = childNode(withName: PaddleCategoryName) as! SKSpriteNode
        
//        ball2.alpha = 1
//        ball3.alpha = 1
        
        
        bottom.physicsBody!.categoryBitMask = BottomCategory
        ball.physicsBody!.categoryBitMask = BallCategory
        //ball2.physicsBody!.categoryBitMask = BallCategory
        //ball3.physicsBody!.categoryBitMask = BallCategory
        paddle.physicsBody!.categoryBitMask = PaddleCategory
        borderBody.categoryBitMask = BorderCategory
        
        ball.physicsBody!.contactTestBitMask = BottomCategory
        
        ball.physicsBody!.contactTestBitMask = PaddleCategory

    }
    
    func spawnPolygon() {
        let rainDrop = SKShapeNode(rectOf: CGSize(width: 20, height: 20))
        rainDrop.position = CGPoint(x: size.width / 2, y:  size.height / 2)
        rainDrop.fillColor = SKColor.blue
        rainDrop.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 20, height: 20))
        
        let randomPosition = abs(CGFloat(random.nextInt()).truncatingRemainder(dividingBy: size.width))
        rainDrop.position = CGPoint(x: randomPosition, y: size.height)
        
        addChild(rainDrop)
    }
    
    // MARK: - touch handler
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let touchLocation = touch!.location(in: self)
        
        if let body = physicsWorld.body(at: touchLocation) {
            print(body.node!.name)
            if body.node!.name == RightCategoryName {
                print("Began touch on paddle")
                isFingerOnRight = true
                
                print("")
                //spawnPolygon()
            }
        }
        if let body = physicsWorld.body(at: touchLocation) {
            print(body.node!.name)
            if body.node!.name == LeftCategoryName {
                print("Began touch on paddle")
                isFingerOnLeft = true
                //spawnPolygon()
            }
        }

        if isFingerOnRight {
            let paddle = childNode(withName: "paddle") as! SKSpriteNode
            paddle.physicsBody!.applyImpulse(CGVector(dx: 4, dy: 0))
            print("RIGHT!!!!")
        }
        if isFingerOnLeft {
            let paddle = childNode(withName: "paddle") as! SKSpriteNode
            paddle.physicsBody!.applyImpulse(CGVector(dx: -4, dy: 0))
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
        if firstBody.categoryBitMask == BallCategory && secondBody.categoryBitMask == BottomCategory {
            print("Hit bottom. First contact has been made.")

        }
        
        if firstBody.categoryBitMask == BallCategory && secondBody.categoryBitMask == PaddleCategory {
            
            //let ball2 = childNode(withName: Ball2CategoryName) as! SKSpriteNode
            print("OIOIOIOIOIOIOI")
            //ball2.alpha = 1
            //  ball2.physicsBody?.affectedByGravity = true
            
        }
        
    }
    
}
