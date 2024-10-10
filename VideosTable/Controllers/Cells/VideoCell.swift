//
//  VideoCell.swift
//  VideosTable
//
//  Created by Alexey on 10.10.24.
//

import UIKit
import AVFoundation

class VideoCell: UITableViewCell {
    
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var loopObserver: Any?
    var playerLooper: NSObject?
    var playerLayer: AVPlayerLayer?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let playerLayer = AVPlayerLayer()
        playerLayer.frame = self.videoView.bounds
        playerLayer.videoGravity = .resizeAspectFill
        videoView.layer.cornerRadius = 8.0
        self.videoView.layer.insertSublayer(playerLayer, at: 0)
        self.playerLayer = playerLayer
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.removeObservers()
    }
    
    deinit {
        self.removeObservers()
    }
    
    
    func configure(with url: String) {
        let videoPath = Bundle.main.path(forResource: "cake", ofType: "mp4")!
        let videoURL = URL(fileURLWithPath: videoPath)
        let videoPlayer = AVPlayer(url: videoURL)
        
        //        Solution with PlayerLooper is very slow
        //        let playerItem = AVPlayerItem(url:videoURL)
        //        let videoPlayer = AVQueuePlayer(items: [playerItem])
        //        playerLooper = AVPlayerLooper(player: videoPlayer, templateItem: playerItem)
        //        self.playerLayer?.player = videoPlayer
        
        
        videoPlayer.addObserver(self, forKeyPath: "timeControlStatus", options: [.old, .new], context: nil)
        self.playerLayer?.player = videoPlayer
        self.loopVideo(videoPlayer)
      //  videoPlayer.play()
    }
    
    func loopVideo(_ videoPlayer: AVPlayer) {
        loopObserver = NotificationCenter.default.addObserver(forName: Notification.Name.AVPlayerItemDidPlayToEndTime, object: nil, queue: nil) { notification in
            self.playerLayer?.player?.seek(to: CMTime.zero)
            self.playerLayer?.player?.play()
        }
    }
    
    func removeObservers() {
        if let obs = loopObserver {
            NotificationCenter.default.removeObserver(obs)
        }
        self.playerLayer?.player?.removeObserver(self, forKeyPath: "timeControlStatus")
    }
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "timeControlStatus", let change = change, let newValue = change[NSKeyValueChangeKey.newKey] as? Int, let oldValue = change[NSKeyValueChangeKey.oldKey] as? Int {
            let oldStatus = AVPlayer.TimeControlStatus(rawValue: oldValue)
            let newStatus = AVPlayer.TimeControlStatus(rawValue: newValue)
            if newStatus != oldStatus {
                DispatchQueue.main.async {[weak self] in
                    if let status = newStatus {
                        switch status {
                        case .playing:
                            print("playing")
                            self?.playerLayer?.player?.play()
                            self?.activityIndicator.stopAnimating()
                        case .paused:
                            print("paused")
                            self?.activityIndicator.stopAnimating()
                            
                        case .waitingToPlayAtSpecifiedRate:
                            print("waiting")
                            self?.activityIndicator.startAnimating()
                            
                        @unknown default:
                            break
                        }
                    }
                }
            }
        }
    }
}
