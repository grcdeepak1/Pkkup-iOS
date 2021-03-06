//
//  PkkupPlayer.swift
//  Pkkup
//
//  Copyright (c) 2014 Pkkup. All rights reserved.
//

import Foundation

var _currentPkkupPlayer: PkkupPlayer?
let PKKUP_CURRENT_USER_KEY = "kPkkupCurrentUserKey"
let PKKUP_USER_DID_LOGIN_NOTIFICATION = "pkkupUserDidLoginNotification"
let PKKUP_USER_DID_LOGOUT_NOTIFICATION = "pkkupUserDidLogoutNotification"

var _pkkupPlayerCache = NSCache()

class PkkupPlayer {
    var playerDictionary: NSDictionary

    // Player Attributes
    var id: Int?
    var name: String?
    var username: String?
    var email: String?
    var gravatarHash: String?
    var latitude: Double?
    var longitude: Double?
    var biography: String?
    var city: String?
    var state: String?
    var playerSports: [String]?

    // Relations
    var sports: [PkkupSport]?
    var followerIds: [Int]?
    var followingIds: [Int]?
    var followers: [PkkupPlayer]?
    var following: [PkkupPlayer]?
    var gamesConfirmedIds: [Int]?
    var gamesMaybeIds: [Int]?
    var gamesRecentIds: [Int]?
    var gamesConfirmed: [PkkupGame]?
    var gamesMaybe: [PkkupGame]?
    var gamesRecent: [PkkupGame]?
    var locationIds: [Int]?
    var locations: [PkkupLocation]?

    // Maybe implement if we have time...
    var groups: [PkkupGroup]?

    init(dictionary: NSDictionary) {
        self.playerDictionary = dictionary
        id = dictionary["id"] as? Int
        username = dictionary["username"] as? String
        name = dictionary["name"] as? String
        gravatarHash = dictionary["gravatar_hash"] as? String
        biography = dictionary["biography"] as? String
        city = dictionary["city"] as? String
        state = dictionary["state"] as? String
        playerSports = dictionary["sports"] as? [String]
        
        followerIds = dictionary["followers"] as? [Int]
        followingIds = dictionary["following"] as? [Int]
        
        var gamesDictionary = dictionary["games"] as NSDictionary
        gamesConfirmedIds = gamesDictionary["confirmed"] as? [Int]
        gamesMaybeIds = gamesDictionary["maybe"] as? [Int]
        gamesRecentIds = gamesDictionary["recent"] as? [Int]
        locationIds = dictionary["locations"] as? [Int]
        _pkkupPlayerCache.setObject(self, forKey: id!)
    }

    class func playersWithArray(playersArray: [NSDictionary]) -> [PkkupPlayer] {
        var players = playersArray.map({
            (dictionary: NSDictionary) -> PkkupPlayer in
            PkkupPlayer(dictionary: dictionary)
        })
        return players
    }

    class func playersWithIds(playerIds: [Int]) -> [PkkupPlayer] {
        var players = playerIds.map({
            (playerId: Int) -> PkkupPlayer in
            PkkupPlayer.get(playerId)
        })
        return players
    }

    class func get(id: Int) -> PkkupPlayer {
        var player = PkkupPlayer.getCached(id)!
        return player
    }

    class func getCached(id: Int) -> PkkupPlayer? {
        var player = _pkkupPlayerCache.objectForKey(id) as? PkkupPlayer
        return player
    }

    class var currentPlayer: PkkupPlayer? {
        get {
            if _currentPkkupPlayer == nil {
                var data = HTKUtils.getDefaults(PKKUP_CURRENT_USER_KEY) as? NSData
                if data != nil {
                    var userDictionary = NSJSONSerialization.JSONObjectWithData(data!, options: nil, error: nil) as NSDictionary
                    _currentPkkupPlayer = PkkupPlayer(dictionary: userDictionary)
                }
            }
            return _currentPkkupPlayer
        }
        
        set (player) {
            _currentPkkupPlayer = player
            if _currentPkkupPlayer != nil {
                var data = NSJSONSerialization.dataWithJSONObject(player!.playerDictionary, options: nil, error: nil)
                HTKUtils.setDefaults(PKKUP_CURRENT_USER_KEY, withValue: data)
            } else {
                HTKUtils.setDefaults(PKKUP_CURRENT_USER_KEY, withValue: nil)
            }
        }
    }

    func logout() {
        PkkupPlayer.currentPlayer = nil
        PkkupClient.sharedInstance.logout()
        NSNotificationCenter.defaultCenter().postNotificationName(PKKUP_USER_DID_LOGOUT_NOTIFICATION, object: nil)
    }

    func getGravatarImageUrl() -> String {
        var url = "http://www.gravatar.com/avatar/\(self.gravatarHash!)"
        return url
    }

    func getFollowers() -> [PkkupPlayer] {
        var followers = PkkupPlayer.playersWithIds(self.followerIds!)
        return followers
    }

    func getFollowing() -> [PkkupPlayer] {
        var following = PkkupPlayer.playersWithIds(self.followingIds!)
        return following
    }
    
    func getGamesConfirmed() -> [PkkupGame] {
        var confimedGames = PkkupGame.gamesWithIds(self.gamesConfirmedIds!)
        return confimedGames
    }
    
    func getGamesMaybe() -> [PkkupGame] {
        var maybeGames = PkkupGame.gamesWithIds(self.gamesMaybeIds!)
        return maybeGames
    }
    func getGamesRecent() -> [PkkupGame] {
        var recentGames = PkkupGame.gamesWithIds(self.gamesRecentIds!)
        return recentGames
    }
    
    func getLocations() -> [PkkupLocation] {
        var locations = PkkupLocation.locationsWithIds(self.locationIds!)
        return locations
    }
}
