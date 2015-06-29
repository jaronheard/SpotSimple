//
//  ViewController.swift
//  SpotSimple
//
//  Created by Jaron Heard on 6/16/15.
//  Copyright (c) 2015 Jaron Heard. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var auth = SPTAuth.defaultInstance()
    var nc = NSNotificationCenter.defaultCenter()
    let userDefaults = NSUserDefaults.standardUserDefaults()
    var session:SPTSession!
    var player:SPTAudioStreamingController!
    
    @IBOutlet weak var LoginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
        LoginButton.hidden = true
        // Do any additional setup after loading the view, typically from a nib.
        nc.addObserver(self, selector: "updateAfterFirstLogin", name: "loginSuccessful", object: session)
        nc.addObserver(self, selector: "updateAfterSessionSetup", name: "sessionSetupComplete", object: nil)
        nc.addObserver(self, selector: "updateAfterPlayerSetup", name: "playerSetupComplete", object: nil)
        
        initialSessionSetup()
    }
    
    func initialSessionSetup() {
        print("initialSessionSetup")
        if let sessionObject:AnyObject = self.userDefaults.objectForKey("spotifySession") {
            if let unarchivedSession = unarchiveSession(sessionObject) {
                if unarchivedSession.isValid() {
                    self.session = unarchivedSession
                    self.nc.postNotification(NSNotification(name: "sessionSetupComplete",object: nil))
                } else {
                    print("sessionInvalid")
                    refreshSession(unarchivedSession)
                }
            }
        } else {
            LoginButton.hidden = false
        }
    }
    
    func updateAfterFirstLogin(session: SPTSession) {
        print("updateAfterFirstLogin")
        if session.isValid() {
            self.session = session
            self.nc.postNotification(NSNotification(name: "sessionSetupComplete",object: nil))
        } else {
            print("invalid session recieved from callback")
            LoginButton.hidden = false
        }
    }
    
    func updateAfterSessionSetup() {
        print("updateAfterSessionSetup")
        setupPlayer()
    }
    
    func updateAfterPlayerSetup() {
        print("updateAfterPlayerSetup")
        playPlaylistFirstPageFromURI("spotify:user:cariboutheband:playlist:4Dg0J0ICj9kKTGDyFu0Cv4")
    }
    
    func playMusicAndStuff() {
        playPlaylistFirstPageFromURI("spotify:user:cariboutheband:playlist:4Dg0J0ICj9kKTGDyFu0Cv4")
        let sadsad = userFirstPlaylist("cariboutheband")
        //playPlaylistFirstPageFromURI(sadsad)
    }
    

    
    func playUsingSession(session: SPTSession!) {
        if player == nil {
            player = SPTAudioStreamingController(clientId: SPTAuth.defaultInstance().clientID)
        }
        
        player?.loginWithSession(session, callback: { (error: NSError!) -> Void in
            if error != nil {
                print("enabling playback got error \(error)")
                return
            }
            let library = self.getUserLibrary()
            self.player?.playURIs(library, fromIndex: 0, callback: { (error) -> Void in
                if error != nil {
                    print("playing uris got error \(error)")
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
            print("getting user saved tracks got error \(error)")
            return
        }
        if let resultObj = result as? [String] {
            library = resultObj
        } else {
            print("user tracks not a string array")
        }
    })
        return library
    }
    
    func setupPlayer() {
        if self.player == nil {
            self.player = SPTAudioStreamingController(clientId: SPTAuth.defaultInstance().clientID!)
            self.player.playbackDelegate = self.player.playbackDelegate //not sure about this line
            self.player.diskCache = SPTDiskCache(capacity: 1024 * 1024 * 64)
        }
        if self.player.loggedIn {
            self.nc.postNotification(NSNotification(name: "playerSetupComplete", object: nil))
        } else {
            self.player.loginWithSession(SPTAuth.defaultInstance().session, callback: { (error: NSError!) -> Void in
                if error != nil {
                    print("player.loginWithSession got error \(error)")
                    return
                } else {
                    self.nc.postNotification(NSNotification(name: "playerSetupComplete", object: nil))
                }
            })
        }
    }
    
    func testUserData() {
        let userReq = SPTUser.createRequestForCurrentUserWithAccessToken(SPTAuth.defaultInstance().session.accessToken, error: nil)
        SPTRequest.sharedHandler().performRequest(userReq, callback: { (error: NSError!, response: NSURLResponse!, data: NSData!) -> Void in
            if error != nil {
                print("getting user data got error \(error)")
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
        })
    }
    
    func playPlaylistFirstPageFromURI(uri: String) {
        let session = SPTAuth.defaultInstance().session
        let playlistReq = SPTPlaylistSnapshot.createRequestForPlaylistWithURI(NSURL(string:uri), accessToken: SPTAuth.defaultInstance().session.accessToken, error: nil)
        SPTRequest.sharedHandler().performRequest(playlistReq, callback: { (error: NSError!, response: NSURLResponse!, data: NSData!) -> Void in
            if error != nil {
                print("enabling playback got error \(error)")
                return
            }
            let playlistSnapshot = SPTPlaylistSnapshot(fromData: data, withResponse: response, error: nil)
            self.player.playURIs(playlistSnapshot.firstTrackPage.items, fromIndex: 0, callback: nil)
        })
    }
    
    func userFirstPlaylist(username: String) -> String {
        var firstPlaylist = ""
        let playlistListReq = SPTPlaylistList.createRequestForGettingPlaylistsForUser(username, withAccessToken: SPTAuth.defaultInstance().session.accessToken, error: nil)
        SPTRequest.sharedHandler().performRequest(playlistListReq, callback: { (error: NSError!, response: NSURLResponse!, data: NSData!) -> Void in
            if error != nil {
                print("getting playlist list for user \(username) got error \(error)")
                return
            }
            let playlistList = SPTPlaylistList(fromData: data, withResponse: response, error: nil)
            let firstPlaylistURI = playlistList.items[0].uri
            if let firstPlaylistString = firstPlaylistURI!.absoluteString {
                firstPlaylist = firstPlaylistString
            } else {
                firstPlaylist = "nice try"
            }
        })
        return firstPlaylist
    }
    
    func setupSession(sessionObject: AnyObject) {
        if let sessionDataObject = sessionObject as? NSData {
            if let session = NSKeyedUnarchiver.unarchiveObjectWithData(sessionDataObject) as? SPTSession {
                let validSession = session.isValid()
                if !validSession {
                    refreshSession(session)
                } else {
                    SPTAuth.defaultInstance().session = session
                }
            }
        }
    }
    
    func unarchiveSession(sessionObject: AnyObject) -> SPTSession? {
        print("unarchiveSession")
        var session: SPTSession?
        if let sessionDataObject = sessionObject as? NSData {
            if let session = NSKeyedUnarchiver.unarchiveObjectWithData(sessionDataObject) as? SPTSession {
                print("session downcast success")
            } else {
                print("sessionDataObject is not a valid SPTSession")
            }
        } else {
            print("sessionObject is not a valid NSData")
        }
        return session
    }
    
    func refreshSession(session: SPTSession) {
        print("refreshSession")
        SPTAuth.defaultInstance().renewSession(session, callback: { (error: NSError!,renewedSession: SPTSession!) -> Void in
            if let errorCheck = error {
                print("Error refreshing session \(error)")
                print("Check token refresh service")
                print("Token refresh URL \(SPTAuth.defaultInstance().tokenRefreshURL)")
                print("Has token refresh URL \(SPTAuth.defaultInstance().hasTokenRefreshService)")
                return
            }
            if renewedSession == nil {
                print("Check token refresh service")
                print("Token refresh URL \(SPTAuth.defaultInstance().tokenRefreshURL)")
                print("Has token refresh URL \(SPTAuth.defaultInstance().hasTokenRefreshService)")
                return
            }
            if renewedSession != nil {
                SPTAuth.defaultInstance().session = renewedSession!
                syncSession(SPTAuth.defaultInstance().session)
                self.nc.postNotification(NSNotification(name: "sessionSetupComplete", object: nil))
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

