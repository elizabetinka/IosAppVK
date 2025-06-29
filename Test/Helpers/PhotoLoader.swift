//
//  PhotoProvider.swift
//  Test
//
//  Created by Елизавета Кравченкова   on 29.06.2025.
//

import Foundation
import UIKit


typealias LoadPhotoResult = Result<UIImage, LoadPhotoError>

enum LoadPhotoError: Error, LocalizedError{
    
    case network(Error)
    case badStatusCode
    case badData
    
    var errorDescription: String? {
        switch self {
        case .network(let underlying):
            return "Ошибка сети: \(underlying.localizedDescription)"
        case .badStatusCode:
            return "Неуспешный статус ответа от сервера"
        case .badData:
            return "Ошибка данных: невозможно создать изображение"
        }
    }

}

/// Протокол для получения  фотографий из url
protocol PhotoLoader {
    
    func getPhoto(url: URL, completion: @escaping (LoadPhotoResult) -> Void)
}

/// Класс для получения фотографий по url из сети
final class NetworkPhotoLoader: PhotoLoader {
    static let shared = NetworkPhotoLoader()
    
    private init() {
            let config = URLSessionConfiguration.default
        
            if let requestTimeout = Bundle.main.object(forInfoDictionaryKey: "RequestTimeoutInterval") as? Double {
                config.timeoutIntervalForRequest = requestTimeout
            }
        
            if let resourceTimeout = Bundle.main.object(forInfoDictionaryKey: "ResourceTimeoutInterval") as? Double {
                config.timeoutIntervalForRequest = resourceTimeout
            }

            session = URLSession(configuration: config)
    }
    
    let session : URLSession

    func getPhoto(url: URL, completion: @escaping (LoadPhotoResult) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            
            if let error = error {
                completion(.failure(.network(error)))
                return
            }
            
            guard let httpRes = response as? HTTPURLResponse, 200..<300 ~= httpRes.statusCode else {
                completion(.failure(.badStatusCode))
                return
            }
            
            
            guard let data = data, let image = UIImage(data: data) else {
                completion(.failure(.badData))
                return
            }

            completion(.success(image))
        
        }
        task.resume()
    }

}
