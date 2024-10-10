//
//  VideosViewController.swift
//  VideosTable
//
//  Created by Alexey on 10.10.24.
//

//
//  VideosViewController.swift
//  VideosTable
//
//  Created by Alexey on 10.10.24.
//

import UIKit
import AVFoundation

final class VideosViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    private var videoItems: [VideoItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let items = fetchModelsFrom(filename: "templates") {
            videoItems = [items,items,items,items].flatMap{ $0 }
            tableView.reloadData()
        }
    }
    
    private func fetchModelsFrom(filename fileName: String) -> [VideoItem]? {
        guard let url = Bundle.main.url(
            forResource: fileName,
            withExtension: "json"
        ) else { return nil }
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let jsonData = try decoder.decode([VideoItem].self, from: data)
            return jsonData
        } catch {
            print("error:\(error)")
            return nil
        }
    }
}


extension VideosViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videoItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "VideoCell",
            for: indexPath
        )
        if let cell = cell as? VideoCell{
            cell.configure(with: videoItems[indexPath.row])
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let videoCell = cell as? VideoCell else { return }
        videoCell.player.play()
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let videoCell = cell as? VideoCell else { return }
        videoCell.player.pause()
    }
}
