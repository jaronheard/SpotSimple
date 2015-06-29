//
//  Session.swift
//  SpotSimple
//
//  Created by Jaron Heard on 6/21/15.
//  Copyright (c) 2015 Jaron Heard. All rights reserved.
//

import Foundation

func syncSession(session: SPTSession) {
    let userDefaults = NSUserDefaults.standardUserDefaults()
    let sessionData = NSKeyedArchiver.archivedDataWithRootObject(session)
    userDefaults.setObject(sessionData, forKey: "spotifySession")
    userDefaults.synchronize()
}

func syncSession(session: SPTSession, notification: String) {
    let userDefaults = NSUserDefaults.standardUserDefaults()
    let sessionData = NSKeyedArchiver.archivedDataWithRootObject(session)
    userDefaults.setObject(sessionData, forKey: "spotifySession")
    userDefaults.synchronize()
    NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: notification, object: nil))
}