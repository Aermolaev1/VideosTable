//
//  VideosViewController.swift
//  VideosTable
//
//  Created by Alexey on 10.10.24.
//

import UIKit
import AVKit
import AVFoundation

class VideosViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.reloadData()
        // Do any additional setup after loading the view.
    }
}


extension VideosViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 16
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VideoCell", for: indexPath) as! VideoCell
        let videoPath = Bundle.main.path(forResource: "cake", ofType: "mp4")!
        cell.configure(with: videoPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let videoCell = (cell as? VideoCell) else { return }
        videoCell.playerLayer?.player?.play()
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let videoCell = (cell as? VideoCell) else { return }
        videoCell.playerLayer?.player?.pause()
    }
}
