//
//  ViewController.swift
//  TVAlert
//
//  Created by Austin Drummond on 04/03/2016.
//  Copyright (c) 2016 Austin Drummond. All rights reserved.
//

import Foundation
import UIKit
import TVAlert

func execAfter(_ delay:Double, closure:@escaping ()->()) {
    DispatchQueue.main.asyncAfter(
        deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
}

struct TableViewItem {
    var title:String
    var didSelectHandler:()->()
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
                self.showSimpleTVAlert(.dark)
            },
            TableViewItem(title: "Multibutton") {
                self.showMultiButtonTVAlert(.dark)
            },
            TableViewItem(title: "Login") {
                self.showLoginTVAlert(.dark)
            },
        ]);
        
        let light = TableViewSection(title: "Light Style - TVAlertController", rows: [
            TableViewItem(title: "Simple") {
                self.showSimpleTVAlert(.light)
            },
            TableViewItem(title: "Multibutton") {
                self.showMultiButtonTVAlert(.light)
            },
            TableViewItem(title: "Login") {
                self.showLoginTVAlert(.light)
            },
        ]);
        
        self.tableData = [ui, dark, light]
    }
    
    //MARK:- TableView Datasouce
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") ?? UITableViewCell()
        cell.textLabel?.text = self.tableData[indexPath.section].rows[indexPath.row].title
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.tableData[section].title
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.tableData.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableData[section].rows.count
    }
    
    //MARK:- TableView Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.tableData[indexPath.section].rows[indexPath.row].didSelectHandler()
    }
}

// MARK: Action helpers
extension ViewController {
    
    
    // MARK: UIAlertController
    func showSimpleUIAlert() {
        let alertController = UIAlertController(title: "Title", message: "Default Message", preferredStyle: .alert)
        
        
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
            // ...
        }
        alertController.addAction(OKAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            // ...
        }
        alertController.addAction(cancelAction)

        
        self.present(alertController, animated: true) {
            // ...
        }
    }
    
    func showMultiButtonUIAlert() {
        let alertController = UIAlertController(title: "Title", message: "Default Message", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            // ...
        }
        alertController.addAction(cancelAction)
        
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
            // ...
        }
        alertController.addAction(OKAction)
        
        let destroyAction = UIAlertAction(title: "Destroy", style: .destructive) { (action) in
            print(action)
        }
        alertController.addAction(destroyAction)
        
        self.present(alertController, animated: true) {
            // ...
        }
    }
    
    func showLoginUIAlert() {
        
        let alertController = UIAlertController(title: "Title", message: "Default Message", preferredStyle: .alert)
        
        let loginAction = UIAlertAction(title: "Login", style: .default) { (_) in
            let loginTextField = alertController.textFields![0] as UITextField
            let passwordTextField = alertController.textFields![1] as UITextField
            print("Login: \(loginTextField.text):\(passwordTextField.text)")
        }
        loginAction.isEnabled = false
        
        let forgotPasswordAction = UIAlertAction(title: "Forgot Password", style: .destructive) { (_) in }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Login"
            
            NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange, object: textField, queue: OperationQueue.main) { (notification) in
                loginAction.isEnabled = textField.text != ""
            }
        }
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Password"
            textField.isSecureTextEntry = true
        }
        
        alertController.addAction(loginAction)
        alertController.addAction(forgotPasswordAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: TVAlertController
    func showSimpleTVAlert(_ style:UIBlurEffectStyle) {
        let alertController = TVAlertController(title: "Title", message: "Default Message", preferredStyle: .alert)
        
        alertController.style = style
        
        let OKAction = TVAlertAction(title: "OK", style: .default) { (action) in
            // ...
        }
        alertController.addAction(OKAction)
        
        let cancelAction = TVAlertAction(title: "Cancel", style: .cancel) { (action) in
            // ...
        }
        alertController.addAction(cancelAction)
        
        
        self.present(alertController, animated: true) {
            // ...
        }
    }
    
    func showMultiButtonTVAlert(_ style:UIBlurEffectStyle) {
        let alertController = TVAlertController(title: "Title", message: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec ullamcorper nulla non metus auctor fringilla. Maecenas faucibus mollis interdum. Fusce dapibus, tellus ac cursus commodo, tortor mauris condimentum nibh, ut fermentum massa justo sit amet risus. Maecenas sed diam eget risus varius blandit sit amet non magna.", preferredStyle: .alert)
        
        alertController.style = style
        
        let cancelAction = TVAlertAction(title: "Cancel", style: .cancel) { (action) in
            // ...
        }
        alertController.addAction(cancelAction)
        
        let OKAction = TVAlertAction(title: "OK", style: .default) { (action) in
            // ...
        }
        alertController.addAction(OKAction)
        
        let destroyAction = TVAlertAction(title: "Destroy", style: .destructive) { (action) in
            print(action)
        }
        alertController.addAction(destroyAction)
        
        self.present(alertController, animated: true) {
            // ...
        }
    }
    
    func showLoginTVAlert(_ style:UIBlurEffectStyle) {
        
        let alertController = TVAlertController(title: "Title", message: "Default Message", preferredStyle: .alert)
        
        alertController.style = style
        
        let loginAction = TVAlertAction(title: "Login", style: .default) { (_) in
            let loginTextField = alertController.textFields![0] as UITextField
            let passwordTextField = alertController.textFields![1] as UITextField
            print("Login: \(loginTextField.text):\(passwordTextField.text)")
        }
        loginAction.isEnabled = false
        
        let forgotPasswordAction = TVAlertAction(title: "Forgot Password", style: .destructive) { (action) in
            print("Test")
        }
        let cancelAction = TVAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Login"
            
            NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange, object: textField, queue: OperationQueue.main, using: { (notification) in
                  loginAction.isEnabled = textField.text != ""
            })
        }
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Password"
            textField.isSecureTextEntry = true
        }
        
        alertController.addAction(loginAction)
        alertController.addAction(forgotPasswordAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
}

