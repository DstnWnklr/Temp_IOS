//
//  CardViewController.swift
//  Temp
//
//  Created by Dustin Winkler on 11.12.21.
//

import UIKit

class CardViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var vegetable:[String] = ["Test", "Test1", "Test2", "Test3", "Test4", "Test5", "Test6"]
    var vegImges:[String] = ["test", "test1", "test2", "test3", "test4", "test5", "test6"]
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var handleArea: UIView!
    
    var firebaseDB = FirebaseDB.getInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "ImageFolderTableCell", bundle: nil), forCellReuseIdentifier: "cell")
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.frame = tableView.frame.inset(by: UIEdgeInsets(top: 100, left: 0, bottom: 100, right: 0))
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vegetable.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ImageFolderTableCell
        
        return cell
    }
    
    func addTableContent() -> Bool {
        vegetable.insert("Test \(Int.random(in: 0..<6))", at: vegetable.startIndex)
        vegImges.insert("Test \(Int.random(in: 0..<6))", at: vegImges.startIndex)
        
        tableView.reloadData()
        
        return false
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        // delete
        let delete = UIContextualAction(style: .normal, title: nil) { (action, view, completionHandler) in
            print("Delete \(indexPath.row + 1)")
            completionHandler(true)
        }
        
        delete.image = UIImage(named: "Temp_Icon_Trash_Can")
        
        // swipe Action
        let swipe = UISwipeActionsConfiguration(actions: [delete])
        return swipe
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120.0;
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        // copy Link
        let link = UIContextualAction(style: .normal, title: nil) { (action, view, completionHandler) in
            print("Copy Link \(indexPath.row + 1)")
            self.presentShareSheet()
        }
        
        link.image = UIImage(named: "Temp_Icon_Share")
        
        // swipe Action
        let swipe = UISwipeActionsConfiguration(actions: [link])
        return swipe
    }
    
    @objc
    private func presentShareSheet() {
        let url = URL(string: "https://www.google.de")
        
        let shareSheetViewController = UIActivityViewController(
        activityItems: [
            url
        ],
        applicationActivities: nil
        )
        present(shareSheetViewController, animated: true)
    }
    
}
