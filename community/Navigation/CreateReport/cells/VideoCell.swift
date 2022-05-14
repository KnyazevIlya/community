//
//  VideoCell.swift
//  community
//
//  Created by Illia Kniaziev on 10.03.2022.
//

import UIKit
import AVKit

class VideoCell: UICollectionViewCell {
    
    let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let playerView: PlayerView = {
        let view = PlayerView(videoContentMode: .resizeAspect)
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let backgroundPlayerView: PlayerView = {
        let view = PlayerView(videoContentMode: .resizeAspectFill)
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let blurView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        return blurView
    }()
    
    let activityIndicator: UIActivityIndicatorView = {
       let indicator = UIActivityIndicatorView()
        indicator.style = .large
        indicator.color = .systemBlue
        indicator.startAnimating()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUpUI()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpUI()
    }
    
    func setUpUI() {
        containerView.pin(toView: self)
        backgroundPlayerView.pin(toView: containerView)
        blurView.pin(toView: containerView)
        activityIndicator.center(inView: containerView)
        playerView.pin(toView: containerView)
    }
    
    func configure(withVideoUrl url: URL) {
        playerView.prepareToPlay(withUrl: url)
        backgroundPlayerView.prepareToPlay(withUrl: url)
    }
    
}
