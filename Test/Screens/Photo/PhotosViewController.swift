//
//  PhotosViewController.swift
//  Test
//
//  Created by Елизавета Кравченкова   on 30.06.2025.
//

import UIKit


final class PhotosViewController: UIViewController {

    private let photos: [UIImage?]
    private var currentIndex: Int

    private let imageView = UIImageView()

    init(photos: [UIImage?], startIndex: Int) {
        self.photos = photos
        self.currentIndex = startIndex
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setImage()
    }

    private func setupView() {
        view.backgroundColor = .black

        imageView.contentMode = .scaleAspectFit
        imageView.frame = view.bounds
        view.addSubview(imageView)

        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeLeft))
        leftSwipe.direction = .left
        view.addGestureRecognizer(leftSwipe)

        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeRight))
        rightSwipe.direction = .right
        view.addGestureRecognizer(rightSwipe)
    }

    private func setImage() {
        imageView.image = photos[currentIndex]
    }

    @objc private func swipeLeft() {
        guard currentIndex < photos.count - 1 else { return }
        currentIndex += 1
        setImage()
    }

    @objc private func swipeRight() {
        guard currentIndex > 0 else { return }
        currentIndex -= 1
        setImage()
    }
}
