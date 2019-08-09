//
//  ViewController.swift
//  practice-adding-plane-3
//
//  Created by Maher Bhavsar on 25/07/19.
//  Copyright © 2019 Seven Dots. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        //sceneView.debugOptions = [SCNDebugOptions.showWireframe, SCNDebugOptions.showFeaturePoints, SCNDebugOptions.showCreases]
        
        //        // Create a new scene
        //        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        //        // Set the scene to the view
        //        sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        UIApplication.shared.isIdleTimerDisabled = true
        self.sceneView.autoenablesDefaultLighting = false
        // Run the view's session
        sceneView.session.run(configuration)
        
        addGestures()
    }
    
    func addGestures () {
        let tapped = UITapGestureRecognizer(target: self, action: #selector(tapGesture))
        
        sceneView.addGestureRecognizer(tapped)
    }
    
    @objc func tapGesture (sender: UITapGestureRecognizer) {
        let location = sender.location(in: sceneView)
        let hitTest = sceneView.hitTest(location, types: .existingPlaneUsingExtent)
        
        if hitTest.isEmpty {
            print("No Plane Detected")
        } else {
            sceneView.scene.rootNode.enumerateChildNodes { (child, _) in
                if child.name == "MeshNode" || child.name == "TextNode" {
                    child.removeFromParentNode()
                }
            }
            let scene = SCNScene(named: "art.scnassets/ship.scn")!
            let node = scene.rootNode.childNode(withName: "ship", recursively: false)
            //node?.geometry?.firstMaterial?.diffuse.contents = UIImage()
            
            let columns = hitTest.first?.worldTransform.columns.3
            
            node!.position = SCNVector3(x: columns!.x, y: columns!.y, z: columns!.z)
            
            sceneView.scene.rootNode.addChildNode(node!)
            
            
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    // MARK: - ARSCNViewDelegate
    
    /*
     // Override to create and configure nodes for anchors added to the view's session.
     func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
     let node = SCNNode()
     
     return node
     }
     */
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        let meshNode : SCNNode
        let textNode : SCNNode
        guard let planeAnchor = anchor as? ARPlaneAnchor else {return}
        
        
        guard let meshGeometry = ARSCNPlaneGeometry(device: sceneView.device!)
            else {
                fatalError("Can't create plane geometry")
        }
        meshGeometry.update(from: planeAnchor.geometry)
        meshNode = SCNNode(geometry: meshGeometry)
        meshNode.opacity = 0.6
        meshNode.name = "MeshNode"
        
        guard let material = meshNode.geometry?.firstMaterial
            else { fatalError("ARSCNPlaneGeometry always has one material") }
        material.diffuse.contents = UIColor.blue
        
        node.addChildNode(meshNode)
        
        let textGeometry = SCNText(string: "Plane", extrusionDepth: 1)
        textGeometry.font = UIFont(name: "Futura", size: 75)
        
        textNode = SCNNode(geometry: textGeometry)
        textNode.name = "TextNode"
        
        textNode.simdScale = SIMD3(repeating: 0.0005)
        textNode.eulerAngles = SCNVector3(x: Float(-90.degreesToradians), y: 0, z: 0)
        
        node.addChildNode(textNode)
        
        textNode.centerAlign()
        
        
        print("did add plane node")
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        let planeNode = node.childNode(withName: "MeshNode", recursively: false)
        
        if let planeGeometry = planeNode?.geometry as? ARSCNPlaneGeometry {
            planeGeometry.update(from: planeAnchor.geometry)
        }
        
        
        
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}


extension SCNNode {
    func centerAlign() {
        let (min, max) = boundingBox
        let extents = ((max) - (min))
        simdPivot = float4x4(translation: SIMD3((extents / 2) + (min)))
    }
}

extension float4x4 {
    init(translation vector: SIMD3<Float>) {
        self.init(SIMD4(1, 0, 0, 0),
                  SIMD4(0, 1, 0, 0),
                  SIMD4(0, 0, 1, 0),
                  SIMD4(vector.x, vector.y, vector.z, 1))
    }
}

func + (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
}
func - (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x - right.x, left.y - right.y, left.z - right.z)
}
func / (left: SCNVector3, right: Int) -> SCNVector3 {
    return SCNVector3Make(left.x / Float(right), left.y / Float(right), left.z / Float(right))
}
extension Int {
    var degreesToradians : Double {return Double(self) * .pi/180}
}

//extension Float {
//    var degreesToradians : Double {return Double(self) * .pi/180}
//}
//extension Double {
//    var degreesToradians : Double {return Double(self) * .pi/180}
//}
