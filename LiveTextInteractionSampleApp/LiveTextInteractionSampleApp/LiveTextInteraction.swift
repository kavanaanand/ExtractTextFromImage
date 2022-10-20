//
//  LiveTextInteraction.swift
//  LiveTextInteractionSampleApp
//
//  Created by Kavana Anand on 10/1/22.
//

import VisionKit

@available(iOS 16.0, *)
@objc protocol LiveTextInteractionDelegate {
    
    @objc func contentsRect(for interaction: LiveTextInteraction) -> CGRect
    
}

@available(iOS 16.0, *)
@MainActor
@objc class LiveTextInteraction: NSObject {
    
    @objc required override init() {
        super.init()
        interaction.delegate = self
    }
    
    @objc func imageInteraction() -> ImageAnalysisInteraction {
        return interaction
    }
    
    @objc func setContentsRectNeedUpdate() {
        interaction.setContentsRectNeedsUpdate()
    }
    
    @objc func analyze(_ image: UIImage) {
        Task {
            do {
                let analysis = try await analyzer.analyze(image, configuration: ImageAnalyzer.Configuration([.text]))
                    interaction.preferredInteractionTypes = .automatic
                    interaction.analysis = analysis
            } catch {
                
            }
        }
    }
    
    @objc weak var delegate : LiveTextInteractionDelegate?
    private let analyzer = ImageAnalyzer()
    private let interaction = ImageAnalysisInteraction()
}

@available(iOS 16.0, *)
extension LiveTextInteraction : ImageAnalysisInteractionDelegate {

    func interaction(_ interaction: ImageAnalysisInteraction, shouldBeginAt point: CGPoint, for interactionType: ImageAnalysisInteraction.InteractionTypes) -> Bool {
        return true
    }

    func interaction(_ interaction: ImageAnalysisInteraction, highlightSelectedItemsDidChange highlightSelectedItems: Bool) {

    }

    func interaction(_ interaction: ImageAnalysisInteraction, liveTextButtonDidChangeToVisible visible: Bool) {

    }

    func contentsRect(for interaction: ImageAnalysisInteraction) -> CGRect {
        return delegate?.contentsRect(for: self) ?? CGRectZero
    }
}
