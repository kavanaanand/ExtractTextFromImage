//
//  ViewController.swift
//  ExtractTexFromImageSampleApp
//
//  Created by Kavana Anand on 10/1/22.
//

import UIKit

class ViewController: UIViewController {
    private let imageView = UIImageView()
    private let label = UILabel()
    private let ltInteraction = LiveTextInteraction()
    private let ltRecognizer = TextRecognizer()
    private let overlayLayer = CAShapeLayer()
    private let images = ["dreambig", "summer", "progress", "coffee", "happy", "welcome"];
}

extension ViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .orange
        
        ltInteraction.delegate = self
        
        ltRecognizer.delegate = self
        
        imageView.image = UIImage(named: images[0])
        imageView.contentMode = UIView.ContentMode.scaleAspectFit
        imageView.addInteraction(ltInteraction.imageInteraction())
        view.addSubview(imageView)
        
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .left
        label.backgroundColor = .black
        label.layer.opacity = 0.7
        label.textColor = .white
        view.addSubview(label)
        
        overlayLayer.fillColor = UIColor.clear.cgColor
        overlayLayer.strokeColor = UIColor.red.cgColor
        overlayLayer.lineWidth = 2.0
        imageView.layer.addSublayer(overlayLayer)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 50),
            imageView.bottomAnchor.constraint(equalTo: label.topAnchor, constant: 10),
            label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            label.heightAnchor.constraint(equalToConstant: 250),
        ])
        
        var index: Int = 0
        Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { [self] timer in
            guard index < images.count else {
                timer.invalidate()
                return
            }
            imageView.image = UIImage(named: images[index])
            getText()
            index = index + 1
        }
    }
}

private extension ViewController {
    private func getText() {
        if let image = imageView.image {
//            ltInteraction.analyze(image)
            ltRecognizer.recognizeText(image)
        }
    }
}

extension ViewController: LiveTextInteractionDelegate {
    func contentsRect(for interaction: LiveTextInteraction) -> CGRect {
        return imageView.frame
    }
    
    func liveTextInteraction(_ interaction: LiveTextInteraction, hasText text: String) {
        label.text = text
    }
}

extension ViewController: TextRecognizerDelegate {
    func textRecognizer(_ recognizer: TextRecognizer, didFindText text: String, at rect: CGRect) {
        let labelText = text.appendingFormat("\n\nx:%f y:%f\nw:%f h:%f", rect.minX, rect.minY, rect.width, rect.height)
        label.text = labelText
        overlayLayer.path = UIBezierPath(rect: imageView.convertRect(fromImageRect: rect)).cgPath
    }
}


// The following code from line 101 to l73 is borrowed from https://github.com/nubbel/UIImageView-GeometryConversion
extension UIImageView {
    func convertRect(fromImageRect imageRect: CGRect) -> CGRect {
        let imageTopLeft = imageRect.origin
        let imageBottomRight = CGPoint(x: imageRect.maxX, y: imageRect.maxY)
        
        let viewTopLeft = convertPoint(fromImagePoint: imageTopLeft)
        let viewBottomRight = convertPoint(fromImagePoint: imageBottomRight)
        
        var viewRect : CGRect = .zero
        viewRect.origin = viewTopLeft
        viewRect.size = CGSize(width: abs(viewBottomRight.x - viewTopLeft.x), height: abs(viewBottomRight.y - viewTopLeft.y))
        return viewRect
    }
    
    func convertPoint(fromImagePoint imagePoint: CGPoint) -> CGPoint {
        guard let imageSize = image?.size else { return CGPoint.zero }
        
        var viewPoint = imagePoint
        let viewSize = bounds.size
        
        let ratioX = viewSize.width / imageSize.width
        let ratioY = viewSize.height / imageSize.height
        
        switch contentMode {
        case .scaleAspectFit: fallthrough
        case .scaleAspectFill:
            var scale : CGFloat = 0
            
            if contentMode == .scaleAspectFit {
                scale = min(ratioX, ratioY)
            }
            else {
                scale = max(ratioX, ratioY)
            }
            
            viewPoint.x *= scale
            viewPoint.y *= scale
            
            viewPoint.x += (viewSize.width  - imageSize.width  * scale) / 2.0
            viewPoint.y += (viewSize.height - imageSize.height * scale) / 2.0
        
        case .scaleToFill: fallthrough
        case .redraw:
            viewPoint.x *= ratioX
            viewPoint.y *= ratioY
        case .center:
            viewPoint.x += viewSize.width / 2.0  - imageSize.width  / 2.0
            viewPoint.y += viewSize.height / 2.0 - imageSize.height / 2.0
        case .top:
            viewPoint.x += viewSize.width / 2.0 - imageSize.width / 2.0
        case .bottom:
            viewPoint.x += viewSize.width / 2.0 - imageSize.width / 2.0
            viewPoint.y += viewSize.height - imageSize.height
        case .left:
            viewPoint.y += viewSize.height / 2.0 - imageSize.height / 2.0
        case .right:
            viewPoint.x += viewSize.width - imageSize.width
            viewPoint.y += viewSize.height / 2.0 - imageSize.height / 2.0
        case .topRight:
            viewPoint.x += viewSize.width - imageSize.width
        case .bottomLeft:
            viewPoint.y += viewSize.height - imageSize.height
        case .bottomRight:
            viewPoint.x += viewSize.width  - imageSize.width
            viewPoint.y += viewSize.height - imageSize.height
        case.topLeft: fallthrough
        default:
            break
        }
        
         return viewPoint
    }
}
