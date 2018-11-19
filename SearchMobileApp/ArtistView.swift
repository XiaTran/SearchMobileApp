//
//  ArtistView.swift
//  SearchMobileApp
//
//  Created by Xia Tran on 15/11/2018.
//  Copyright © 2018 Xia Tran. All rights reserved.
//http://ws.audioscrobbler.com/2.0/?method=artist.gettopalbums&artist=cher&api_key=650fb36b73367ce84b82cd8c6b48a577&format=json

import Foundation
import UIKit
import Alamofire

class ArtistView : UIViewController {
  
  @IBOutlet var mainImageView: UIImageView!
  @IBOutlet var artistNameLabel: UILabel!
  @IBOutlet weak var artistTopTrackLabel: UILabel!
  @IBOutlet weak var artistTopAlbumLabel: UILabel!
  
  var artistTopTracks = [ArtistTopTracks]()
  var artistTopAlbums = [ArtistTopAlbums]()
  var image = UIImage()
  var name = String()
  var artistUrl = String()

typealias JSONStandard = [String : Any]
  
  override func viewDidLoad() {
    super.viewDidLoad()

    mainImageView.image = image
    artistNameLabel.text = name
    
    let nameAndSpaces = name.replacingOccurrences(of: " ", with: "+")
    print(nameAndSpaces)
    
    let artistTrackURL = "http://ws.audioscrobbler.com/2.0/?method=artist.gettoptracks&artist=\(nameAndSpaces)&api_key=650fb36b73367ce84b82cd8c6b48a577&format=json"
    
    let artistAlbumURL = "http://ws.audioscrobbler.com/2.0/?method=artist.gettopalbums&artist=\(nameAndSpaces)&api_key=650fb36b73367ce84b82cd8c6b48a577&format=json"
    
    print(artistTrackURL)
    callAlamoTrack(url: artistTrackURL)
    callAlamoAlbum(url: artistAlbumURL)
  }
  
  
  //takes user to the last.fm url of the artist
  @IBAction func urlButton(_ sender: Any) {
    UIApplication.shared.open(URL(string:artistUrl)! as URL, options: [:], completionHandler: nil)
  }
  
  
  func callAlamoTrack(url: String) {
    Alamofire.request(url).responseJSON(completionHandler: {
      response in
      self.parseDataTrack(JSONData: response.data!)
    })
  }
  
  func callAlamoAlbum(url: String) {
    Alamofire.request(url).responseJSON(completionHandler: {
      response in
      self.parseDataAlbum(JSONData: response.data!)
    })
  }
  
  
  func parseDataTrack(JSONData: Data) {
    do {
      var readableJSON = try JSONSerialization.jsonObject(with: JSONData, options: .mutableContainers) as! JSONStandard
      
        if let toptracks = readableJSON["toptracks"] as? JSONStandard {
//accessing API for track names
          if let track = toptracks["track"] as? [JSONStandard] {
            if track.count == 0 {
              artistTopTrackLabel.text = "No top tracks available"
            } else
          if track.count <= 1 {
            let topTrack = [track[0]] as [JSONStandard]
            var songInString = ""
              for song in topTrack {
                songInString += song["name"] as! String
                artistTopTrackLabel.text = (" - \(songInString)")
              }
          } else {
          let topTwoTracks = track[0...1]
          //remove the arraySlice
          let arrayTopTracks = Array(topTwoTracks)

          var songInStringArray = [""]
            for song in arrayTopTracks {
              songInStringArray.append(song["name"] as! String)
            }
            artistTopTrackLabel.text = songInStringArray.joined(separator: "\n - ")
            print(songInStringArray)
          }
        }
      }
    }
    catch {
      print(error)
    }
  }
 
  func parseDataAlbum(JSONData: Data) {
    do {
      var readableJSON = try JSONSerialization.jsonObject(with: JSONData, options: .mutableContainers) as! JSONStandard
      
      if let topAlbums = readableJSON["topalbums"] as? JSONStandard {
  //accessing API for album names
        if let album = topAlbums["album"] as? [JSONStandard] {
          if album.count <= 1 {
            artistTopAlbumLabel.text = "No top albums available"
          } else
            if album.count <= 2 {
              let topalbum = [album[0]] as [JSONStandard]
              var albumInString = ""
              for album in topalbum {
                albumInString += album["name"] as! String
                artistTopAlbumLabel.text = (" - \(albumInString)")
              }
            } else {
              let topTwoAlbums = album[0...1]
              //remove the arraySlice
              let arrayTopAlbums = Array(topTwoAlbums)
              
              var albumInStringArray = [""]
              for album in arrayTopAlbums {
                print(album)
                albumInStringArray.append(album["name"] as! String)
              }

              artistTopAlbumLabel.text = albumInStringArray.joined(separator: "\n - ")
              print(albumInStringArray)
          }
        }
      }
    }
    catch {
      print(error)
    }
  }

}
