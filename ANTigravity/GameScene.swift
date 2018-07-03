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


var blockNodeArray          : [SKSpriteNode] = [SKSpriteNode]()
var blockPropertiesArray    : [BlockProperties] = [BlockProperties]()
// amount of blocks that will fall at the current game level

var numberOfBlocksTotal     : Int = 2
var numberOfBlocksRemaining : Int = numberOfBlocksTotal

var currentLevelInt : Int = 1


private var currentPolygonSpawnTime : TimeInterval = 0
private var polygonSpawnRate        : TimeInterval = 3.0
private let random = GKARC4RandomSource()


// this represents the slowest speed at which our shapes will travel
let TickLengthLevelOne = TimeInterval(600) // ms
// == every 6/10ths of a second, our shape should descend


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    //let scale: CGFloat = 2.0
    //let damping: CGFloat = 0.98
    
    //var point: CGPoint?
    
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
        
        self.view?.isPaused = false
        
        blockPropertiesArray.removeAll()
        blockNodeArray.removeAll()
        populateBlockArray(numberOfBlocks: numberOfBlocksTotal)
        
//        let currentLevel = SKLabelNode()
//        currentLevel.ch
//        print("UHULLLLLL \(currentLevel?.text)")
        
        
        
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
        
        paddle.texture = SKTexture(imageNamed: "SliceAntsPaddle")
        
        paddle.zPosition = 3
        paddle.physicsBody?.affectedByGravity = true
        paddle.physicsBody?.restitution = 0.1
        paddle.physicsBody?.mass = 500
        paddle.physicsBody?.friction = 0.99
        paddle.physicsBody?.angularDamping = 1
        paddle.physicsBody?.linearDamping = 0
        
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
        
        
        let tree = childNode(withName: "tree") as! SKSpriteNode
        var currentLevel = tree.childNode(withName: "currentLevel") as! SKLabelNode
        
        print("UHULLLLLL \(String(describing: currentLevel.text))")
        
        currentLevel.text = String(currentLevelInt)
        
        
        let treeInv = childNode(withName: "treeInv") as! SKSpriteNode
        var remainingBlocks = treeInv.childNode(withName: "remainingBlocks") as! SKLabelNode
        
        print("UHULLLLLL \(String(describing: remainingBlocks.text))")
        
        remainingBlocks.text = String(numberOfBlocksRemaining)
    }

    
    // MARK: - touch handler
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let touchLocation = touch!.location(in: self)
        
        //point = touchLocation
        
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
            //paddle.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
            //paddle.physicsBody!.applyImpulse(CGVector(dx: 12000, dy: 0))
            paddle.physicsBody?.applyForce(CGVector(dx: 3000000, dy: 0))
            
            paddle.texture = SKTexture(imageNamed: "SliceAntsPaddleInv")
            print("RIGHT!!!!")
        }
        if isFingerOnLeft {
            let paddle = childNode(withName: "paddle") as! SKSpriteNode
            //paddle.physicsBody!.velocity = CGVector(dx: -120, dy: 0)
            //paddle.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
            //paddle.physicsBody!.applyImpulse(CGVector(dx: -12000, dy: 0))
            paddle.physicsBody?.applyForce(CGVector(dx: -3000000, dy: 0))
            
            paddle.texture = SKTexture(imageNamed: "SliceAntsPaddle")
            print("LEFT!!!!!!")
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        /*let touch = touches.first
        let touchLocation = touch!.location(in: self)
        
        point = touchLocation*/
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isFingerOnRight = false
        isFingerOnLeft = false
        
        let paddle = childNode(withName: "paddle") as! SKSpriteNode
        paddle.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
        
        
        //point = nil
    }
    
    /*func moveNodeToPoint(sprite:SKSpriteNode, point:CGPoint) {
        let dx: CGFloat = (point.x - sprite.position.x) * scale
        //let dy: CGFloat = (point.y - sprite.position.y) * scale
        sprite.physicsBody?.velocity = CGVector(dx: dx, dy: 0)
    }*/
    
    // MARK: - collision handler
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        print("COLLISION")
        
        /*if (contact.bodyA.categoryBitMask == PaddleCategory) {
            if (contact.bodyB.categoryBitMask == BlockCategory) {
                print("BOO")
                
                let blockFriction = contact.bodyB.node?.physicsBody?.friction
                
                if isFingerOnRight {
                    contact.bodyB.node?.physicsBody?.applyImpulse(CGVector(dx: 12000 * blockFriction!, dy: 0))
                }
                if isFingerOnLeft {
                    contact.bodyB.node?.physicsBody?.applyImpulse(CGVector(dx: 12000 * blockFriction!, dy: 0))
                }
                
            }
            
        } else if (contact.bodyB.categoryBitMask == PaddleCategory) {
            if (contact.bodyA.categoryBitMask == BlockCategory) {
                print("BOO")
                
                let blockFriction = contact.bodyA.node?.physicsBody?.friction
                
                if isFingerOnRight {
                    contact.bodyA.node?.physicsBody?.applyImpulse(CGVector(dx: 12000 * blockFriction!, dy: 0))
                }
                if isFingerOnLeft {
                    contact.bodyA.node?.physicsBody?.applyImpulse(CGVector(dx: 12000 * blockFriction!, dy: 0))
                }
            }
        }*/
        
        if contact.bodyA.categoryBitMask == BottomCategory {
            
            contact.bodyB.node?.physicsBody?.collisionBitMask = 0
            contact.bodyB.node?.physicsBody?.categoryBitMask = 0
            
            
            let alertView = UIAlertController(title: "BOO!",
                                              message: "you lost :(" as String, preferredStyle:.actionSheet)
            let okAction = UIAlertAction(title: "START OVER!", style: .default, handler: {(alert: UIAlertAction!) in
                game.IsOver = true
                self.view?.window?.rootViewController?.viewDidLoad()
            })
            
            alertView.addAction(okAction)
            self.view?.window?.rootViewController?.present(alertView, animated: true, completion: {
                numberOfBlocksRemaining = numberOfBlocksTotal
                
                let treeInv = self.childNode(withName: "treeInv") as! SKSpriteNode
                var remainingBlocks = treeInv.childNode(withName: "remainingBlocks") as! SKLabelNode
                
                print("UHULLLLLL \(String(describing: remainingBlocks.text))")
                
                remainingBlocks.text = String(numberOfBlocksRemaining)
                
                self.view?.isPaused = true
            })
        }
        
        else if contact.bodyB.categoryBitMask == BottomCategory {
            
            contact.bodyA.node?.physicsBody?.collisionBitMask = 0
            contact.bodyA.node?.physicsBody?.categoryBitMask = 0
            

            let alertView = UIAlertController(title: "BOO!",
                                              message: "you lost :(" as String, preferredStyle:.actionSheet)
            let okAction = UIAlertAction(title: "START OVER!", style: .default, handler: {(alert: UIAlertAction!) in
                game.IsOver = true
                self.view?.window?.rootViewController?.viewDidLoad()
            })
            
            alertView.addAction(okAction)
            self.view?.window?.rootViewController?.present(alertView, animated: true, completion: {
                numberOfBlocksRemaining = numberOfBlocksTotal
                
                let treeInv = self.childNode(withName: "treeInv") as! SKSpriteNode
                var remainingBlocks = treeInv.childNode(withName: "remainingBlocks") as! SKLabelNode
                
                print("UHULLLLLL \(String(describing: remainingBlocks.text))")
                
                remainingBlocks.text = String(numberOfBlocksRemaining)
                
                self.view?.isPaused = true
            })
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
            if (numberOfBlocksRemaining > 0) {
                currentPolygonSpawnTime = 0
                spawnPolygon()
            }
            
            else {
                let alertView = UIAlertController(title: "CONGRATULATIONS!!",
                                                  message: "you won! :D" as String, preferredStyle:.actionSheet)
                let okAction = UIAlertAction(title: "GO FORWARD!", style: .default, handler: {(alert: UIAlertAction!) in
                    game.IsOver = true
                    self.view?.window?.rootViewController?.viewDidLoad()
                })
                
                alertView.addAction(okAction)
                self.view?.window?.rootViewController?.present(alertView, animated: true, completion: {
                    numberOfBlocksTotal += 1
                    numberOfBlocksRemaining = numberOfBlocksTotal
                    
                    let treeInv = self.childNode(withName: "treeInv") as! SKSpriteNode
                    var remainingBlocks = treeInv.childNode(withName: "remainingBlocks") as! SKLabelNode
                    
                    print("UHULLLLLL \(String(describing: remainingBlocks.text))")
                    
                    remainingBlocks.text = String(numberOfBlocksTotal)
                    
                    currentLevelInt += 1
                    self.view?.isPaused = true
                })
            }
        }
        
        /////////////////////////////
        
        /*let paddle = childNode(withName: "paddle") as! SKSpriteNode
        
        if (point != nil) {
            moveNodeToPoint(sprite: paddle, point: point!)
        }
        else {
            // This will slow the circle over time when after the touch ends
            let dx = paddle.physicsBody!.velocity.dx * damping
            //let dy = paddle.physicsBody!.velocity.dy * damping
            paddle.physicsBody!.velocity = CGVector(dx: dx, dy: 0)
        }*/
    }

    
    // MARK: - Block Array handler
    
    func populateBlockArray(numberOfBlocks: Int) {
        
        var i = 0
        
        while (i < numberOfBlocks) {
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
            
            
            // randomise block position @ the top of the screen
            var randomPosition = abs(CGFloat(random.nextInt()).truncatingRemainder(dividingBy: size.width))
            
            // 100 é a largura do botao que move a plataforma + a arvore
            while (randomPosition - block.size.width / 2) < 100 || (randomPosition + block.size.width / 2) > UIScreen.main.bounds.width - 100 {
                randomPosition = abs(CGFloat(random.nextInt()).truncatingRemainder(dividingBy: size.width))
            }
            
            block.position = CGPoint(x: randomPosition, y: size.height)
            block.zPosition = 3
            block.physicsBody?.restitution = 0.1
            block.physicsBody?.mass = 50
            block.physicsBody?.friction = 0.9
            block.physicsBody?.angularDamping = 1
            block.physicsBody?.linearDamping = 0
            
            block.physicsBody?.categoryBitMask = BlockCategory
            block.physicsBody?.contactTestBitMask = BottomCategory | WorldCategory | PaddleCategory
            
            block.alpha = 1
            
            blockNodeArray.append(block)
            //print(blockNodeArray.last)
            blockPropertiesArray.append(blockProperties)
            print(blockPropertiesArray.last?.BlockCategoryName as Any)
            
            i += 1
        }
    }
    
    
    // MARK: - block randomizer
    
    func spawnPolygon() {
        
        addChild(blockNodeArray[numberOfBlocksRemaining - 1])
        
        numberOfBlocksRemaining -= 1
        
        let treeInv = childNode(withName: "treeInv") as! SKSpriteNode
        var remainingBlocks = treeInv.childNode(withName: "remainingBlocks") as! SKLabelNode
        
        print("UHULLLLLL \(String(describing: remainingBlocks.text))")
        
        remainingBlocks.text = String(numberOfBlocksRemaining)

    }
}
