//
//  PlayerView.swift
//  MomsVideoPlayer
//
//  Created by Hardik Parmar on 18/01/21.
//

import UIKit
import AVKit

class PlayerView: UIView {
    
    override static var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
    private var videoContentMode: AVLayerVideoGravity = .resizeAspect
    
    private var assetPlayer: AVQueuePlayer? {
        didSet {
            DispatchQueue.main.async {
                if let layer = self.layer as? AVPlayerLayer {
                    layer.player = self.assetPlayer
                }
            }
        }
    }
    
    private var url: URL?
    private var playerItem:AVPlayerItem?
    private var urlAsset: AVURLAsset?
    private var looper: AVPlayerLooper?
    
    init(videoContentMode: AVLayerVideoGravity) {
        super.init(frame: .zero)
        
        self.videoContentMode = videoContentMode
        initialSetup()
    }
    
    required init?(coder: NSCoder) {
        super.init(frame: .zero)
        initialSetup()
    }
    
    private func initialSetup() {
        if let layer = layer as? AVPlayerLayer {
            layer.videoGravity = videoContentMode
        }
    }
    
    func prepareToPlay(withUrl url:URL) {
        guard !(self.url == url && assetPlayer != nil && assetPlayer?.error == nil) else {
            play()
            return
        }
        
        self.url = url
        
        let options = [AVURLAssetPreferPreciseDurationAndTimingKey : true]
        urlAsset = AVURLAsset(url: url, options: options)
        
        let keys = ["tracks"]
        urlAsset?.loadValuesAsynchronously(forKeys: keys, completionHandler: { [weak self] in
            guard let self = self else { return }
            self.startLoading(self.urlAsset!)
        })
        
    }
    
    private func startLoading(_ asset: AVURLAsset) {
        var error:NSError?
        let status:AVKeyValueStatus = asset.statusOfValue(forKey: "tracks", error: &error)
        if status == AVKeyValueStatus.loaded {
            let item = AVPlayerItem(asset: asset)
            playerItem = item
            assetPlayer = AVQueuePlayer(playerItem: playerItem)
            looper = AVPlayerLooper(player: assetPlayer!, templateItem: playerItem!)
            didFinishLoading(assetPlayer)
        }
    }
    
    private func didFinishLoading(_ player: AVPlayer?) {
        guard let player = player else { return }
        DispatchQueue.main.async {
            player.play()
        }
    }
    
    func play() {
        guard assetPlayer?.isPlaying == false else { return }
        DispatchQueue.main.async {
            self.assetPlayer?.play()
        }
    }
}

extension AVPlayer {
    
    var isPlaying:Bool {
        get {
            return (rate != 0 && error == nil)
        }
    }
    
}
