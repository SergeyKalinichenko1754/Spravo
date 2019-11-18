//
//  ImageLoader.swift
//  Spravo
//
//  Created by Onix on 11/15/19.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit

protocol ImageLoaderType: Service {
    func loadImage(urlString: String, indexPath: IndexPath?, completion: @escaping (IndexPath?, UIImage?) -> ())
}

class ImageLoader: ImageLoaderType {
    private func storeImage(urlString: String, image: UIImage) {
        let path = NSTemporaryDirectory().appending(UUID().uuidString)
        let url = URL(fileURLWithPath: path)
        let data = image.jpegData(compressionQuality: 1.0)
        try? data?.write(to: url)
        var imageDictionary = UserDefaults.standard.object(forKey: "ImageCache") as? [String: String] ?? [:]
        imageDictionary[urlString] = path
        UserDefaults.standard.set(imageDictionary, forKey: "ImageCache")
    }
    
    func loadImage(urlString: String, indexPath: IndexPath? = nil, completion: @escaping (IndexPath?, UIImage?) -> ()) {
        DispatchQueue.global().async {
            if let imageDictionary = UserDefaults.standard.object(forKey: "ImageCache") as? [String: String],
                let path = imageDictionary[urlString],
                let data = try? Data(contentsOf: URL(fileURLWithPath: path)) {
                let image = UIImage(data: data)
                completion(indexPath, image)
                return
            }
            guard let imgURL = URL(string: urlString),
                let imageData = try? Data(contentsOf: imgURL) else {
                    completion(indexPath, nil)
                    return
            }
            if let image = UIImage(data: imageData) {
                self.storeImage(urlString: urlString, image: image)
                completion(indexPath, image)
                return
            }
            completion(indexPath, nil)
        }
    }
}
