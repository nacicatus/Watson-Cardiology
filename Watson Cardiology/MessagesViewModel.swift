//
//  MessagesViewModel.swift
//  Watson Cardiology
//
//  Created by Saurabh Sikka on 21/10/16.
//  Copyright © 2016 Saurabh Sikka. All rights reserved.
//

import Foundation
import ConversationV1
import TextToSpeechV1
import AVFoundation
import JSQMessagesViewController

class MessagesViewModel {
    static var sharedInstance = MessagesViewModel()
    
    var tts: TextToSpeech?
    var player: AVAudioPlayer? = nil
    var convoService: Conversation?
    var workspaceID = ""
    var watsonContext: Context?
    var watsonEntities: [String: String] = [:]
    var timeInput: String = ""
    var timeFlag: Bool = false
    var reachedEndOfConversation = false
    var messages: [JSQMessage] = []
    
    func parseConversationResponse(text: String, date: NSDate, senderId: String, senderDisplayName: String, completion: ((data: (Bool, String))-> Void)) {
        guard let convoService = convoService else {
            print ("No conversation service")
            return
        }
        
        convoService.message(workspaceID, text: text, context: watsonContext, failure: { error in
            print ("error was generated when sending a message to service: \(error)")
            }, success: { dataResponse in
                
                // Check if time question has been answered to grab input
                if self.timeFlag {
                    self.timeInput = dataResponse.input.text ?? ""
                    self.timeFlag = false
                }
                // Get watson's reply to the user
                let output = dataResponse.output.text[0]
                // Check if time question was asked
                for o in dataResponse.output.text {
                    if o == "time" {
                        self.timeFlag = true
                    }
                }
                // Save watson's conversation context to continue using to keep conversation going.
                self.watsonContext = dataResponse.context
                // Store watson reply as JSQMessage.
                self.storeWatsonReply(date, output: output)
                // Store entities and user input
                self.storeEntities(dataResponse.entities)
                // Check what point watson has reached in the conversation
                self.reachedEndOfConversation = self.checkProgress(dataResponse.context)
                completion(data: (self.reachedEndOfConversation, output))
        })
    }
    
    /**
     Store entities and user input.
     
     - paramater entities: Dictionary with keys defined to be the entities inputted in Watson conversation service. Value
     is the user input/keyword associated with the entity.
     example: {
     [0] = (key = "occasions", value = "anniversary")
     [1] = (key = "romantic", value = "date")
     [2] = (key = "places", value = "out")
     [3] = (key = "time", value = "none")
     }
     */
    func storeEntities(entities: [Entity]) {
        if !entities.isEmpty {
            for e in entities {
                guard let key = e.entity, let val = e.value else {
                    break
                }
                watsonEntities[key] = val
            }
        }
    }
    
    /**
     Send back watson's reply as a text bubble.
     - paramater date: NSDate of today and time.
     - paramater output: Watson's response to the user's input.
     */
    func storeWatsonReply(date: NSDate, output: String) {
        let reply = JSQMessage(senderId: User.Watson.rawValue, senderDisplayName: "Watson", date: date, text: output)
        self.messages.append(reply)
    }
    
    func checkProgress(convoContext: Context) -> Bool {
        var displaySuggestions = false
        guard let node = convoContext.system?.dialogStack[0] else {
            return displaySuggestions
        }
        // Check if watson has reached the end of the conversation.
        if node.rangeOfString("root") != nil {
            displaySuggestions = true
        }
        // Check if the conversation has restarted to the first node or the "anything else" node.
        if (node.rangeOfString("node_1_") != nil) || (node.rangeOfString("node_3_") != nil) {
            
            // Clear entities
            watsonEntities = [:]
        }
        return displaySuggestions
    }
    
    func synthesizeText(text: String) {
        guard let tts = tts else {
            print ("no text to speech service")
            return
        }
        tts.synthesize(text,
                       voice: SynthesisVoice.US_Michael,
                       audioFormat: AudioFormat.WAV,
                       failure: { error in
                        print("error was generated \(error)")
        }) { data in
            do {
                self.player = try AVAudioPlayer(data: data)
                self.player!.play()
            } catch {
                print("Couldn't create player.")
            }
        }
    }
}
