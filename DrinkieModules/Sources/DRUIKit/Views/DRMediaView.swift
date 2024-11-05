import UIKit
import AVFoundation

final public class DRMediaView: UIView {
    
    private var imageView: UIImageView?
    private var videoView: VideoPlayerUIView?
    private var player: AVPlayer?
    private var playerLooper: AVPlayerLooper?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    deinit {
        player?.replaceCurrentItem(with: nil)
    }
    
    private func initImageView() {
        if self.imageView != nil { return }
        
        let imageView = UIImageView(frame: bounds)
        
        self.imageView = imageView
        if let videoView {
            insertSubview(imageView, belowSubview: videoView)
        } else {
            addSubview(imageView)
        }
    }
    
    private func initVideoView(player: AVPlayer) {
        if self.videoView != nil { return }
        let videoView = VideoPlayerUIView(frame: bounds, player: player, videoGravity: .resizeAspectFill)
        
        self.videoView = videoView
        if let imageView {
            insertSubview(videoView, aboveSubview: imageView)
        } else {
            addSubview(videoView)
        }
    }
    
    // MARK: - Public
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.imageView?.frame = bounds
        self.videoView?.frame = bounds
    }
    
    public func showImage(_ image: UIImage?, contentMode: UIView.ContentMode = .scaleAspectFill) {
        initImageView()
        
        guard let imageView else { return }
        imageView.contentMode = contentMode
        imageView.image = image
        imageView.isHidden = image == nil
    }
    
    public func showVideo(url: URL, videoGravity: AVLayerVideoGravity = .resizeAspectFill) {
        
        if let playerItem = player?.currentItem, let asset = playerItem.asset as? AVURLAsset, asset.url == url {
            return
        }
        
        let playerItem = AVPlayerItem(url: url)
        playerItem.preferredForwardBufferDuration = TimeInterval(1)
        
        if let player = player as? AVQueuePlayer {
            player.replaceCurrentItem(with: nil)
            player.replaceCurrentItem(with: playerItem)
            self.playerLooper = AVPlayerLooper(player: player, templateItem: playerItem)
        } else {
            let player = AVQueuePlayer()
            player.isMuted = true
            
            self.player = player
            self.playerLooper = AVPlayerLooper(player: player, templateItem: playerItem)
            initVideoView(player: player)
        }
        videoView?.videoGravity = videoGravity
    }
    
    public func pauseVideoPlayback() {
        player?.pause()
    }
    
    public func resumeVideoPlayback() {
        player?.play()
    }
}

final class VideoPlayerUIView: UIView {
    
    var player: AVPlayer {
        didSet {
            playerLayer.player = player
        }
    }
    
    var videoGravity: AVLayerVideoGravity {
        didSet {
            playerLayer.videoGravity = videoGravity
        }
    }
    
    private var playerLayer = AVPlayerLayer()
    
    init(frame: CGRect, player: AVPlayer, videoGravity: AVLayerVideoGravity) {
        self.player = player
        self.videoGravity = videoGravity
        self.playerLayer.videoGravity = videoGravity
        self.playerLayer.player = player
        
        super.init(frame: frame)
        
        layer.addSublayer(playerLayer)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
}
