//
//  ViewController.swift
//  MibileV2_project
//
//  Created by Sy Lee on 2023/04/28.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    @IBOutlet weak var emptyView: UIView!
    
    @IBOutlet weak var currentImageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    @IBAction func photoIconPressed(_ sender: UIBarButtonItem) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emptyView.layer.cornerRadius = emptyView.frame.width / 2
        emptyView.layer.shadowColor = UIColor.white.cgColor
        emptyView.layer.shadowOpacity = 0.2
        emptyView.layer.shadowOffset = .zero
        emptyView.layer.shadowRadius = 10
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let img = info[.originalImage] as? UIImage {
            currentImageView.image = img
            imagePicker.dismiss(animated: true)
            
            guard let ciImage = CIImage(image: img) else {
                fatalError("UIImage -> CIImage 변환 실패")
            }
            detect(ciImg: ciImage)
        }
    }
    func detect(ciImg: CIImage) {
        let config = MLModelConfiguration()
        guard let mobileNetV2 = try? MobileNetV2(configuration: config) else {
            fatalError("모델을 찾지 못함")
        }
        let model = mobileNetV2.model
        guard let vnModel = try? VNCoreMLModel(for: model) else {
            fatalError("VN 모델 생성 불가")
        }
        let classifyImageRequest = VNClassifyImageRequest { request, error in
            let results = request.results as? [VNClassificationObservation]
            print(results ?? "result is nil")
            guard let topResult = results?.first else {
                fatalError("Top result is nil")
            }
            self.navigationItem.title = topResult.identifier
        }
        
        let handler = VNImageRequestHandler(ciImage: ciImg)
        do {
            try handler.perform([classifyImageRequest])
        } catch {
            print("Handler perform error")
        }
        
    }

}

