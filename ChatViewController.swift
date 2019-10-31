//
//  ViewController.swift
//  Flash Chat
//
//  Created by Angela Yu on 29/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import Firebase
import ChameleonFramework

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    
    // Declare instance variables here
    var message_array:[Message] = [Message]()
    
    // We've pre-linked the IBOutlets
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var messageTextfield: UITextField!
    @IBOutlet var messageTableView: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO: Set yourself as the delegate and datasource here:
        messageTableView.delegate = self
        messageTableView.dataSource = self
        
        
        //TODO: Set yourself as the delegate of the text field here:
        messageTextfield.delegate = self
        
        
        //TODO: Set the tapGesture here: looks for single or multiple taps
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        messageTableView.addGestureRecognizer(tapGesture) //whenever I tap within the table view
        

        //TODO: Register your MessageCell.xib file here:
        messageTableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "customMessageCell")
        configureTableView()
        retrieveMessages()
        
        messageTableView.separatorStyle = .none
    }
    
    

    ///////////////////////////////////////////
    
    //MARK: - TableView DataSource Methods
    

    
    //TODO: Declare cellForRowAtIndexPath here:
    
    //Asks the data source for a cell to insert in a particular location of the table view.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //Returns a reusable table-view cell object for the specified reuse identifier and adds it to the table.
        //for all rows, give each a custom cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell
        cell.messageBody.text = message_array[indexPath.row].messageBody
        cell.senderUsername.text = message_array[indexPath.row].sender
        cell.avatarImageView.image = UIImage(named: "egg")
        
        if cell.senderUsername.text == Auth.auth().currentUser?.email {
            //my sent messages
            cell.avatarImageView.backgroundColor = UIColor.flatLime()
            cell.messageBody.backgroundColor = UIColor.flatSand()
            
        } else{
            cell.avatarImageView.backgroundColor = UIColor.flatRed()
            cell.messageBody.backgroundColor = UIColor.flatYellow()
        }
        
        return cell
    }
    
    //TODO: Declare numberOfRowsInSection here:
    
    //Tells the data source to return the number of rows in a given section of a table view. Provide it immediately
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return message_array.count
    }
    
    
    //TODO: Declare tableViewTapped here:
    @objc func tableViewTapped(){
        messageTextfield.endEditing(true)
    }
    
    
    //TODO: Declare configureTableView here: reformat the table view
    func configureTableView(){
        messageTableView.rowHeight = UITableView.automaticDimension
        messageTableView.estimatedRowHeight = 120.0
    }
    
    
    ///////////////////////////////////////////
    
    //MARK:- TextField Delegate Methods
    
    

    
    //TODO: Declare textFieldDidEndEditing here: called manually - needs a tap gesture registered
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        //Trailing closure
        
        UIView.animate(withDuration: 0.5){
            //increase height constraint of the text bar to 258
            self.heightConstraint.constant = 50
            self.view.layoutIfNeeded() //Lays out the subviews immediately, if layout updates are pending.
        }
    }
    
    
    
    //TODO: Declare textFieldDidBeginEditing here:
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.5){
            self.heightConstraint.constant = 350
            self.view.layoutIfNeeded()
        }
    }

    
    ///////////////////////////////////////////
    
    
    //MARK: - Send & Recieve from Firebase
    
    
    
    
    //once Send button is pressed
    @IBAction func sendPressed(_ sender: AnyObject) {
        
        messageTextfield.endEditing(true)
        messageTextfield.isEnabled = false
        sendButton.isEnabled = false
        
        //TODO: Send the message to Firebase and save it in our database - Messages exists in Firebase as a node/DB root
        let message_DB = Database.database().reference().child("Messages")
        let message_dictionary = ["Sender":Auth.auth().currentUser?.email, "MessageBody":messageTextfield.text!]
        
        message_DB.childByAutoId().setValue(message_dictionary){
            (error, reference) in
            if error != nil {
                print(error!)
            } else{
                print("Message saved successfully..")
                
                //enable button and text field
                self.messageTextfield.isEnabled = true
                self.sendButton.isEnabled = true
                self.messageTextfield.text = "" //reset message body to empty
            }
        }
        
    }
    
    //TODO: Create the retrieveMessages method here:
    func retrieveMessages(){
        let message_DB = Database.database().reference().child("Messages")
        message_DB.observe(.childAdded) { (snapshot) in //used to listen for data changes at a particular location
            let snapshot_value = snapshot.value as! Dictionary<String,String>
            
            let text_written = snapshot_value["MessageBody"]!
            let sender = snapshot_value["Sender"]!
            print(sender,text_written)
            
            //Create a Message instant
            let message = Message()
            message.messageBody = text_written
            message.sender = sender
            
            self.message_array.append(message)
            self.configureTableView()
            self.messageTableView.reloadData()
        }
    }
    

    
    
    
    @IBAction func logOutPressed(_ sender: AnyObject) {
        
        //TODO: Log out the user and send them back to WelcomeViewController
        do{
            try Auth.auth().signOut()
            print("Logged out successfully")
            navigationController?.popToRootViewController(animated: true)
        } catch{
            print("Trying to log out...")
        }
        
    }
    


}
