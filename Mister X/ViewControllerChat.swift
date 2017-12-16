//
//  ViewControllerChat.swift
//
//
//  Created by admin on 09.11.17.
//

import UIKit
import JSQMessagesViewController
import Firebase


class ViewControllerChat: JSQMessagesViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    var ref: DatabaseReference!
    var messageRef: DatabaseReference!
    
    var chatmessages = [JSQMessage]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //those three things make the colors look like they are correct. If it is transparent it will be too dark
        navigationController?.navigationBar.isTranslucent = false
        tabBarController?.tabBar.isTranslucent = false
        self.inputToolbar.isTranslucent = false
        
        //getting information about the user
        let defaults = UserDefaults.standard
        var currentGame = defaults.string(forKey: "currentGame")
        //gamecode is only available to users who joined.
        if (currentGame?.isEmpty == true){
            currentGame = defaults.string(forKey: "gameCode")
        }
        senderId = defaults.string(forKey: "uid")
        senderDisplayName = defaults.string(forKey: "name")
        
        ref = Database.database().reference()
        messageRef = ref.child("game/" + currentGame!).child("messages")
        
        
        //hides attachement
        inputToolbar.contentView.leftBarButtonItem = nil
        //makes avatars disappear
        collectionView.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        
        
        
        
        
        let query = messageRef.queryLimited(toLast: 10)
        
        
        _ = query.observe(.childAdded, with: { [weak self] snapshot in
            
            if  let data        = snapshot.value as? [String: String],
                let id          = data["sender_id"],
                let text        = data["text"],
                !text.isEmpty
            {
                self?.createMessage(senderID: id, text: text)
            }
        })
    }
    
    func createMessage(senderID: String!, text: String!){
        let usernameref = ref.child("user").child(senderID).child("username")
        usernameref.observe(.value, with: { (snapshot) in
            //get the single value
            if let value = snapshot.value as? String{
                
                if let message = JSQMessage(senderId: senderID, displayName: value, text: text){
                    self.chatmessages.append(message)
                    
                    self.finishReceivingMessage()
                }
            }
        })
       
            

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //sends message
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!){
        
        let singleMessageRef = messageRef.childByAutoId()
        
        let message = ["sender_id": senderId, "text": text]
        
        singleMessageRef.setValue(message)
        
        finishSendingMessage()
    }
    
    //returns message by index
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData!
    {
        return chatmessages[indexPath.item]
    }
    
    //returns how many messages there are
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return chatmessages.count
    }
    
    
    //creates bubble for outgoing texts
    lazy var outgoingBubble: JSQMessagesBubbleImage = {
        return JSQMessagesBubbleImageFactory()!.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    }()
    
    //creates bubble for incoming texts
    lazy var incomingBubble: JSQMessagesBubbleImage = {
        return JSQMessagesBubbleImageFactory()!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    }()
    
    //decides whether it is an incomming bubble or outgoing bubble
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource!{
        return chatmessages[indexPath.item].senderId == senderId ? outgoingBubble : incomingBubble
    }
    
    //hides avatars
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource!{
        return nil
    }
    
    
    //displays the sender above the speach bubble
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString!{
        return chatmessages[indexPath.item].senderId == senderId ? nil : NSAttributedString(string: chatmessages[indexPath.item].senderDisplayName)
    }
    
    //height of top label that displays the sender
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat{
        return chatmessages[indexPath.item].senderId == senderId ? 0 : 15
    }
    
    
    
    
    
    //MARK: - Delegates
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}


