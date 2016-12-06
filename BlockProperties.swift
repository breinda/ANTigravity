import Foundation
import UIKit

class BlockProperties {
    
    var BlockCategory : UInt32 = 0
    let BlockCategoryName : String
    let BlockShape : Shape
    
    enum Shape : String {
        case rectangle
        case oval
        case square
        case line
    }
    
    // TO DO: switch Slanted para objetos caindo nao-perpendicularmente
    
    init(inputShape: String) {
        
        //blockShape = Shape(rawValue: inputShape)!
        
        if let bShape = Shape(rawValue: inputShape) {
            
            BlockShape = bShape
            
            switch BlockShape {
            case .rectangle:
                BlockCategory = 0x1 << 5
                
            case .oval:
                BlockCategory = 0x1 << 6
                
            case .square:
                BlockCategory = 0x1 << 7
                
            case .line:
                BlockCategory = 0x1 << 8
            }
            
            BlockCategoryName = BlockShape.rawValue
            
        } else {
            print("There's no Shape named \(inputShape)")
            exit(1)
        }
    
    }
    
}
