//
//  PhotoDataSourse.swift
//  Test
//
//  Created by Елизавета Кравченкова   on 29.06.2025.
//

import Foundation
import UIKit

/// Протокол для кеширования изображений
protocol PhotoDataSource {
    func getImage(by url: URL) -> UIImage?
    func saveImage(url: URL, image: UIImage)
}


class InMemoryImageStore : PhotoDataSource {
    let cache = NSCache<NSURL, UIImage>()
    
    static let shared = InMemoryImageStore()
    private init() {}
    
    func getImage(by url: URL) -> UIImage? {
        return cache.object(forKey: url as NSURL)
    }
    
    func saveImage(url: URL, image: UIImage) {
        cache.setObject(image, forKey: url as NSURL)
    }
}
