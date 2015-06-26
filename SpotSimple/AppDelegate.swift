//
//  AppDelegate.swift
//  SpotSimple
//
//  Created by Jaron Heard on 6/16/15.
//  Copyright (c) 2015 Jaron Heard. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let kClientID = "3232e7f472f34d1fa31e360e229f7df2"
    let kCallbackURL = "spotsimple://returnafterspotifylogin"
    let kTokenSwapURL = "http://localhost:1234/swap"
    let kTokenRefreshServiceURL = "http://localhost:1234/refresh"
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        let canHandle = SPTAuth.defaultInstance().canHandleURL(url)
        if canHandle {
            SPTAuth.defaultInstance().handleAuthCallbackWithTriggeredAuthURL(url, callback: { (error: NSError!,session: SPTSession!) -> Void in
                if let errorCheck = error {
                    println("Authentication Error")
                    return
                }
                syncSession(session)
                NSNotificationCenter.defaultCenter().postNotificationName("loginSuccessful", object: nil)
            })
        }
        return false
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        SPTAuth.defaultInstance().clientID = kClientID
        SPTAuth.defaultInstance().redirectURL = NSURL(string: kCallbackURL)
        SPTAuth.defaultInstance().requestedScopes = [SPTAuthStreamingScope, SPTAuthPlaylistReadPrivateScope, SPTAuthPlaylistModifyPublicScope,SPTAuthPlaylistModifyPrivateScope,SPTAuthUserFollowModifyScope, SPTAuthUserFollowReadScope,SPTAuthUserLibraryModifyScope,SPTAuthUserLibraryReadScope,SPTAuthUserReadBirthDateScope,SPTAuthUserReadEmailScope,SPTAuthUserReadPrivateScope]
        return true
    }
    
    

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

