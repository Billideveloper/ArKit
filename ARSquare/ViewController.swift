//
//  ViewController.swift
//  ARSquare
//
//  Created by Ravi Thakur on 24/01/21.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    @IBOutlet weak var btn: UIButton!
    
    private let label : UILabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
//         Create a new scene
        let scene = SCNScene()
        
//         Set the scene to the view
        sceneView.scene = scene
        
        let tapgesture = UITapGestureRecognizer(target: self, action: #selector(tapped))

        self.sceneView.addGestureRecognizer(tapgesture)
        
    }
    
    @objc func tapped(recognizer: UIGestureRecognizer){
        
        let sceneView = recognizer.view as! SCNView
        let touchLocation = recognizer.location(in: sceneView)
        let hitTouch = sceneView.hitTest(touchLocation, options: [:])
        
        if !hitTouch.isEmpty {
            let node = hitTouch[0].node
            let material = node.geometry?.material(named: "Color")
            material?.diffuse.contents = UIColor.blue
        }
        
    }
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        DispatchQueue.main.async {
           
            self.label.text = "Plane Detected"
            
            UIView.animate(withDuration: 0.3) {
                self.label.alpha = 1.0
            } completion: { (Bool) in
                self.label.alpha = 0.0
            }
        }
    }
    
    
    
    
    
    func showBox(){
        
        let box = SCNBox(width: 0.3, height: 0.3, length: 0.3, chamferRadius: 0)
        
        let material = SCNMaterial()
        material.name = "Color"
        material.diffuse.contents = UIColor.red
        
        box.materials = [material]
        
        let node = SCNNode(geometry: box)
        node.position = SCNVector3(0, 0, -0.5)
        
        self.sceneView.scene.rootNode.addChildNode(node)
        
    }
    
    func showText(){
        
        let text = SCNText(string: "Welcome to World of AR", extrusionDepth: 1.0)
        
        text.firstMaterial?.diffuse.contents = UIColor.green
        
        
        let textNode = SCNNode(geometry: text)
        textNode.position = SCNVector3(0, 0.5, -0.5)
        textNode.scale = SCNVector3(0.02, 0.02, 0.02)
        
        self.sceneView.scene.rootNode.addChildNode(textNode)
        
        
        
    }
    
    
    
    
    @IBAction func button(_ sender: UIButton) {
        
        if sender.titleLabel?.text == "Box"{
            print("Im here")
            
            showBox()
            
            btn.setTitle("Text", for: .normal)
        }else{
            showText()
            btn.setTitle("Box", for: .normal)
        }
        
    }
    
    
    
    
    
    

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
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
