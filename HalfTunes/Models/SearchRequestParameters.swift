
import Foundation

struct SearchRequestParameters: Encodable {
  let media: String
  let entity: String
  let term: String
}
