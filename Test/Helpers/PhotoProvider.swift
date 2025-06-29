//
//  PhotoProvider.swift
//  Test
//
//  Created by Елизавета Кравченкова   on 29.06.2025.
//

import Foundation
import UIKit

/// Класс для получения фотографий
final class PhotoProvider {
    
    typealias GetPhotoResult = Result<UIImage, GetPhotoError>

    enum GetPhotoError: Error {
        
        case someError(Error)
    }
    
    let photoLoader: PhotoLoader
    let photoDataStore: PhotoDataSource
    
    init(photoLoader: PhotoLoader = NetworkPhotoLoader.shared,
         photoDataStore: PhotoDataSource = InMemoryImageStore.shared) {
        self.photoLoader = photoLoader
        self.photoDataStore = photoDataStore
    }
    

    func getPhoto(url: URL, completion: @escaping (GetPhotoResult) -> Void) {
        
        if let cachedImage = photoDataStore.getImage(by: url) {
            completion(.success(cachedImage))
            return
        }
        
        photoLoader.getPhoto(url: url) { result in
            switch result {
            case .success(let image):
                completion(.success(image))
            case .failure(let error):
                completion(.failure(.someError(error)))
            }
        }
    }

}
