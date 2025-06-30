//
//  MyActivityIndicator.swift
//  Test
//
//  Created by Елизавета Кравченкова   on 30.06.2025.
//

import UIKit

final class MyActivityIndicator: UIView {

    private(set) var isAnimating = false

    private let spinnerLayer = CAShapeLayer()
    private let animationKey = "rotateAnimation"
    private let size: Size
    private let style: Style


    init(size: Size = .medium, style: Style = .circle) {
        self.size = size
        self.style = style
        super.init(frame: CGRect(origin: .zero, size: size.size))
        setupLayer()
        startAnimating()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        return size.size
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        spinnerLayer.frame = bounds
        spinnerLayer.path = getPath()
    }

    private func setupLayer() {
        spinnerLayer.strokeColor = UIColor.systemPink.cgColor
        spinnerLayer.fillColor = UIColor.clear.cgColor
        spinnerLayer.lineWidth = 3
        layer.addSublayer(spinnerLayer)
    }

    func startAnimating() {
        isAnimating = true
        let rotation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.fromValue = 0
        rotation.toValue = 2 * Double.pi
        rotation.duration = 1.0
        rotation.repeatCount = .infinity
        spinnerLayer.add(rotation, forKey: animationKey)
    }

    func stopAnimating() {
        isAnimating = false
        spinnerLayer.removeAnimation(forKey: animationKey)
    }
}


// MARK: - Size

extension MyActivityIndicator {
    enum Size {
        case small
        case medium
        case large

        var size: CGSize {
            switch self {
            case .small:  return CGSize(width: 30, height: 30)
            case .medium: return CGSize(width: 50, height: 50)
            case .large:  return CGSize(width: 80, height: 80)
            }
        }

        var radius: CGFloat {
            return min(size.width, size.height) / 2 - 3
        }
    }
    
}



// MARK: - Style

extension MyActivityIndicator {
    enum Style {
        case circle
        case square
        case triangle
    }
    
    private func getPath() -> CGPath {
        switch style {
            case .circle:  return getCircle()
            case .square: return getSquare()
            case .triangle:  return getTriangle()
        }
    }
    
    
    func getCircle() -> CGPath {
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let startAngle = -CGFloat.pi / 2
        let endAngle = startAngle + 1.5 * .pi
        let path = UIBezierPath(
            arcCenter: center,
            radius: size.radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: true
        )
        return path.cgPath
    }
    
    func getSquare() -> CGPath {
        let size = min(bounds.width, bounds.height) * 0.6
        let origin = CGPoint(
            x: bounds.midX - size / 2,
            y: bounds.midY - size / 2
        )
        let rect = CGRect(origin: origin, size: CGSize(width: size, height: size))
        let path = UIBezierPath(rect: rect)
        return path.cgPath
    }
    
    func getTriangle() -> CGPath {
        let size = min(bounds.width, bounds.height) * 0.6
        let center = CGPoint(x: bounds.midX, y: bounds.midY)

        let path = UIBezierPath()

        let point1 = CGPoint(x: center.x, y: center.y - size / 2) // верхняя вершина
        let point2 = CGPoint(x: center.x - size / 2, y: center.y + size / 2) // левая нижняя
        let point3 = CGPoint(x: center.x + size / 2, y: center.y + size / 2) // правая нижняя

        path.move(to: point1)
        path.addLine(to: point2)
        path.addLine(to: point3)
        path.close()

        return path.cgPath
    }
    
}

