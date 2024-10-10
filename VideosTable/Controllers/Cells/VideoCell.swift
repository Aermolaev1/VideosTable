//
//  VideoCell.swift
//  VideosTable
//
//  Created by Alexey on 10.10.24.
//

import UIKit
import AVFoundation

final class VideoCell: UITableViewCell {
    
    @IBOutlet private weak var videoView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    private var loopObserver: Any?
    private var playerLooper: NSObject?
    private var playerLayer: AVPlayerLayer?
    private var currentUrl: String? = nil
    private var observer: NSKeyValueObservation?
    private var preparePlayerWorkItem: DispatchWorkItem? = nil
    
    public var player = AVPlayer()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let playerLayer = AVPlayerLayer()
        playerLayer.frame = videoView.bounds
        playerLayer.videoGravity = .resizeAspectFill
        videoView.layer.cornerRadius = 8.0
        videoView.layer.insertSublayer(playerLayer, at: 0)
        playerLayer.player = player
        self.playerLayer = playerLayer
        player.isMuted = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        preparePlayerWorkItem?.cancel()
        preparePlayerWorkItem = nil
        player.replaceCurrentItem(with: nil)
        removeObservers()
    }
    
    deinit {
        self.removeObservers()
    }
    
    func configure(with item: VideoItem) {
        titleLabel.text = item.title
        configurePlayer(with: item.videoUrl)
    }
}

//MARK: player item creation
private extension VideoCell {
    
    func configurePlayer(with urlString: String) {
        currentUrl = urlString
        let item = DispatchWorkItem(block: { [weak self] in
            guard let self else { return }
            let url = self.fileUrl(with: urlString)
            if let url {
                self.loopVideo()
                self.makeObserver()
                self.player.replaceCurrentItem(with: AVPlayerItem(url: url))
                self.playerLayer?.player = self.player
                DispatchQueue.main.async { [weak self] in
                    guard let self,
                          self.currentUrl == urlString else { return }
                }
            } else {
                self.player.replaceCurrentItem(with: nil)
                self.removeObservers()
            }
        })
        DispatchQueue.global(qos: .userInitiated).async(execute: item)
        preparePlayerWorkItem = item
    }
    
    func fileUrl(with urlString: String) -> URL? {
        let name = (urlString as NSString).deletingPathExtension
        guard let videoPath = Bundle.main.path(forResource: name, ofType: "mp4") else { return nil }
        return URL(fileURLWithPath: videoPath)
    }
}

//MARK: Observers
private extension VideoCell {
    
    func makeObserver() {
        observer = player.observe(\.timeControlStatus, options:  [.new, .old], changeHandler: { (player, change) in
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                switch player.timeControlStatus {
                case .playing:
                    //   print("playing")
                    self.activityIndicator.stopAnimating()
                case .paused:
                    // print("paused")
                    self.activityIndicator.startAnimating()
                    
                case .waitingToPlayAtSpecifiedRate:
                    // print("waiting")
                    self.activityIndicator.startAnimating()
                @unknown default:
                    break
                }
            }
         })
    }
    
    func removeObservers() {
        if let obs = loopObserver {
            NotificationCenter.default.removeObserver(obs)
        }
        observer?.invalidate()
        observer = nil
    }
    
    func loopVideo() {
        loopObserver = NotificationCenter.default.addObserver(
            forName: Notification.Name.AVPlayerItemDidPlayToEndTime,
            object: player.currentItem,
            queue: .main
        ) { [weak self] notification in
            guard let self else { return }
            self.player.seek(to: CMTime.zero)
            self.player.play()
        }
    }
}
