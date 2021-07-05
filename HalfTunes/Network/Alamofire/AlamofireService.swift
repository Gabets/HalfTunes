
import Alamofire
import Foundation

final class AlamofireService {
  
  func getSearchResults(searchTerm: String, completion: @escaping QueryResult) {
    
    let parameters = SearchRequestParameters(media: APIConstants.valueMusic,
                                             entity: APIConstants.valueSong,
                                             term: searchTerm)
    
    AF.request(APIConstants.baseURL, parameters: parameters).response { response in
      
      // debug
      print("\n LOG response \n", response.debugDescription)
      var errorMessage = ""
      var queryResults: ([Track], String) = ([], "")
      
      // handle result
      if let error = response.error {
        errorMessage += error.localizedDescription
      } else if let data = response.data,
                let response = response.response,
                response.statusCode == 200 {
        
        queryResults = SearchResultService.updateSearchResults(data)
      } else {
        errorMessage += "Unknown error"
      }
      
      DispatchQueue.main.async {
        completion(queryResults.0, errorMessage + queryResults.1)
      }
    }
  }
}
