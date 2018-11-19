//
//  Structs.swift
//  SearchMobileApp
//
//  Created by Xia Tran on 19/11/2018.
//  Copyright © 2018 Xia Tran. All rights reserved.
//
import UIKit
import Foundation

//for TableviewController original search artist
struct ArtistImageAndName {
  let usedImage : UIImage?
  let usedName : String?
  let artistUrlLink : String?
  let artistLargeImage : UIImage?
}

//for artistView, for additional tracks info
struct ArtistTopTracks {
  let topTrack : String?
}

//for artistView, additional albumns info
struct ArtistTopAlbums {
  let topAlbum : String?
}
