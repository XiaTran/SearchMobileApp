//
//  TableViewController.swift
//  SearchMobileApp
//
//  Created by Xia Tran on 14/11/2018.
//  Copyright © 2018 Xia Tran. All rights reserved.


import UIKit
import Alamofire
import JGProgressHUD

class TableViewController: UITableViewController,UISearchBarDelegate {

  @IBOutlet weak var searchBar: UISearchBar!
  var artistImageAndName = [ArtistImageAndName]()
  var searchURL = String()
  var searchedArtist = String()
  
  typealias JSONStandard = [String : Any]
  
  //Loading spinny thing
  let hud : JGProgressHUD = {
    let hud = JGProgressHUD(style: .light)
    hud.interactionType = .blockAllTouches
    return hud
  }()
  
  
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    let keywords = searchBar.text
    let keywordsAndSpaces = keywords?.replacingOccurrences(of: " ", with: "+")
//search for artist name
    searchURL = "http://ws.audioscrobbler.com/2.0/?method=artist.search&artist=\(keywordsAndSpaces!)&api_key=650fb36b73367ce84b82cd8c6b48a577&format=json"
    searchedArtist = keywordsAndSpaces!
    print(searchURL)
      artistImageAndName.removeAll()
    hud.textLabel.text = "Searching..."
    hud.show(in: view, animated: true)
    callAlamo(url: searchURL, headers: ["Content-Type": "application/x-www-form-urlencoded"])
    
    searchBar.endEditing(true)
    self.hud.dismiss(afterDelay: 2, animated: true)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    //position search bar in navigation bar to stop moving when scrolling
    navigationItem.titleView = searchBar
    navigationItem.hidesSearchBarWhenScrolling = false
  }
  
  //calls the parsed data
  func callAlamo(url: String, headers: [String : String]? = [:]) {
    Alamofire.request(url, headers: headers).responseJSON(completionHandler: {
      response in
      switch response.result {
      case .success:
               self.parseData(JSONData: response.data!)
      case .failure(let error):
        print("Error when serialising the url: \(error)")
        self.hud.textLabel.text = "Error: Check artist name is correct"
        self.hud.dismiss(afterDelay: 2, animated: true)
      }
    })
  }

  func parseData(JSONData: Data) {
    do {
      var readableJSON = try JSONSerialization.jsonObject(with: JSONData, options: .mutableContainers) as! JSONStandard
        if let results = readableJSON["results"] as? JSONStandard {
        if let artistmatches = results["artistmatches"] as? JSONStandard {
        if let artist = artistmatches["artist"] as? [JSONStandard] {
         
          for item in artist {
              let usedName = item["name"] as? String
              let artistUrl = item["url"] as? String


                if let images = item["image"] as? [JSONStandard] {
                  let selectedSmallImage = images[1]
                  let selectedLargeImage = images[3]
                
                  //if name of artist has a picture, get the URL, small icon for search page and large icon for artistView page
                    if let selectedSmallImageUrl = URL(string: selectedSmallImage["#text"] as! String) {
                      
                          let selectedLargeImageUrl = URL(string: selectedLargeImage["#text"] as! String)
                          let selectedLargeImageData = try! Data(contentsOf: selectedLargeImageUrl!)
                      let usedLargeImage = UIImage(data: (selectedLargeImageData as Data))
                      
                      let selectedSmallImageData = try! Data(contentsOf: selectedSmallImageUrl)
                      let usedSmallImage = UIImage(data: (selectedSmallImageData as Data))
                      
                      artistImageAndName.append(ArtistImageAndName.init(usedImage: usedSmallImage, usedName: usedName, artistUrlLink: artistUrl, artistLargeImage: usedLargeImage))
                    } else {
                      //if artist has no picture, use a noImageAvailable icon
                      let usedSmallImage = UIImage(named: "noImage")
                      let usedLargeImage = UIImage(named: "noImageLarge")
                    
                      //append
                    artistImageAndName.append(ArtistImageAndName.init(usedImage: usedSmallImage, usedName: usedName, artistUrlLink: artistUrl, artistLargeImage: usedLargeImage))
                  }
                    self.tableView.reloadData()
                }
            }
          }
        }
      }
    }
    catch {
      print(error)
    }
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return artistImageAndName.count
  }
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
    
    //tag 2 is the picture icon
    let usedImageView = cell?.viewWithTag(2) as! UIImageView
      usedImageView.image = artistImageAndName[indexPath.row].usedImage
    //tag 1 is the name of the artist
    let usedNameView = cell?.viewWithTag(1) as! UILabel
      usedNameView.text = artistImageAndName[indexPath.row].usedName
    
    return cell!
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    let indexPath = self.tableView.indexPathForSelectedRow?.row
    
    let vc = segue.destination as! ArtistView
    
    vc.image = artistImageAndName[indexPath!].artistLargeImage!
    vc.name = artistImageAndName[indexPath!].usedName!
    vc.artistUrl = artistImageAndName[indexPath!].artistUrlLink!
    
  }

}

