//
//  Shape.swift
//  DAY06
//
//  Created by Zuleykha Pavlichenkova on 20.08.2022.
//

import UIKit

class ShapeView: UIView {
    enum Shape: Int, CaseIterable {
        case circle = 0
        case square
    }
    
    let shape: Shape
    
    override var collisionBoundsType: UIDynamicItemCollisionBoundsType {
        switch shape {
        case .circle:
            return .ellipse
        case .square:
            return .rectangle
        }
    }
    
    init(shape: Shape, frame: CGRect, color: UIColor) {
        self.shape = shape
        super.init(frame: frame)
        layer.masksToBounds = true
        clipsToBounds = true
        backgroundColor = color
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        switch shape {
        case .circle:
            layer.cornerRadius = 0.5 * layer.bounds.width
        default:
            break
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
