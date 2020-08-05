//
//  LMListTableViewController.swift
//  mediaAnalyzer
//
//  Created by HanGyo Jeong on 2020/08/05.
//  Copyright © 2020 HanGyoJeong. All rights reserved.
//

import UIKit

class LMListTableViewController: UIViewController {

    @IBOutlet weak var lmTableView: UITableView!
    
    var mediaFileArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set tableview delegate
        lmTableView.delegate = self
        lmTableView.dataSource = self

        // Get the local video files
        var fileMangr = FileManager.default
        NSLog("File Directory path \(fileMangr.currentDirectoryPath) ")
        
        // Get the document directory path
        let dirPaths = fileMangr.urls(for: .documentDirectory, in: .userDomainMask)
        NSLog("File Document Directory path \(dirPaths[0].path) ")
        
        // Get tthe temporary directory path
        let tmpDir = NSTemporaryDirectory()
        NSLog("File Temporary Directory path \(tmpDir) ")
        
        // Change the working directory
        if fileMangr.changeCurrentDirectoryPath(dirPaths[0].path!) {
            // Success to Change working directory
        } else {
            // Fail to change working directory
        }
        
        mediaFileArray = ["bip bop", "big buck bunny", "alticast atlantic girls in the lonely island"]
        
        lmTableView.estimatedRowHeight = 50
    }
}

//MARK: Table view delegates
extension LMListTableViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mediaFileArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = lmTableView.dequeueReusableCell(withIdentifier: "LMTableViewCell", for: indexPath) as! LMTableViewCell
        
        let row = indexPath.row
        cell.mediaFileNameLabel.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.headline)
        cell.mediaFileNameLabel.text = mediaFileArray[row]
        
        return cell
    }
}
