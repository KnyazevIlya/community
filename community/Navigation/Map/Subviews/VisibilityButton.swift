//
//  VisibilityButton.swift
//  community
//
//  Created by Illia Kniaziev on 06.03.2022.
//

import UIKit
import Lottie

class VisibilityButton: UIButton {
    
    private enum AnimationKeyFrames: CGFloat {
        
        case hideStart = 0
        
        case restored = 70
        
        case showEnd = 120
        
    }
    
    var isIconCrossed = false {
        willSet {
            if newValue != isIconCrossed {
                if newValue {
                    playHide()
                } else {
                    playShow()
                }
            }
        }
    }
    
    private var animationView = AnimationView(name: "eye")
    
    override func layoutSubviews() {
        super.layoutSubviews()
        configureAnimationView()
    }
    
    private func configureAnimationView() {
        let origin = CGPoint(x: (frame.width - frame.height) / 2, y: 0)
        let size = CGSize(width: frame.height, height: frame.height)
        animationView.frame = CGRect(origin: origin, size: size)
        animationView.contentMode = .scaleToFill
        animationView.isUserInteractionEnabled = false
        addSubview(animationView)
    }
    
    private func playHide() {
        animationView.play(
            fromFrame: AnimationKeyFrames.hideStart.rawValue,
            toFrame: AnimationKeyFrames.restored.rawValue,
            loopMode: .none
        )
    }
    
    private func playShow() {
        animationView.play(
            fromFrame: AnimationKeyFrames.restored.rawValue,
            toFrame: AnimationKeyFrames.showEnd.rawValue,
            loopMode: .none
        )
    }

}
