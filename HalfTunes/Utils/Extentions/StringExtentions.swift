
import Foundation

extension String {
  func getURL300() -> URL? {
    let intSize = Int(Sizes.imageWidth)
    let string300 = self.replacingOccurrences(of: "100x100bb", with: "\(intSize)x\(intSize)bb")
    return URL(string: string300)
  }
}
