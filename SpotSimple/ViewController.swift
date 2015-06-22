//
//  ViewController.swift
//  SpotSimple
//
//  Created by Jaron Heard on 6/16/15.
//  Copyright (c) 2015 Jaron Heard. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    let kClientID = "3232e7f472f34d1fa31e360e229f7df2"
    let kCallbackURL = "spotsimple://returnafterspotifylogin"
    let kTokenSwapURL = "http://localhost:1234/swap"
    let kTokenRefreshServiceURL = "http://localhost:1234/refresh"
    var auth = SPTAuth.defaultInstance()
    
    @IBOutlet weak var LoginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        LoginButton.hidden = true
        // Do any additional setup after loading the view, typically from a nib.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateAfterFirstLogin", name: "loginSuccessful", object: nil)
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        if let sessionObject:AnyObject = userDefaults.objectForKey("spotifySession") {
            //session available
        } else {
            LoginButton.hidden = false
        }
        
    }
    
    func updateAfterFirstLogin() {
        LoginButton.hidden = true
    }
    
    @IBAction func LoginWithSpotify(sender: AnyObject) {
        let loginURL = SPTAuth.defaultInstance().loginURL
        UIApplication.sharedApplication().openURL(loginURL)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

