//
//  CustomImagePicker.swift
//  Spravo
//
//  Created by Onix on 11/26/19.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit

protocol ImagePickerDelegate: class {
    func didSelect(image: UIImage?, indexPath: IndexPath?)
    func removeImage(_ indexPath: IndexPath?)
}

class CustomImagePicker: NSObject {
    private let pickerController: UIImagePickerController
    private weak var presentationController: UIViewController?
    private weak var delegate: ImagePickerDelegate?
    var indexPath: IndexPath?
    
    init(_ presentationController: UIViewController, delegate: ImagePickerDelegate) {
        self.pickerController = UIImagePickerController()
        super.init()
        self.presentationController = presentationController
        self.delegate = delegate
        self.pickerController.delegate = self
        self.pickerController.allowsEditing = true
        self.pickerController.mediaTypes = ["public.image"]
    }
    
    private func action(for type: UIImagePickerController.SourceType, title: String) -> UIAlertAction? {
        guard UIImagePickerController.isSourceTypeAvailable(type) else {
            return nil
        }
        return UIAlertAction(title: title, style: .default) { [unowned self] _ in
            self.pickerController.sourceType = type
            self.presentationController?.present(self.pickerController, animated: true)
        }
    }
    
    func present(from sourceView: UIView, indexPath: IndexPath? = nil, currentImage: UIImage? = nil) {
        self.indexPath = indexPath
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        var title = NSLocalizedString("CustomImagePicker.TakePhoto", comment: "take photo label")
        if let action = self.action(for: .camera, title: title) {
            alertController.addAction(action)
        }
        title = NSLocalizedString("CustomImagePicker.CameraRoll", comment: "camera roll label")
        if let action = self.action(for: .savedPhotosAlbum, title: title) {
            alertController.addAction(action)
        }
        title = NSLocalizedString("CustomImagePicker.PhotoLibrary", comment: "Photo library label")
        if let action = self.action(for: .photoLibrary, title: title) {
            alertController.addAction(action)
        }
        if let _ = currentImage {
            title = NSLocalizedString("CustomImagePicker.RemovePhoto", comment: "Remove current photo label")
            let action = UIAlertAction(title: title, style: .destructive) { [unowned self] _ in
                self.removeImage()
            }
            alertController.addAction(action)
        }
        title = NSLocalizedString("Common.Cancel", comment: "Cancel Button caption")
        alertController.addAction(UIAlertAction(title: title, style: .cancel, handler: nil))
        if UIDevice.current.userInterfaceIdiom == .pad {
            alertController.popoverPresentationController?.sourceView = sourceView
            alertController.popoverPresentationController?.sourceRect = sourceView.bounds
            alertController.popoverPresentationController?.permittedArrowDirections = [.down, .up]
        }
        self.presentationController?.present(alertController, animated: true)
    }
    
    private func pickerController(_ controller: UIImagePickerController, didSelect image: UIImage?) {
        controller.dismiss(animated: true, completion: nil)
        self.delegate?.didSelect(image: image, indexPath: indexPath)
    }
    
    private func removeImage() {
        self.pickerController.dismiss(animated: true, completion: nil)
        delegate?.removeImage(indexPath)
    }
}

extension CustomImagePicker: UIImagePickerControllerDelegate {
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.pickerController(picker, didSelect: nil)
    }
    
    public func imagePickerController(_ picker: UIImagePickerController,
                                      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[.editedImage] as? UIImage else {
            return self.pickerController(picker, didSelect: nil)
        }
        self.pickerController(picker, didSelect: image)
    }
}

extension CustomImagePicker: UINavigationControllerDelegate {
}
