//
//  ViewController.swift
//  DAY06
//
//  Created by Zuleykha Pavlichenkova on 18.08.2022.
//

import UIKit
import CoreMotion

protocol DynamicShapeBehavior: UIDynamicBehavior {
    func addItem(_ item: UIDynamicItem)
    func removeItem(_ item: UIDynamicItem)
}

class ViewController: UIViewController {
    private lazy var animator = UIDynamicAnimator(referenceView: view)
    
    private lazy var behaviors: [DynamicShapeBehavior] = [gravity, collision, elacticity]
    
    private let gravity: UIGravityBehavior = {
        let gravity = UIGravityBehavior()
        return gravity
    }()
    
    private lazy var collision: UICollisionBehavior = {
        let collision = UICollisionBehavior()
        collision.translatesReferenceBoundsIntoBoundary = true
        collision.collisionDelegate = self
        return collision
    }()
    
    private lazy var elacticity: UIDynamicItemBehavior = {
        let dynamic = UIDynamicItemBehavior()
        dynamic.elasticity = 1
        dynamic.resistance = 0
        dynamic.density = 2
        return dynamic
    }()
    
    private let density: UIDynamicItemBehavior = {
        let dynamic = UIDynamicItemBehavior()
        dynamic.density = 2
        return dynamic
    }()
    
    private var motionManager = CMMotionManager()
    private var motionQueue = OperationQueue()
    
    private let kMaxVelocity: Float = 500
    private let itemsHeight: CGFloat = 100
    private let itemsWidth: CGFloat = 100
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
//        activateAccelerometer()
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapGesture)))
        
    }
    
    @objc func handleTapGesture(_ gesture: UITapGestureRecognizer) {
        let x = gesture.location(in: view).x
        let y = gesture.location(in: view).y
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture))
        let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(handleRotationGesture))
        
        guard let shape = ShapeView.Shape(rawValue: .random(in: 0 ..< ShapeView.Shape.allCases.count)) else { return }
        let shapeView = ShapeView(
            shape: shape,
            frame: CGRect(
                origin: CGPoint(x: x - 0.5 * itemsWidth, y: y - 0.5 * itemsHeight),
                size: CGSize(width: itemsWidth, height: itemsHeight)
            ),
            color: .random
        )
        
        view.addSubview(shapeView)
        
        [panGesture, pinchGesture, rotationGesture] .forEach {
            shapeView.addGestureRecognizer($0)
            $0.delegate = self
        }
        
        ([gravity, collision] as [DynamicShapeBehavior]) .forEach { $0.addItem(shapeView)}
        if shape == .circle {
            elacticity.addItem(shapeView)
        } else {
            density.addItem(shapeView)
        }
        behaviors.forEach { animator.addBehavior($0) }
    }
    
    @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        guard let gestureView = gesture.view as? ShapeView, let superview = gestureView.superview else {return}
        
        let translation = gesture.translation(in: superview)
        switch gesture.state {
        case .began:
            gravity.removeItem(gestureView)
        case .changed:
            gestureView.shape == .circle ? elacticity.removeItem(gestureView) : density.removeItem(gestureView)
            collision.removeItem(gestureView)
            gestureView.center = CGPoint(
                x: gestureView.center.x + translation.x,
                y: gestureView.center.y + translation.y
            )
            gesture.setTranslation(.zero, in: superview)
            animator.updateItem(usingCurrentState: gestureView)
            gestureView.shape == .circle ? elacticity.addItem(gestureView) : density.addItem(gestureView)
            collision.addItem(gestureView)
        case .ended:
            gravity.addItem(gestureView)
        default:
            break
        }
    }
    
    @objc func handlePinchGesture(_ gesture: UIPinchGestureRecognizer) {
        guard let gestureView = gesture.view as? ShapeView, let superview = gestureView.superview else {return}
        switch gesture.state {
        case .began:
            gravity.removeItem(gestureView)
        case .changed:
            gestureView.shape == .circle ? elacticity.removeItem(gestureView) : density.removeItem(gestureView)
            collision.removeItem(gestureView)
            let newWidth = gestureView.layer.bounds.size.width * gesture.scale
            let newHeight = gestureView.layer.bounds.size.height * gesture.scale
            if newWidth < superview.bounds.width - 50 && newHeight < superview.bounds.height - 50 && newWidth > 10 && newHeight > 10 {
                
                gestureView.layer.bounds.size.width = newWidth
                gestureView.layer.bounds.size.height = newHeight
                gesture.scale = 1
            }
            gestureView.shape == .circle ? elacticity.addItem(gestureView) : density.addItem(gestureView)
            collision.addItem(gestureView)
        case .ended:
            gravity.addItem(gestureView)
        default:
            break
        }
    }
    
    @objc func handleRotationGesture(_ gesture: UIRotationGestureRecognizer) {
        guard let gestureView = gesture.view as? ShapeView else {return}
        switch gesture.state {
        case .began:
            gravity.removeItem(gestureView)
        case .changed:
            gestureView.shape == .circle ? elacticity.removeItem(gestureView) : density.removeItem(gestureView)
            collision.removeItem(gestureView)
            gestureView.transform = gestureView.transform.rotated(by: gesture.rotation)
            gesture.rotation = 0
            animator.updateItem(usingCurrentState: gestureView)
            gestureView.shape == .circle ? elacticity.addItem(gestureView) : density.addItem(gestureView)
            collision.addItem(gestureView)
        case .ended:
            gravity.addItem(gestureView)
        default:
            break
        }
    }
}

extension UIColor {
    static var random: UIColor {
        return UIColor(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1),
            alpha: 1.0
        )
    }
}

extension UIGravityBehavior: DynamicShapeBehavior {}
extension UICollisionBehavior: DynamicShapeBehavior {}
extension UIDynamicItemBehavior: DynamicShapeBehavior {}

extension ViewController: UICollisionBehaviorDelegate {
    private func activateAccelerometer() {
        motionManager.startDeviceMotionUpdates(to: motionQueue) { deviceMotion, _ in
            guard let motion = deviceMotion else {return}
            let gravity = motion.gravity
            DispatchQueue.main.async {
                self.gravity.gravityDirection = CGVector(
                    dx: gravity.x * 5,
                    dy: gravity.y * 5
                )
            }
        }
    }
}

extension ViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer is UILongPressGestureRecognizer || otherGestureRecognizer is UILongPressGestureRecognizer {
            return false
        } else { return true }
    }
}
