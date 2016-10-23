//
//  User.swift
//  Watson Cardiology
//
//  Created by Saurabh Sikka on 21/10/16.
//  Copyright © 2016 Saurabh Sikka. All rights reserved.
//

import Foundation
import JSQMessagesViewController

// JSQMessages User Enum to make it easier to work with.
public enum User: String {
    case Hoffman    = "053496-4509-288"
    case Watson     = "707-8956784-57"
}

// JSQMessages Helper Function to get usernames for a specific User.
public func getName(user: User) -> String{
    switch user {
    case .Hoffman:
        return "Lara Hoffman"
    case .Watson:
        return "Thomas Watson"
    }
}

// JSQMessages Create an avatar with Image
private let AvatarWatson = JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(named:"watson_avatar"), diameter: 37);
private let AvatarHoffman = JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(named:"avatar_small"), diameter: 37);

// JSQMessages Helper Method for getting an avatar for a specific User.
public func getAvatar(id: String) -> JSQMessagesAvatarImage{
    let user = User(rawValue: id)!
    switch user {
    case .Hoffman:
        return AvatarHoffman
    case .Watson:
        return AvatarWatson
    }
}

