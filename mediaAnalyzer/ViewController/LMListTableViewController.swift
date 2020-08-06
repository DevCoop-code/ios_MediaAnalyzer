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
//        let tmpDir = NSTemporaryDirectory()
//        NSLog("File Temporary Directory path \(tmpDir) ")
        
        // Change the working directory
//        if fileMangr.changeCurrentDirectoryPath(dirPaths[0].path) {
            // Success to Change working directory
//        } else {
            // Fail to change working directory
//        }
        
        // Make new Directory
//        let newDir = dirPaths[0].appendingPathComponent("data")
//        do {
//            try fileMangr.createDirectory(at: newDir, withIntermediateDirectories: true, attributes: nil)
//        } catch let error as NSError {
//
//        }
        
        // Remove the Directory
//        do {
//            try fileMangr.removeItem(atPath: newDir.path)
//        } catch let error as NSError {
//
//        }
        
        // List of all of files
        let filelist: [String]
        do {
            filelist = try fileMangr.contentsOfDirectory(atPath: dirPaths[0].path)
            
            for filename in filelist {
                NSLog(filename)
                mediaFileArray.append(filename)
            }
        } catch let error as NSError {
            
        }
        
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
    
    // Add swipe to delete UITableViewCell
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            NSLog("Delete the table view cell")
        }
    }
}
