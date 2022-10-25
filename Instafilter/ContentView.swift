//
//  ContentView.swift
//  Instafilter
//
//  Created by Saurabh Jamadagni on 17/10/22.
//

import CoreImage
import CoreImage.CIFilterBuiltins
import SwiftUI

struct ContentView: View {
    @State private var image: Image?
    @State private var inputImage: UIImage?
    @State private var processedImage: UIImage?
    @State private var filterIntensity = 0.5
    @State private var showingImagePicker = false
    @State private var showingFilterSheet = false
    @State private var currentFilter: CIFilter = CIFilter.sepiaTone()
    
    let context = CIContext()

    var body: some View {
        NavigationView {
            VStack {
                ZStack {
                    Rectangle()
                        .fill(.secondary)
                    
                    Text("Tap to insert image")
                        .foregroundColor(.white)
                        .font(.headline)
                    
                    image?
                        .resizable()
                        .scaledToFit()
                }
                .onTapGesture {
                    showingImagePicker = true
                }
                
                HStack {
                    Text("Intensity")
                    
                    Slider(value: $filterIntensity)
                        .onChange(of: filterIntensity, perform: { _ in applyProcessing() })
                }
                .padding(.vertical)
                
                HStack {
                    Button("Change Filter") { showingFilterSheet = true }
                    Spacer()
                    Button("Save", action: save)
                        .disabled(image == nil)
                }
            }
            .padding([.horizontal, .bottom])
            .navigationTitle("Instafilter")
            .onChange(of: inputImage) { _ in loadImage() }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $inputImage)
            }
            .confirmationDialog("Select Filter", isPresented: $showingFilterSheet) {
                Button("Crystallize") { setFilter(CIFilter.crystallize()) }
                Button("Sepia Tone") { setFilter(CIFilter.sepiaTone()) }
                Button("Pixellate") { setFilter(CIFilter.pixellate()) }
                Button("Gaussian Blur") { setFilter(CIFilter.gaussianBlur()) }
                Button("Unsharp Mask") { setFilter(CIFilter.unsharpMask()) }
                Button("Cancel", role: .cancel) { }
            }
        }
    }
    
    func setFilter(_ filter: CIFilter) {
        currentFilter = filter
        loadImage()
    }
    
    func loadImage() {
        guard let inputImage = inputImage else { return }
        
        let ciImageStarter = CIImage(image: inputImage)
        currentFilter.setValue(ciImageStarter, forKey: kCIInputImageKey)
        applyProcessing()
    }
    
    func applyProcessing() {
        let filterKeys = currentFilter.inputKeys
        
        if filterKeys.contains(kCIInputIntensityKey) {
            currentFilter.setValue(filterIntensity, forKey: kCIInputIntensityKey)
        }
        
        if filterKeys.contains(kCIInputRadiusKey) {
            currentFilter.setValue(filterIntensity * 200, forKey: kCIInputRadiusKey)
        }
        
        if filterKeys.contains(kCIInputScaleKey) {
            currentFilter.setValue(filterIntensity * 100, forKey: kCIInputScaleKey)
        }
        
        guard let outputImage = currentFilter.outputImage else { return }
        
        if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
            let uiImage = UIImage(cgImage: cgimg)
            image = Image(uiImage: uiImage)
            processedImage = uiImage
        }
    }
    
    func save() {
        guard let processedImage = processedImage else { return }
        
        let imageSaver = ImageSaver()
        imageSaver.successHandler = {
            print("Save successful!")
        }
        imageSaver.errorHandler = {
            print("\($0.localizedDescription) error reported")
        }
        
        imageSaver.writeToPhotoAlbum(image: processedImage)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
