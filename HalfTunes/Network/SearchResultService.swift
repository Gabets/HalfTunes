
import Foundation

struct SearchResultService {
  static func updateSearchResults(_ data: Data) -> ([Track], String) {
    var tracks: [Track] = []
    var errorMessage = ""
    var response: JSONDictionary?
    
    do {
      response = try JSONSerialization.jsonObject(with: data, options: []) as? JSONDictionary
    } catch let parseError as NSError {
      errorMessage += "JSONSerialization error: \(parseError.localizedDescription)\n"
      return (tracks, errorMessage)
    }
    
    guard let array = response!["results"] as? [Any] else {
      errorMessage += "Dictionary does not contain results key\n"
      return (tracks, errorMessage)
    }
    
    var index = 0
    for trackDictionary in array {
      if let trackDictionary = trackDictionary as? JSONDictionary,
        let previewURLString = trackDictionary["previewUrl"] as? String,
        let previewURL = URL(string: previewURLString),
        let name = trackDictionary["trackName"] as? String,
        let artist = trackDictionary["artistName"] as? String,
        let artworkUrl100 = trackDictionary["artworkUrl100"] as? String,
        let artworkUrl = artworkUrl100.getURL300() {
        tracks.append(Track(name: name, artist: artist, previewURL: previewURL, index: index, artworkUrl: artworkUrl))
          index += 1
      } else {
        errorMessage += "Problem parsing trackDictionary\n"
      }
    }
    
    return (tracks, errorMessage)
  }
}
