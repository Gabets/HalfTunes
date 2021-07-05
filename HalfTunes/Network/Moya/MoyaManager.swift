
import Foundation
import Moya

class MoyaManager {
  private let loggerConfig = NetworkLoggerPlugin.Configuration(logOptions: .verbose)
  private let provider: MoyaProvider<MoyaService>
  
  init() {
    let networkLogger = NetworkLoggerPlugin(configuration: loggerConfig)
    provider = MoyaProvider<MoyaService>(plugins: [networkLogger])
  }
  
  func getSearchResults(searchTerm: String, completion: @escaping QueryResult) {
    provider.request(.getSearch(searchTerm: searchTerm)) { result in
      var errorMessage = ""
      var queryResults: ([Track], String) = ([], "")
      
      switch result {
      case .success(let successResponse):
        // for experiments
//        print("\n LOG response: \n", successResponse.response.debugDescription)
        let data = successResponse.data
        if let response = successResponse.response,
           response.statusCode == 200 {
          
          queryResults = SearchResultService.updateSearchResults(data)
        } else {
          errorMessage += "Unknown error"
        }
      case .failure(let error):
        print("\n LOG moya error: \n", error.localizedDescription)
        errorMessage += error.localizedDescription
      }
      
      DispatchQueue.main.async {
        completion(queryResults.0, errorMessage + queryResults.1)
      }
      
    }
  }
}
