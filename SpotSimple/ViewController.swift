//
//  ViewController.swift
//  SpotSimple
//
//  Created by Jaron Heard on 6/16/15.
//  Copyright (c) 2015 Jaron Heard. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    let kTokenSwapURL = "http://localhost:1234/swap"
    let kTokenRefreshServiceURL = "http://localhost:1234/refresh"
    var auth = SPTAuth.defaultInstance()
    var session:SPTSession!
    var player:SPTAudioStreamingController!
    
    @IBOutlet weak var LoginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        LoginButton.hidden = true
        // Do any additional setup after loading the view, typically from a nib.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateAfterFirstLogin", name: "loginSuccessful", object: nil)
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        if let sessionObject:AnyObject = userDefaults.objectForKey("spotifySession") {
            //session available
            if let sessionDataObject = sessionObject as? NSData {
                if let session = NSKeyedUnarchiver.unarchiveObjectWithData(sessionDataObject) as? SPTSession {
                    if !session.isValid() {
                        SPTAuth.defaultInstance().renewSession(self.session, callback: { (error: NSError!,renewedSession: SPTSession!) -> Void in
                            if let errorCheck = error {
                                println("Error refreshing session")
                                return
                            }
                            if renewedSession != nil {
                                self.session = renewedSession!
                                syncSession(self.session)
                            }
                        })
                    } else {
                        SPTAuth.defaultInstance().session = session
                    }
                }
            }
            handleNewSession()
        } else {
            LoginButton.hidden = false
        }
    }
    
    func updateAfterFirstLogin() {
        LoginButton.hidden = true
    }
    
    func playUsingSession(session: SPTSession!) {
        if player == nil {
            player = SPTAudioStreamingController(clientId: SPTAuth.defaultInstance().clientID)
        }
        
        player?.loginWithSession(session, callback: { (error: NSError!) -> Void in
            if error != nil {
                println("enabling playback got error \(error)")
                return
            }
            let library = self.getUserLibrary()
            self.player?.playURIs(library, fromIndex: 0, callback: { (error) -> Void in
                if error != nil {
                    println("playing uris got error \(error)")
                    return
                }
            })
        })
    }
    
    @IBAction func LoginWithSpotify(sender: AnyObject) {
        let loginURL = SPTAuth.defaultInstance().loginURL
        UIApplication.sharedApplication().openURL(loginURL)
    }
    
    func getUserLibrary() -> [String]? {
        var checkError:NSErrorPointer
        var library:[String]?
SPTYourMusic.savedTracksForUserWithAccessToken(session.accessToken, callback: { (error, result) -> Void in
        if error != nil {
            println("getting user saved tracks got error \(error)")
            return
        }
        if let resultObj = result as? [String] {
            library = resultObj
        } else {
            println("user tracks not a string array")
        }
    })
        return library
    }
    
    func handleNewSession() {
        if self.player == nil {
            self.player = SPTAudioStreamingController(clientId: SPTAuth.defaultInstance().clientID!)
            self.player.playbackDelegate = self.player.playbackDelegate //not sure about this line
            self.player.diskCache = SPTDiskCache(capacity: 1024 * 1024 * 64)
            self.player.loginWithSession(SPTAuth.defaultInstance().session, callback: { (error: NSError!) -> Void in
                if error != nil {
                    println("enabling playback got error \(error)")
                    return
                }
            })
/* testcode
            let userReq = SPTUser.createRequestForCurrentUserWithAccessToken(SPTAuth.defaultInstance().session.accessToken, error: nil)
            SPTRequest.sharedHandler().performRequest(userReq, callback: { (error: NSError!, response: NSURLResponse!, data: NSData!) -> Void in
                if error != nil {
                    println("gettin user data got error \(error)")
                    return
                }
                let user = SPTUser(fromData: data, withResponse: response, error: nil)
                let product = user.product
                let username = user.displayName
                let canonicalUserName = user.canonicalUserName
                let territory = user.territory
                let email = user.emailAddress
                let uri = user.uri
                let sharingURL = user.sharingURL
                let followers = user.followerCount
                let ds = 1
            })
*/            
            let playlistReq = SPTPlaylistSnapshot.createRequestForPlaylistWithURI(NSURL(string: "spotify:user:cariboutheband:playlist:4Dg0J0ICj9kKTGDyFu0Cv4"), accessToken: SPTAuth.defaultInstance().session.accessToken, error: nil)
            SPTRequest.sharedHandler().performRequest(playlistReq, callback: { (error: NSError!, response: NSURLResponse!, data: NSData!) -> Void in
                if error != nil {
                    println("enabling playback got error \(error)")
                    return
                }
                let playlistSnapshot = SPTPlaylistSnapshot(fromData: data, withResponse: response, error: nil)
                self.player.playURIs(playlistSnapshot.firstTrackPage.items, fromIndex: 0, callback: nil)
/* testcode
                let seconds = 4.0
                let delay = seconds * Double(NSEC_PER_SEC)  // nanoseconds per seconds
                var dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                
                dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                    
                    let trackURI = self.player.currentTrackURI
                    let trackDur = self.player.currentTrackDuration
                    let bd = 1
                    
                })
*/
            })
        }
    }
    
    func displayUserAlbums() {
        //do stuff
    }
    
    func loginWithSession() {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

