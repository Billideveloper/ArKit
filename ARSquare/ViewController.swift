//
//  ViewController.swift
//  ARSquare
//
//  Created by Ravi Thakur on 24/01/21.
//

import UIKit
import SceneKit
import ARKit

enum BodyType : Int {
    case box = 1
    case plane = 2
    case car = 3
}

class ViewController: UIViewController, ARSCNViewDelegate {
    
    var planes = [overlayPlanes]()
    
    var boxes = [SCNNode]()

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
        
        registerGestureRecognizers()
        
    }
    
    
    private func registerGestureRecognizers() {
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        tapGestureRecognizer.numberOfTapsRequired = 1
        
        let doubletapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(doubletapp))
        doubletapGestureRecognizer.numberOfTapsRequired = 2
        
        tapGestureRecognizer.require(toFail: doubletapGestureRecognizer)
        
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
        self.sceneView.addGestureRecognizer(doubletapGestureRecognizer)
    }
    
    
    @objc func doubletapp(recognizer: UIGestureRecognizer){
        
        let sceneView = recognizer.view as! ARSCNView
        let touchLocation = recognizer.location(in: sceneView)
        
        let hitResults = sceneView.hitTest(touchLocation, options: [:])
        
        if !hitResults.isEmpty {
            
            guard let hitResult = hitResults.first else {
                return
            }
            
            let node = hitResult.node
            
            node.physicsBody?.applyForce(SCNVector3(hitResult.worldCoordinates.x * Float(2.0), 2.0, hitResult.worldCoordinates.z * Float(2.0)), asImpulse: true)
            
        }
        
    }
    
    
    @objc func tapped(recognizer: UIGestureRecognizer){
    
        let sceneView = recognizer.view as! ARSCNView
        let touchLocation = recognizer.location(in: sceneView)

        guard let query = sceneView.raycastQuery(from: touchLocation, allowing: .estimatedPlane, alignment: .horizontal) else {return}

        guard let results = sceneView.session.raycast(query).first else{
            return
        }
        addModel(hitResults: results)
       
        
    }
    
    
    
    func addModel(hitResults: ARRaycastResult){
        
        
        let scene = SCNScene(named: "chair.dae")!
        
        let node = scene.rootNode.childNode(withName: "SketchUp", recursively: true)
            
        node?.position = SCNVector3(x: hitResults.worldTransform.columns.3.x, y: hitResults.worldTransform.columns.3.y, z: hitResults.worldTransform.columns.3.z)
            
        node?.scale = SCNVector3(0.2,0.2,0.2)
            
        self.sceneView.scene.rootNode.addChildNode(node!)
            
        print("here ")
        
        
    }
    
    func addBox(hitResult: ARRaycastResult){
        
        print("Im added")
        
        let boxGeometry = SCNBox(width: 0.2, height: 0.2, length: 0.1, chamferRadius: 0)
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        boxGeometry.materials = [material]
        
        
        let boxNode = SCNNode(geometry: boxGeometry)
        //adding physics to box
        boxNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        //adding collision to box
        boxNode.physicsBody?.categoryBitMask = BodyType.box.rawValue
        
        self.boxes.append(boxNode)
        //for flat position
//        boxNode.position = SCNVector3(hitResult.worldTransform.columns.3.x,hitResult.worldTransform.columns.3.y + Float(boxGeometry.height/2), hitResult.worldTransform.columns.3.z)
        
        //for above the plane to see physics on object
        
        boxNode.position = SCNVector3(hitResult.worldTransform.columns.3.x,hitResult.worldTransform.columns.3.y +    Float(0.5), hitResult.worldTransform.columns.3.z)
        
        self.sceneView.scene.rootNode.addChildNode(boxNode)
        
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
        
//        DispatchQueue.main.async {
//
//            self.label.text = "Plane Detected"
//
//            UIView.animate(withDuration: 0.3) {
//                self.label.alpha = 1.0
//            } completion: { (Bool) in
//                self.label.alpha = 0.0
//            }
//        }
        
        if !(anchor is ARPlaneAnchor) {
            return
        }
        
        let plane = overlayPlanes(anchor: anchor as! ARPlaneAnchor)
        self.planes.append(plane)
        node.addChildNode(plane)
        
    }
    
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        
        let plane = self.planes.filter { plane in
            return plane.anchor.identifier == anchor.identifier
            }.first
        
        if plane == nil {
            return
        }
        
        plane?.update(anchor: anchor as! ARPlaneAnchor)
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
        
//        if sender.titleLabel?.text == "Box"{
//            print("Im here")
//
//            showBox()
//
//            btn.setTitle("Text", for: .normal)
//        }else{
//            showText()
//            btn.setTitle("Box", for: .normal)
//        }
        
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
