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
    
    var videoItems: [VideoItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if let items = loadJson(filename: "templates") {
            self.videoItems = [items,items,items,items].flatMap{ $0 }
            tableView.reloadData()
        }
        // Do any additional setup after loading the view.
    }
    
    func loadJson(filename fileName: String) -> [VideoItem]? {
        if let url = Bundle.main.url(forResource: fileName, withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let jsonData = try decoder.decode([VideoItem].self, from: data)
                return jsonData
            } catch {
                print("error:\(error)")
            }
        }
        return nil
    }
}


extension VideosViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videoItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VideoCell", for: indexPath) as! VideoCell
        cell.configure(with: videoItems[indexPath.row])
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
