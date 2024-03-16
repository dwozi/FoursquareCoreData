//
//  SecondViewController.swift
//  FourSquare
//
//  Created by Hakan Hardal on 20.11.2023.
//

import UIKit
import CoreData

class SecondViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    
    @IBOutlet weak var nameText: UITextField!
    
    @IBOutlet weak var commentText: UITextField!
    
    var isim = ""
    var yorum = ""
    var data = Data()
    var secilenTitleTasima = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imageView.addGestureRecognizer(gestureRecognizer)
        
        let gestureRc = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRc)
        
       

    }
    @objc func hideKeyboard(){
        view.endEditing(true)
        
    }
    @objc func selectImage(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true)
        
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.editedImage] as? UIImage
        self.dismiss(animated: true)
    }
    
    
    @IBAction func nextButton(_ sender: Any) {
        self.isim = nameText.text!
        self.yorum = commentText.text!
        data = imageView.image!.jpegData(compressionQuality: 0.5)!
       performSegue(withIdentifier: "mapVC", sender: nil)
        
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "mapVC"{
            let destinationVC = segue.destination as? MapViewController
            destinationVC?.namesText = self.isim
            destinationVC?.detailsText = self.yorum
            destinationVC?.imagedata = self.data
            destinationVC?.secilenTitle = self.secilenTitleTasima
            
            
        }
    }
    
    
    
    
}
