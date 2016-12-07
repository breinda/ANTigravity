import Foundation
import UIKit
import SpriteKit


let NumberOfColors: UInt32 = 6
let NumberOfShapes: UInt32 = 4


enum BlockColor: Int, CustomStringConvertible {
    
    case Blue = 0, Orange, Purple, Red, Teal, Yellow
    
    var spriteName: String {
        switch self {
        case .Blue:
            return "blue"
        case .Orange:
            return "orange"
        case .Purple:
            return "purple"
        case .Red:
            return "red"
        case .Teal:
            return "teal"
        case .Yellow:
            return "yellow"
        }
    }

    var description: String {
        return self.spriteName
    }
    
    // static function that creates a BlockColor using the rawvalue: Int initialiser
    static func random() -> BlockColor {
        return BlockColor(rawValue: Int(arc4random_uniform(NumberOfColors)))!
    }
}

enum BlockShape: Int, CustomStringConvertible {
    
    case Rectangle = 0, Oval, Square, Line
    
    var spriteName: String {
        switch self {
        case .Rectangle:
            return "rectangle"
        case .Oval:
            return "oval"
        case .Square:
            return "square"
        case .Line:
            return "line"
        }
    }
    
    var description: String {
        return self.spriteName
    }
    
    // static function that creates a BlockShape using the rawvalue: Int initialiser
    static func random() -> BlockShape {
        return BlockShape(rawValue: Int(arc4random_uniform(NumberOfShapes)))!
    }
}



class BlockProperties: CustomStringConvertible {
    
    var BlockCategory : UInt32 = 0
    let BlockCategoryName : String
    //let BlockShape : Shape
    
    let color: BlockColor
    var sprite: SKSpriteNode?
    let shape: BlockShape
    
    var colorName: String {
        return color.spriteName
    }
    
    var description: String {
        return "\(color), \(shape)"
    }
    
    
//    enum Shape : String {
//        case rectangle
//        case oval
//        case square
//        case line
//    }
    
    
    // TO DO: switch Slanted para objetos caindo nao-perpendicularmente
    
    init(color: BlockColor, shape: BlockShape) {
        
        //blockShape = Shape(rawValue: inputShape)!
        
        //if let bShape = shape.spriteName {
            
            //BlockShape = bShape
        
        self.color = color
        self.shape = shape
        
        if shape.spriteName == "rectangle" {
            BlockCategory = 0x1 << 5
            
        }
        else if shape.spriteName == "oval" {
            BlockCategory = 0x1 << 6
            
        }
        else if shape.spriteName == "square" {
            BlockCategory = 0x1 << 7
            
        }
        else if shape.spriteName == "line" {
            BlockCategory = 0x1 << 8
            
        }
        
        BlockCategoryName = shape.spriteName
    }
    
//        switch shape {
//            case :
//                BlockCategory = 0x1 << 5
//                
//            case .oval:
//                BlockCategory = 0x1 << 6
//                
//            case .square:
//                BlockCategory = 0x1 << 7
//                
//            case .line:
//                BlockCategory = 0x1 << 8
//            }
        
            //BlockCategoryName = BlockShape.rawValue
            //BlockCategoryName = shape.spriteName
            
//        } else {
//            print("There's no Shape named \(inputShape)")
//            exit(1)
//        }
    
    //}
    
}
