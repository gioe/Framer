//
//  ViewController.swift
//  Framer
//
//  Created by Matt Gioe on 10/24/17.
//  Copyright © 2017 Matt Gioe. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

enum AppState {
    case addingWall
    case menu
}

class ViewController: UIViewController, SCNPhysicsContactDelegate {
  
    
    @IBOutlet weak var statusTextView: UITextView!
//    var box: Box!
    var status: String!
    var startPosition: SCNVector3!
    var distance: Float!
    var trackingState: ARCamera.TrackingState!
    
    enum Mode {
        case waitingForMeasuring
        case measuring
    }
    
    var mode: Mode = .waitingForMeasuring {
        didSet {
            switch mode {
            case .waitingForMeasuring:
                status = "NOT READY"
            case .measuring:
//                box.update(
//                    minExtents: SCNVector3Zero, maxExtents: SCNVector3Zero)
//                box.isHidden = false
                startPosition = nil
                distance = 0.0
                setStatusText()
            }
        }
    }
    
    var trackState = WallTrackState.findFirstPoint
//    var mode = AppState.menu {
//        willSet {
//            if mode == .menu {
//                HUD.remove(options: [MenuOption.newWall, MenuOption.start],
//                           in: sceneView.overlaySKScene!)
//            }
//            if mode == .addingWall {
//                HUD.remove(options: [MenuOption.cancelWall],
//                           in: sceneView.overlaySKScene!)
//            }
//        }
//        didSet {
//            switch mode {
//            case .menu:
//                HUD.present(options: [MenuOption.newWall, MenuOption.start],
//                            in: sceneView.overlaySKScene!)
//            case .addingWall:
//                trackState = .findFirstPoint
//                HUD.present(options: [MenuOption.cancelWall],
//                            in: sceneView.overlaySKScene!)
//
//            }
//        }
//    }
    
    var walls = [(wallNode: SCNNode, wallStartPosition: SCNVector3, wallEndPosition: SCNVector3, wallId: String)]()

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        sceneView.delegate = self
//        sceneView.session.delegate = self
//        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
//
//        let scene = SCNScene()
//        sceneView.scene = scene
//
//        sceneView.overlaySKScene = SKScene(size: view.frame.size)
//
//        // with this we will stil get touches began..
//        sceneView.overlaySKScene!.isUserInteractionEnabled = false
//        sceneView.addGestureRecognizer(UITapGestureRecognizer(target: self,
//                                                              action: #selector(didTap)))
//        mode = .menu
        
        // Set the view's delegate
        sceneView.delegate = self
        // Set a padding in the text view
        statusTextView.textContainerInset =
            UIEdgeInsetsMake(20.0, 10.0, 10.0, 0.0)
        // Instantiate the box and add it to the scene
//        box = Box()
//        box.isHidden = true
//        sceneView.scene.rootNode.addChildNode(box)
        mode = .waitingForMeasuring
        // Set the initial distance
        distance = 0.0
        // Display the initial status
        setStatusText()
    }
    
    func setStatusText() {
        var text = "Status: \(status!)\n"
        text += "Tracking: \(getTrackigDescription())\n"
        text += "Distance: \(String(format:"%.2f cm", distance! * 100.0))"
        statusTextView.text = text
    }
    
    func getTrackigDescription() -> String {
        var description = ""
        if let t = trackingState {
            switch(t) {
            case .notAvailable:
                description = "TRACKING UNAVAILABLE"
            case .normal:
                description = "TRACKING NORMAL"
            case .limited(let reason):
                switch reason {
                case .excessiveMotion:
                    description =
                    "TRACKING LIMITED - Too much camera movement"
                case .insufficientFeatures:
                    description =
                    "TRACKING LIMITED - Not enough surface detail"
                case .initializing:
                    description = "INITIALIZING"
                }
            }
        }
        return description
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Create a session configuration with plane detection
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        sceneView.overlaySKScene?.size = view.frame.size
        //center = view.center
    }
    
//    private func anyPlaneFrom(location: CGPoint, usingExtent: Bool = true) -> (SCNNode, SCNVector3, ARPlaneAnchor)? {
//        let results = sceneView.hitTest(location,
//                                        types: usingExtent ? ARHitTestResult.ResultType.existingPlaneUsingExtent : ARHitTestResult.ResultType.existingPlane)
//
//        guard results.count > 0, let anchor = results[0].anchor as? ARPlaneAnchor, let node = sceneView.node(for: anchor) else {
//                return nil
//
//        }
//
//        return (node,
//                SCNVector3Make(results[0].worldTransform.columns.3.x, results[0].worldTransform.columns.3.y, results[0].worldTransform.columns.3.z),
//                anchor)
//    }
//
//    @objc func didTap(_ sender:UITapGestureRecognizer) {
//        let location = sender.location(in: sceneView)
//
//        switch mode {
//        case .menu: menuTapped(location: location)
//        case .addingWall: addingWallTapped(location: location)
//        }
//    }
//
//    private func menuTapped(location:CGPoint) {
//        guard let hudPosition = sceneView.overlaySKScene?.convertPoint(fromView: location),
//            let node = sceneView.overlaySKScene?.nodes(at: hudPosition).first,
//            let nodeName = node.name else { return }
//
//        switch nodeName {
//        case MenuOption.newWall.id:
//            mode = .addingWall
//
//        case MenuOption.start.id:
//            guard !walls.isEmpty else { return }
//            mode = .menu
//
//        default: break
//        }
//    }
//
//    private func addingWallTapped(location:CGPoint) {
//        if let hudPosition = sceneView.overlaySKScene?.convertPoint(fromView: location), let node = sceneView.overlaySKScene?.nodes(at: hudPosition).first, let nodeName = node.name {
//            switch nodeName {
//            case MenuOption.cancelWall.id:
//                if case .findSecondPoint(let trackingNode, _, _) = trackState {
//                    // cleanup!
//                    trackingNode.removeFromParentNode()
//                }
//                trackState = .findFirstPoint
//                mode = .menu
//            default: break
//            }
//            return
//        }
//
//        switch trackState {
//        case .findFirstPoint:
//            // begin wall placement
//
//            guard let planeData = anyPlaneFrom(location: location) else {
//                return
//
//            }
//
//            let trackingNode = TrackingNode.node(from: planeData.1,
//                                                 to: nil)
//            sceneView.scene.rootNode.addChildNode(trackingNode)
//            trackState = .findSecondPoint(trackingNode: trackingNode,
//                                         wallStartPosition: planeData.1,
//                                         originAnchor: planeData.2)
//        case .findSecondPoint(let trackingNode, let wallStartPosition, let originAnchor):
//            guard let planeData = anyPlaneFrom(location: self.view.center),
//                planeData.2 == originAnchor else { return }
//
//            trackingNode.removeFromParentNode()
//            let wallNode = Wall.node(from: wallStartPosition,
//                                     to: planeData.1)
//            sceneView.scene.rootNode.addChildNode(wallNode)
//
//            let newTrackingNode = TrackingNode.node(from: planeData.1,
//                                                    to: nil)
//            trackState = .findSecondPoint(trackingNode: newTrackingNode, wallStartPosition: planeData.1, originAnchor: originAnchor)
//
//            walls.append((wallNode: wallNode,
//                          wallStartPosition: wallStartPosition,
//                          wallEndPosition: planeData.1,
//                          wallId: UUID().uuidString))
//
//        default:fatalError()
//        }
//    }
    
    func measure() {
       
    }
    
}
    
extension ViewController: ARSessionDelegate {
    
    public func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        trackingState = camera.trackingState
    }
    
}

extension ViewController: ARSCNViewDelegate {
    public func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        // Call the method asynchronously to perform
        //  this heavy task without slowing down the UI
        DispatchQueue.main.async {
            self.measure()
        }
    }
}
