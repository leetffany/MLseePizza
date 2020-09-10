//
//  ViewController.swift
//  SeeFood
//
//  Created by Jamie Kim  on 8/27/20.
//  Copyright © 2020 Jamie Kim . All rights reserved.
//

import UIKit
import CoreML
import Vision

//set viewcontroller as delete
class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //access to  properties of imagepicker
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
    }
    
    //send image to ml model
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //optional binding + downcase using as?
        //if it can be UIImage datatype then execute the next line
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            imageView.image = pickedImage
            //CIImage - to collaborate Vision framework
            //security in case pickedImage not able to convert to CIImage 
            guard let ciimage = CIImage(image: pickedImage) else{
                fatalError("Could not convert into CI image.")
            }
            //now pass ciimage that converted from user-picked image
            detect(image: ciimage)
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func detect(image: CIImage){
        //try? - attempt to try the operation that might throw error
        //guard - if operation is nil trigger throw error
        //model - is going to be used to classify pickedimage
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("can't load ML model")
        }
        //if not nil VNCoreMLRequest completion handler
        let request = VNCoreMLRequest(model: model) { (request, error) in
            //data type is array of any objects -> downcasting to array VNClassificationObservation
            guard let results = request.results as? [VNClassificationObservation] else{
                fatalError("Model failed to process image.")
            }
            //optional chaining first result def has a value
            if let resultFirst = results.first {
                    let percentage = 100 * resultFirst.confidence
                    if resultFirst.identifier.contains("pizza"){
                    //change navigation item title to pizza
                    self.navigationItem.title = "Pizza! with \(percentage)% confidence🤓"
                        
                } else {
                    self.navigationItem.title = "This is NOT a pizza 🥱"
                }
                //print(results)//objects
            }
        }
        //specify which image it should perform classification request on?
        let handler = VNImageRequestHandler(ciImage: image)
        //do catch  - safer than just try in case of error
        do{
            try handler.perform([request])
        } catch {
            print(error)
        }
        
    }
    

    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        //asks app to present imagepicker to the user so they use camera/pick a pic
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    
    }
}

