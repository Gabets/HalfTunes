import UIKit

struct APIConstants {
  static let baseURL = "https://itunes.apple.com/search"
  static let nameMedia = "media"
  static let nameEntity = "entity"
  static let nameTerm = "term"
  static let valueMusic = "music"  
  static let valueSong = "song"
}

struct SessionConstants {
  static let sessionBgId = "by.gabets.HalfTunes.bgSession"
}

struct Sizes {
  static let screenWidth = UIScreen.main.bounds.width
  static let screenHeight = UIScreen.main.bounds.height
  static let imageWidth = screenWidth - 50
}
