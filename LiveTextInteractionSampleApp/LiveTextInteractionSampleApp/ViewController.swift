//
//  ViewController.swift
//  LiveTextInteractionSampleApp
//
//  Created by Kavana Anand on 10/1/22.
//

import UIKit

class ViewController: UIViewController {
    private var imageView = UIImageView()
    private let ltInteraction = LiveTextInteraction()
}

extension ViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.orange
        
        ltInteraction.delegate = self
        
        imageView.image = UIImage(named: "testimage1")
        imageView.contentMode = UIView.ContentMode.scaleAspectFit
        imageView.addInteraction(ltInteraction.imageInteraction())
        self.view.addSubview(imageView)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            imageView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            imageView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 100),
            imageView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -100),
        ])
        
        if let image = imageView.image {
            ltInteraction.analyze(image)
        }
    }
}

extension ViewController : LiveTextInteractionDelegate {
    func contentsRect(for interaction: LiveTextInteraction) -> CGRect {
        return imageView.frame
    }
}
