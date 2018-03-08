//
//  ViewController.swift
//  SpotifySDK1
//
//  Created by Jason Park on 3/4/18.
//  Copyright © 2018 Jason Park. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    var auth = SPTAuth.defaultInstance()!
    var session: SPTSession!
    var player: SPTAudioStreamingController?
    var loginUrl: URL?
    
    
    
    
    ///////////////////////////////////////////////////////////////////
    //--------MARK: CUSTOM UI----------------------------------------//
    ///////////////////////////////////////////////////////////////////
    
    //--------Spotify Login Button
    let spotifyLoginButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Sign in with Spotify", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        button.backgroundColor = UIColor(red: 3/255, green: 187/255, blue: 79/255, alpha: 1)
        button.layer.cornerRadius = 20
        
        button.addTarget(self, action: #selector(handleLoginToSpotify), for: .touchUpInside)
        return button
    }()

    
    
    
    ///////////////////////////////////////////////////////////////////
    //--------MARK: VIEW DID LOAD------------------------------------//
    ///////////////////////////////////////////////////////////////////
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(spotifyLoginButton)
        
        setupSpotifyLoginButtonConstraints()
        
        setup()
        NotificationCenter.default.addObserver(self, selector: #selector(updateAfterFirstLogin), name: Notification.Name(rawValue: "loginSuccessful"), object: nil)
    }

    fileprivate func setup() {
        SPTAuth.defaultInstance().clientID = "e8c7d4ec24ba4fe69a1bded75f95c6ba"
        SPTAuth.defaultInstance().redirectURL = URL(string: "SpotifySDK1://returnAfterLogin")
        SPTAuth.defaultInstance().requestedScopes = [SPTAuthStreamingScope, SPTAuthPlaylistReadPrivateScope, SPTAuthPlaylistModifyPublicScope, SPTAuthPlaylistModifyPrivateScope]
        loginUrl = SPTAuth.defaultInstance().spotifyWebAuthenticationURL()
        
    }
    
    func audioStreamingDidLogin(_ audioStreaming: SPTAudioStreamingController!) {
        // after a user authenticates a session, the SPTAudioStreamingController is then initialized and this method called
        print("logged in")
        self.player?.playSpotifyURI("spotify:track:58s6EuEYJdlb0kO7awm3Vp", startingWith: 0, startingWithPosition: 0, callback: { (error) in
            if (error != nil) {
                print("playing!")
            }
        })
    }
    
    
    
    ///////////////////////////////////////////////////////////////////
    //-----------------------MARK: HANDLERS--------------------------//
    ///////////////////////////////////////////////////////////////////
    
    
    //--------Handle Login--------------------------//
    @objc func handleLoginToSpotify() {
        if UIApplication.shared.openURL(loginUrl!) {
            if auth.canHandle(auth.redirectURL) {
                // To do - build in error handling
            }
        }
    }
    
    @objc func updateAfterFirstLogin () {
        if let sessionObj: AnyObject = UserDefaults.standard.object(forKey: "SpotifySession") as AnyObject? {
            let sessionDataObj = sessionObj as! Data
            let firstTimeSession = NSKeyedUnarchiver.unarchiveObject(with: sessionDataObj) as! SPTSession
            self.session = firstTimeSession
            initializePlayer(authSession: session)
        }
    }
    
    func initializePlayer(authSession:SPTSession){
        if self.player == nil {
            self.player = SPTAudioStreamingController.sharedInstance()
            self.player!.playbackDelegate = self as! SPTAudioStreamingPlaybackDelegate
            self.player!.delegate = self as! SPTAudioStreamingDelegate
            try! player!.start(withClientId: auth.clientID)
            self.player!.login(withAccessToken: authSession.accessToken)
        }
    }
    
    
    
    ///////////////////////////////////////////////////////////////////
    //--------MARK: CONSTRAINTS--------------------------------------//
    ///////////////////////////////////////////////////////////////////

    //--------Spotify Login Button Constraints
    fileprivate func setupSpotifyLoginButtonConstraints() {
        spotifyLoginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        spotifyLoginButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        spotifyLoginButton.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -150).isActive = true
        spotifyLoginButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
    }


}

