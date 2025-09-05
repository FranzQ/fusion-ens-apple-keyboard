//
//  FusionENSKeyboardActionHandler.swift
//  FusionENSKeyboard
//
//  Created by Franz Quarshie on 05/09/2025.
//

import Foundation
import UIKit

class FusionENSKeyboardActionHandler {
    
    // MARK: - Properties
    private let inputViewController: UIViewController
    
    // MARK: - Initialization
    init(inputViewController: UIViewController) {
        self.inputViewController = inputViewController
    }
    
    // MARK: - Functions
    
    func alert(_ message: String) {
        print("Alert: \(message)")
    }
    
    func copyImage(named imageName: String) {
        guard let image = UIImage(named: imageName) else { return }
        guard image.copyToPasteboard() else { return alert("The image could not be copied.") }
        alert("Copied to pasteboard!")
    }
    
    func saveImage(named imageName: String) {
        guard let image = UIImage(named: imageName) else { return }
        image.saveToPhotos(completion: handleImageDidSave)
        alert("Saved to photos!")
    }
    
    private func handleImageDidSave(withError error: Error?) {
        if error == nil { alert("Saved!") }
        else { alert("Failed!") }
    }
}

private extension UIImage {
    
    func copyToPasteboard(_ pasteboard: UIPasteboard = .general) -> Bool {
        guard let data = pngData() else { return false }
        pasteboard.setData(data, forPasteboardType: "public.png")
        return true
    }
    
    func saveToPhotos(completion: @escaping (Error?) -> Void) {
        ImageService.default.saveImageToPhotos(self, completion: completion)
    }
}

/**
 This class is used as a target/selector holder by the image
 extension above.
 */
private class ImageService: NSObject {
    
    public typealias Completion = (Error?) -> Void

    public static private(set) var `default` = ImageService()
    
    private var completions = [Completion]()
    
    public func saveImageToPhotos(_ image: UIImage, completion: @escaping (Error?) -> Void) {
        completions.append(completion)
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveImageToPhotosDidComplete), nil)
    }
    
    @objc func saveImageToPhotosDidComplete(_ image: UIImage, error: NSError?, contextInfo: UnsafeRawPointer) {
        guard completions.count > 0 else { return }
        completions.removeFirst()(error)
    }
}
