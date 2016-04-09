//
//  ViewController.swift
//  TVAlert
//
//  Created by Austin Drummond on 04/03/2016.
//  Copyright (c) 2016 Austin Drummond. All rights reserved.
//

import UIKit
import TVAlert

func execAfter(delay:Double, closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}

struct TableViewItem {
    var title:String
    var didSelectHandler:dispatch_block_t
}

struct TableViewSection {
    var title:String
    var rows:[TableViewItem]
}

class ViewController: UITableViewController {
    
    var tableData:[TableViewSection] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "TVAlertController"
        
        let ui = TableViewSection(title: "UIAlerController", rows: [
            TableViewItem(title: "Simple") {
                self.showSimpleUIAlert()
            },TableViewItem(title: "Multibutton") {
                self.showMultiButtonUIAlert()
            },TableViewItem(title: "Login") {
                self.showLoginUIAlert()
            },
        ])
        
        let dark = TableViewSection(title: "Dark Style - TVAlertController", rows: [
            TableViewItem(title: "Simple") {
                self.showSimpleTVAlert(.Dark)
            },
            TableViewItem(title: "Multibutton") {
                self.showMultiButtonTVAlert(.Dark)
            },
            TableViewItem(title: "Login") {
                self.showLoginTVAlert(.Dark)
            },
        ]);
        
        let light = TableViewSection(title: "Light Style - TVAlertController", rows: [
            TableViewItem(title: "Simple") {
                self.showSimpleTVAlert(.Light)
            },
            TableViewItem(title: "Multibutton") {
                self.showMultiButtonTVAlert(.Light)
            },
            TableViewItem(title: "Login") {
                self.showLoginTVAlert(.Light)
            },
        ]);
        
        self.tableData = [ui, dark, light]
    }
    
    //MARK:- TableView Datasouce
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") ?? UITableViewCell()
        cell.textLabel?.text = self.tableData[indexPath.section].rows[indexPath.row].title
        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.tableData[section].title
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.tableData.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableData[section].rows.count
    }
    
    //MARK:- TableView Delegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.tableData[indexPath.section].rows[indexPath.row].didSelectHandler()
    }
}

// MARK: Action helpers
extension ViewController {
    
    
    // MARK: UIAlertController
    func showSimpleUIAlert() {
        let alertController = UIAlertController(title: "Title", message: "Default Message", preferredStyle: .Alert)
        
        
        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
            // ...
        }
        alertController.addAction(OKAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            // ...
        }
        alertController.addAction(cancelAction)

        
        self.presentViewController(alertController, animated: true) {
            // ...
        }
    }
    
    func showMultiButtonUIAlert() {
        let alertController = UIAlertController(title: "Title", message: "Default Message", preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            // ...
        }
        alertController.addAction(cancelAction)
        
        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
            // ...
        }
        alertController.addAction(OKAction)
        
        let destroyAction = UIAlertAction(title: "Destroy", style: .Destructive) { (action) in
            print(action)
        }
        alertController.addAction(destroyAction)
        
        self.presentViewController(alertController, animated: true) {
            // ...
        }
    }
    
    func showLoginUIAlert() {
        
        let alertController = UIAlertController(title: "Title", message: "Default Message", preferredStyle: .Alert)
        
        let loginAction = UIAlertAction(title: "Login", style: .Default) { (_) in
            let loginTextField = alertController.textFields![0] as UITextField
            let passwordTextField = alertController.textFields![1] as UITextField
            print("Login: \(loginTextField.text):\(passwordTextField.text)")
        }
        loginAction.enabled = false
        
        let forgotPasswordAction = UIAlertAction(title: "Forgot Password", style: .Destructive) { (_) in }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (_) in }
        
        alertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "Login"
            
            NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: textField, queue: NSOperationQueue.mainQueue()) { (notification) in
                loginAction.enabled = textField.text != ""
            }
        }
        
        alertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "Password"
            textField.secureTextEntry = true
        }
        
        alertController.addAction(loginAction)
        alertController.addAction(forgotPasswordAction)
        alertController.addAction(cancelAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    // MARK: TVAlertController
    func showSimpleTVAlert(style:UIBlurEffectStyle) {
        let alertController = TVAlertController(title: "Title", message: "Default Message", preferredStyle: .Alert)
        
        alertController.style = style
        
        let OKAction = TVAlertAction(title: "OK", style: .Default) { (action) in
            // ...
        }
        alertController.addAction(OKAction)
        
        let cancelAction = TVAlertAction(title: "Cancel", style: .Cancel) { (action) in
            // ...
        }
        alertController.addAction(cancelAction)
        
        
        self.presentViewController(alertController, animated: true) {
            // ...
        }
    }
    
    func showMultiButtonTVAlert(style:UIBlurEffectStyle) {
        let alertController = TVAlertController(title: "Title", message: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec ullamcorper nulla non metus auctor fringilla. Maecenas faucibus mollis interdum. Fusce dapibus, tellus ac cursus commodo, tortor mauris condimentum nibh, ut fermentum massa justo sit amet risus. Maecenas sed diam eget risus varius blandit sit amet non magna.", preferredStyle: .Alert)
        
        alertController.style = style
        
        let cancelAction = TVAlertAction(title: "Cancel", style: .Cancel) { (action) in
            // ...
        }
        alertController.addAction(cancelAction)
        
        let OKAction = TVAlertAction(title: "OK", style: .Default) { (action) in
            // ...
        }
        alertController.addAction(OKAction)
        
        let destroyAction = TVAlertAction(title: "Destroy", style: .Destructive) { (action) in
            print(action)
        }
        alertController.addAction(destroyAction)
        
        self.presentViewController(alertController, animated: true) {
            // ...
        }
    }
    
    func showLoginTVAlert(style:UIBlurEffectStyle) {
        
        let alertController = TVAlertController(title: "Title", message: "Default Message", preferredStyle: .Alert)
        
        alertController.style = style
        
        let loginAction = TVAlertAction(title: "Login", style: .Default) { (_) in
            let loginTextField = alertController.textFields![0] as UITextField
            let passwordTextField = alertController.textFields![1] as UITextField
            print("Login: \(loginTextField.text):\(passwordTextField.text)")
        }
        loginAction.enabled = false
        
        let forgotPasswordAction = TVAlertAction(title: "Forgot Password", style: .Destructive) { (action) in
            print("Test")
        }
        let cancelAction = TVAlertAction(title: "Cancel", style: .Cancel) { (_) in }
        
        alertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "Login"
            
            NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: textField, queue: NSOperationQueue.mainQueue()) { (notification) in
                loginAction.enabled = textField.text != ""
            }
        }
        
        alertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "Password"
            textField.secureTextEntry = true
        }
        
        alertController.addAction(loginAction)
        alertController.addAction(forgotPasswordAction)
        alertController.addAction(cancelAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
}

