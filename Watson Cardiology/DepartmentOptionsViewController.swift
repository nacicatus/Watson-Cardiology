//
//  DepartmentOptionsViewController.swift
//  Watson Cardiology
//
//  Created by Saurabh Sikka on 21/10/16.
//  Copyright © 2016 Saurabh Sikka. All rights reserved.
//

import UIKit
import Foundation
import ConversationV1
import TextToSpeechV1


private let reuseIdentifier = "DepartmentCell"

class DepartmentOptionsViewController: UIViewController {
    
    // IBOutlets
    @IBOutlet weak var departmentCollectionView: UICollectionView!
    @IBOutlet var gestureRecognizer: UITapGestureRecognizer!
    
    
    // To use for Watson conversation service
    private var convoService: Conversation!
    private var workspaceID: String?
    var convoContext: Context?
    var greeting: String?
    var tts: TextToSpeech!
    
    // some error messages and codes
    private let conversationErrorCode = -6004
    private let internetErrorCode = -10049
    private let internetAlertTitle = "No Internet Connection"
    private let internetAlertMessage = "Make sure your device is connected to the internet."
    private let credentialsAlertTitle = "Conversation Service Unavailable"
    private let credentialsAlertMessage = "Please make sure you entered your Conversation service credentials correctly."
    private let departmentsAlertTitle = "Please Note"
    private let departmentsAlertMessage = "This is a demo application for Cardiology only. Feel free to pull and add the functionality for other tiles."
    
    // department labels
    private let cardiologyDepartmentLabelText = "CARDIOLOGY"
    private let endocrinologyDepartmentLabelText = "ENDOCRINOLOGY"
    private let neurologyDepartmentLabelText = "NEUROLOGY"
    
    
    override func viewDidLoad() {
        // Get Watson configuration values
        guard let configurationPath = NSBundle.mainBundle().pathForResource("WatsonCardiology", ofType: "plist") else {
            print("problem loading configuration file")
            return
        }
        let configuration = NSDictionary(contentsOfFile: configurationPath)
        workspaceID = WorkspaceID(configuration?["ConversationWorkspaceID"] as! String)
        convoContext = nil
        
        // Instantiating to start first conversation with Watson.
        convoService = Conversation(username: configuration?["ConversationUsername"] as! String, password: configuration?["ConversationPassword"] as! String, version: configuration?["ConversationVersion"] as! String)
        
        // Instantiating to start text to speech service.
        tts = TextToSpeech(username: configuration?["TextToSpeechUsername"] as! String, password: configuration?["TextToSpeechPassword"] as! String)
        
    }
    
    
    /** When button is pressed, call the Watson Conversation services to begin
     the conversation. */
    func collectionCellPressed() {
        
        guard let id = workspaceID else {
            print("no id or context found")
            return
        }
        
        // Call conversation service for Watson to initiate conversation.
        self.convoService.message(id, text: "Hi", context: nil, failure: { error in
            // Alert user to connect to internet
            if error.code == self.conversationErrorCode {
                self.alertUserWithMessage(self.credentialsAlertTitle, message: self.credentialsAlertMessage)
            } else if error.code == self.internetErrorCode {
                self.alertUserWithMessage(self.internetAlertTitle, message: self.internetAlertMessage)
            } else {
                self.alertUserWithMessage("Error", message: "\(error)")
            }
            
            print("error generated when sending message to service: \(error)")
            }, success: { dataResponse in
                // Save the Watson's greeting response.
                self.greeting = dataResponse.output.text[0]
                
                // Save the conversation context to pass to MessagesVC
                self.convoContext = dataResponse.context
                
                // Perform segue once necessary information is grabbed.
                self.performSegueWithIdentifier("toHello", sender: nil)
                
        })
    }
    
    // Show alert to connect device to internet.
    func alertUserWithMessage(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertController.addAction(defaultAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Navigation
    
    // Pass the key words from watson to restaurants view controller.
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let messagesVC = segue.destinationViewController as? MessagesViewController {
            
            // Make sure we have the necessary conversation instantiation variables
            guard let id = self.workspaceID else {
                print("no workspace id to give to MessagesVC")
                return
            }
            
            // Make sure we have the greeting for Watson to give
            guard let greeting = self.greeting else {
                print("no greeting found")
                return
            }
            
            // Pass context and workspace ID
            messagesVC.setupViewModel()
            messagesVC.viewModel.watsonContext = convoContext
            messagesVC.viewModel.workspaceID = id
            messagesVC.viewModel.tts = self.tts
            messagesVC.viewModel.convoService = self.convoService
            // Call to JSQMessage to display Watson's greeting in a text bubble.
            messagesVC.viewModel.storeWatsonReply(NSDate(), output: greeting)
            messagesVC.viewModel.synthesizeText(greeting)
        }
    }
    
}


// MARK: CollectionView for department Options
extension DepartmentOptionsViewController: UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("DepartmentCell", forIndexPath: indexPath) as! DepartmentCollectionViewCell
        cell.departmentNameLabel.font = UIFont.boldSystemFontOfSize(12.0)
        
        
        switch indexPath.item {
        case 0:
            cell.departmentImage.image = UIImage(named:"cardiology")
            cell.departmentNameLabel.text = cardiologyDepartmentLabelText
            cell.departmentNameLabel.adjustsFontSizeToFitWidth = true
        case 1:
            cell.departmentImage.image = UIImage(named:"endocrinology")
            cell.departmentNameLabel.text = endocrinologyDepartmentLabelText
            cell.departmentNameLabel.adjustsFontSizeToFitWidth = true
        case 2:
            cell.departmentImage.image = UIImage(named:"neurology")
            cell.departmentNameLabel.text = neurologyDepartmentLabelText
            cell.departmentNameLabel.adjustsFontSizeToFitWidth = true
        default:
            break
        }
        return cell
    }
    
    @IBAction func handleGestureRecognizer(sender: AnyObject) {
        if gestureRecognizer.state != UIGestureRecognizerState.Ended {
            return
        }
        
        let p = gestureRecognizer.locationInView(departmentCollectionView)
        let indexPath = departmentCollectionView.indexPathForItemAtPoint(p)
        
        if let index = indexPath {
            // Disable other clicks
            gestureRecognizer.enabled = false
            switch index.row {
            case 0:
                // Cardiology clicked
                collectionCellPressed()
            case 1:
                // Endocrinology clicked
                alertUserWithMessage(departmentsAlertTitle, message: departmentsAlertMessage)
                gestureRecognizer.enabled = true;
            case 2:
                // Neurology clicked
                alertUserWithMessage(departmentsAlertTitle, message: departmentsAlertMessage)
                gestureRecognizer.enabled = true;
            default:
                break
            }
        } else {
            print("Could not find index path")
        }
    }
}

extension DepartmentOptionsViewController: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let cellWidth = collectionView.frame.size.width
        let cellSpacing = (collectionView.frame.size.height * (25/451))/2
        let cellHeight = (collectionView.frame.size.height - (2 * cellSpacing))/3
        return CGSizeMake(cellWidth, cellHeight)
    }
}



