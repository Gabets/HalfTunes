import Foundation.NSURL

class Track {
  let artist: String
  let index: Int
  let name: String
  let previewURL: URL
  let artworkUrl: URL

  var downloaded = false
  
  init(name: String, artist: String, previewURL: URL, index: Int, artworkUrl: URL) {
    self.name = name
    self.artist = artist
    self.previewURL = previewURL
    self.index = index
    self.artworkUrl = artworkUrl
  }
}
