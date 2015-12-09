//
//  ViewController.swift
//  PackageTracker
//
//  Created by BJ on 4/26/15.
//  Copyright (c) 2015 Concepts In Code. All rights reserved.
//

import UIKit
import Foundation
import CoreData

class ViewController: UIViewController, UITableViewDataSource {

    var items = [String]()

    internal lazy var packageManager: PackageManager = { USPSManager() }()

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var trackingTextField: UITextField!
    @IBOutlet weak var trackPackageButton: UIButton!

    @IBAction func showHistory(sender: AnyObject?) {
        performSegueWithIdentifier("showHistorySegue", sender: nil)
    }
    
    private func parse(data: NSData) -> Info {
        let xmlParser = NSXMLParser(data: data)
        let packageInfo = Info()
        xmlParser.delegate = packageInfo
        xmlParser.parse()
        
        return packageInfo
    }
    
    // MARK: UITableViewDataSource methods
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCellWithIdentifier("PackageStatusLineCell") else {
            return UITableViewCell()
        }
        
        cell.textLabel?.text = items[indexPath.row]
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
	
    func fetchPackageInfo(packageID packageID: String, completion: (Void -> Void)? = nil) {
        let requestInfo = USPSRequestInfo(packageID: packageID)
        packageManager.fetchPackageResults(requestInfo) { [weak self] items in
            defer { self?.tableView.reloadData() }
            if items.isEmpty {
                self?.items = ["There's nothing to see here"]
            } else {
                self?.items = items
                completion?()
            }
            
        }
    }

}

extension ViewController : PackageDependencyInjectable {
    func updateDetailsForPackageID(packageID: String, completion: Void -> Void) {
        fetchPackageInfo(packageID: packageID, completion: completion)
    }
}

