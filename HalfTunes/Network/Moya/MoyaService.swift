
import Foundation
import Moya

enum MoyaService {
  case getSearch(searchTerm: String)
}

extension MoyaService: TargetType {
  var baseURL: URL {
    return URL(string: APIConstants.baseURL)!
  }
  
  var path: String {
    switch self {
    case .getSearch:
      return ""
    }
  }
  
  var method: Moya.Method {
    switch self {
    case .getSearch:
      return .get
    }
  }
  
  var task: Task {
    switch self {
    case let .getSearch(searchTerm):
      var params = [String : Any]()
      params[APIConstants.nameMedia] = APIConstants.valueMusic
      params[APIConstants.nameEntity] = APIConstants.valueSong
      params[APIConstants.nameTerm] = searchTerm
      
      return .requestParameters(parameters: params, encoding: URLEncoding.queryString)
    }
  }
  
  var sampleData: Data {
    return Data()
  }

  var headers: [String : String]? {
    return ["Content-type": "application/json"]
  }
  
}
