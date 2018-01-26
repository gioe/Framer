//  HUD.swift
//  BouncyAR
//
//  Created by Bjarne Lundgren on 19/08/2017.
//  Copyright © 2017 Silicon.dk ApS. All rights reserved.
//

import Foundation
import SpriteKit

private let OPTION_YOFFSET: CGFloat = 60

public enum MenuOption: String, HUDOption {
    case newWall = "newWall"
    case start = "start"
    case cancelWall = "cancelWall"
    
    var id: String {
        return rawValue
    }
    
    var title: String {
        switch self {
        case .newWall: return "NEW WALL"
        case .start: return "START"
        case .cancelWall: return "CANCEL"
        }
    }
}

protocol HUDOption {
    var id: String { get }
    var title: String { get }
}

class HUD {
    class func present(options:[HUDOption], in scene:SKScene) {
        for i in 0..<options.count {
            let labelNode = SKLabelNode()
            labelNode.text = options[i].title
            labelNode.name = options[i].id
            labelNode.position = CGPoint(x: 20, y: CGFloat(i + 1) * OPTION_YOFFSET)
            labelNode.horizontalAlignmentMode = .left
            labelNode.verticalAlignmentMode = .center
            scene.addChild(labelNode)
        }
    }
    
    class func remove(options:[HUDOption], in scene:SKScene) {
        for option in options {
            scene.childNode(withName: option.id)?.removeFromParent()
        }
    }
}

