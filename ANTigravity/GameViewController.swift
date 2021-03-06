import UIKit
import SpriteKit

struct game {
    static var IsOver : Bool = false
}

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        if game.IsOver == true {
            goToGameScene()
            
            print("ENTREI")
            
            return
        }
        
        if let scene = GameScene(fileNamed:"GameScene") {
            // Configure the view.
            let skView = self.view as! SKView
            skView.showsFPS = true
            skView.showsNodeCount = true
            //skView.showsPhysics = true
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .aspectFit
            
            //game.IsOver = false
            
            skView.presentScene(scene)
        }
        
    }
    
    func goToGameScene() {
        game.IsOver = false
        viewDidLoad()
    }

    override var shouldAutorotate : Bool {
        return true
    }

    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden : Bool {
        return true
    }
}
