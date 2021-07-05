import Foundation

final class QueryService {

  // create session from default configuration
  private let defaultSession = URLSession(configuration: .default)
  private var dataTask: URLSessionDataTask?
  
  func getSearchResults(searchTerm: String, completion: @escaping QueryResult) {
    
    //  cancel any data task that already exists
    dataTask?.cancel()
    var errorMessage = ""
    var queryResult: ([Track], String) = ([], "")
    
    if var urlComponents = URLComponents(string: APIConstants.baseURL) {
      urlComponents.queryItems =
        [URLQueryItem(name: APIConstants.nameMedia, value: APIConstants.valueMusic),
         URLQueryItem(name: APIConstants.nameEntity, value: APIConstants.valueSong),
         URLQueryItem(name: APIConstants.nameTerm, value: searchTerm)]
      
      guard let url = urlComponents.url else {
        return
      }

      // create data task
      dataTask =
        defaultSession.dataTask(with: url) { [weak self] data, response, error in
          defer {
            self?.dataTask = nil
          }
          // debug
          print("\n LOG response: \n", response.debugDescription)
            
          // result handle
          if let error = error {
            errorMessage += "DataTask error: " + error.localizedDescription + "\n"
          } else if let data = data,
                    let response = response as? HTTPURLResponse,
                    response.statusCode == 200 {
            
            queryResult = SearchResultService.updateSearchResults(data)
          } else {
            errorMessage += "Unknown error"
          }
          
          DispatchQueue.main.async {
            completion(queryResult.0, queryResult.1)
          }
      }
      
      // start the data task
      dataTask?.resume()
    }
  }
  
}

