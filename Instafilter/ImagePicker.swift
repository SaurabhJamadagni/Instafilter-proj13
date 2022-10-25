//
//  ImagePicker.swift
//  Instafilter
//
//  Created by Saurabh Jamadagni on 19/10/22.
//

import PhotosUI
import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        // Rather than just pass the data down one level,
        //a better idea is to tell the coordinator what its parent is,
        //so it can modify values there directly.
        
        var parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        // method receives two objects we care about:
        //the picker view controller that the user was interacting with
        //an array of the users selections
        //it’s possible to let the user select multiple images at once.
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            // To dismiss the picker
            picker.dismiss(animated: true)
            
            guard let provider = results.first?.itemProvider else { return }
            
            // if there's a image selected, we can use it.
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, _ in
                    self.parent.image = image as? UIImage
                    // We specifically said images earlier.
                    // But PHPickerViewControllerDelegate calls this same method
                    // for different types of media.
                    // Hence, need to typecast.
                }
            }
        }
    }
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}
