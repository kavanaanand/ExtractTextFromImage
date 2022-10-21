//
//  LiveTextRecognizer.swift
//  LiveTextInteractionSampleApp
//
//  Created by Kavana Anand on 10/21/22.
//

import Vision
import UIKit

@objc protocol LiveTextRecognizerDelegate {
    @objc func liveTextRecognizer(_ recognizer: LiveTextRecognizer, didFindText text: String, at rect: CGRect)
}

@objc class LiveTextRecognizer: NSObject {
    
    @objc required override init() {
        super.init()
    }
    
    @objc func recognizeText(_ image: UIImage) {
        guard let cgImage = image.cgImage else {
            return
        }
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage)
        
        let request = VNRecognizeTextRequest { [self] request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation], error == nil else {
                return
            }
            
            let texts = observations.compactMap { observation in
                observation.topCandidates(1).first?.string
            }
            
            let boundingRects: [CGRect] = observations.compactMap { observation in
                guard let candidate = observation.topCandidates(1).first else { return .zero }
                
                let stringRange = candidate.string.startIndex..<candidate.string.endIndex
                let boxObservation = try? candidate.boundingBox(for: stringRange)
                
                let boundingBox = boxObservation?.boundingBox ?? .zero
                return boundingBox
            }
            
            processResult(image, texts: texts, boundingRects: boundingRects)
        }
        
        do {
            try requestHandler.perform([request])
        } catch {
            print(error)
        }
    }
    
    @objc weak var delegate: LiveTextRecognizerDelegate?
}

private extension LiveTextRecognizer {
    private func processResult(_ image: UIImage, texts: [String], boundingRects: [CGRect]) {
        var textRects = Array<CGRect>()
        for boundingBox in boundingRects {
            // Convert the rectangle from normalized coordinates to image coordinates in system with origin at top left
            let transform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -image.size.height)
            let scale = CGAffineTransform.identity.scaledBy(x: image.size.width, y: image.size.height)
            let imageRect = boundingBox.applying(scale).applying(transform)
            
            // Convert the rectangle from normalized coordinates to image coordinates.
//            let imageRect = VNImageRectForNormalizedRect(boundingBox,
//                                                         Int(image.size.width),
//                                                         Int(image.size.height))
            
            textRects.append(imageRect)
        }
        
        var textRect = textRects[0]
        for i in 1..<textRects.count {
            textRect = textRect.union(textRects[i])
        }
        
        let text = texts.joined(separator: "\n")

        DispatchQueue.main.async { [self] in
            delegate?.liveTextRecognizer(self, didFindText: text, at: textRect)
        }
    }
}

