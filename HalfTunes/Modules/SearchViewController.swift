
import AVFoundation
import AVKit
import Kingfisher
import PKHUD
import UIKit

enum RequestType {
  case urlSession
  case alamofire
  case moya
}

class SearchViewController: UIViewController {

  @IBOutlet private weak var tableView: UITableView!
  @IBOutlet private weak var searchBar: UISearchBar!
    
  private let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
  private let downloadService = DownloadService()
  private let queryService = QueryService()
  private let afService = AlamofireService()
  private let moyaManager = MoyaManager()
  private let tintColor = UIColor(named: "colorTint")
  
  private lazy var downloadsSession: URLSession = {
    let configuration = URLSessionConfiguration.background(withIdentifier: SessionConstants.sessionBgId)
    
    return URLSession(configuration: configuration,
                      delegate: self,
                      delegateQueue: nil)
  }()
  
  private var searchResults: [Track] = []
  private var requestType: RequestType = .urlSession
  
  private lazy var tapRecognizer: UITapGestureRecognizer = {
    var recognizer = UITapGestureRecognizer(target:self, action: #selector(dismissKeyboard))
    return recognizer
  }()
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.tableFooterView = UIView()
    downloadService.downloadsSession = downloadsSession
  }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()

    setupSearchBar()
  }

  // MARK: - Setup
  private func setupSearchBar() {
    searchBar.searchTextField.leftView?.tintColor = .purple
    
    // set customization to viewWillLayoutSubviews or later methods
    if let clearButton = searchBar.searchTextField.value(forKey: "_clearButton") as? UIButton {
// for clear button use image:
//      clearButton.setImage(UIImage(named: "icClear"), for: .normal)
// or system with tint:
      clearButton.setImage(UIImage(systemName: "clear"), for: .normal)
      clearButton.tintColor = .purple
    }
  }
  
  func position(for bar: UIBarPositioning) -> UIBarPosition {
    return .topAttached
  }
  
  // MARK: - Actions
  @objc func dismissKeyboard() {
    searchBar.resignFirstResponder()
  }
    
  @IBAction func tappedSegment(_ sender: UISegmentedControl) {
    switch sender.selectedSegmentIndex {
    case 0:
      requestType = .urlSession
    case 1:
      requestType = .alamofire
    case 2:
      requestType = .moya
    default:
      break
    }
  }
      
  // MARK: - Logic
  private func getImageViewForPlayer(_ artworkUrl: URL) -> UIImageView {
    
    let imageView = UIImageView()
    imageView.backgroundColor = .lightGray
    imageView.layer.masksToBounds = true
    imageView.layer.cornerRadius = 20.0
    imageView.kf.indicatorType = .activity // or use placeholder image
    imageView.kf.setImage(with: artworkUrl)//, placeholder: UIImage(named: "rwdevcon-bg"))
    
    let x = Sizes.screenWidth / 2 - Sizes.imageWidth / 2
    let y = Sizes.screenHeight / 2 - Sizes.imageWidth / 2
    imageView.frame = CGRect(x: x, y: y, width: Sizes.imageWidth, height: Sizes.imageWidth)
    
    return imageView
  }
  
  private func localFilePath(for url: URL) -> URL {
    return documentsPath.appendingPathComponent(url.lastPathComponent)
  }
  
  private func playDownload(_ track: Track) {
    let playerViewController = AVPlayerViewController()
    present(playerViewController, animated: true, completion: nil)
    
    let url = localFilePath(for: track.previewURL)
    let player = AVPlayer(url: url)
  
    do {
        try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
       }
       catch {
          print("\n LOG Setting setCategory to AVAudioSessionCategoryPlayback failed.")
          return
     }
    playerViewController.player = player
    playerViewController.contentOverlayView?.addSubview(getImageViewForPlayer(track.artworkUrl))
    playerViewController.contentOverlayView?.backgroundColor = tintColor
    player.play()
  }
  
  private func reload(_ row: Int) {
    tableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .none)
  }
  
  private func showResult(_ results: [Track], _ errorMessage: String) {
    HUD.hide()
    searchResults = results
    tableView.reloadData()
    tableView.setContentOffset(.zero, animated: false)
    
    if !errorMessage.isEmpty {
      print("\n LOG Search error: \n" + errorMessage)
    }
  }
  
  // MARK: - APICalls
  private func getUrlSessionSearchResult(searchTerm: String) {
    print("\n LOG UrlSession request")
    queryService.getSearchResults(searchTerm: searchTerm) { [weak self] results, errorMessage in
      self?.showResult(results, errorMessage)
    }
  }
  
  private func getAlamofireSearchResult(searchTerm: String) {
    print("\n LOG Alamofire request")
    afService.getSearchResults(searchTerm: searchTerm) { [weak self] results, errorMessage in
      self?.showResult(results, errorMessage)
    }
  }
  
  private func getMoyaSearchResult(searchTerm: String) {
    print("\n LOG Moya request")
    moyaManager.getSearchResults(searchTerm: searchTerm) { [weak self] results, errorMessage  in
      self?.showResult(results, errorMessage)
    }
  }
  
}

// MARK: - Extentions



// MARK: - UISearchBarDelegate
extension SearchViewController: UISearchBarDelegate {
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    dismissKeyboard()
    
    guard let searchText = searchBar.text, !searchText.isEmpty else {
      return
    }
    
    HUD.show(.systemActivity)
    switch requestType {
    case .urlSession:
      getUrlSessionSearchResult(searchTerm: searchText)
    case .alamofire:
      getAlamofireSearchResult(searchTerm: searchText)
    case .moya:
      getMoyaSearchResult(searchTerm: searchText)
    }
  }
  
  func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
    view.addGestureRecognizer(tapRecognizer)
  }

  func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
    view.removeGestureRecognizer(tapRecognizer)
  }
}

// MARK: - Table View Data Source
extension SearchViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell: TrackCell = tableView.dequeueReusableCell(withIdentifier: TrackCell.identifier, for: indexPath) as! TrackCell
    // Delegate cell button tap events to this view controller.
    cell.delegate = self
    
    let track = searchResults[indexPath.row]
    cell.configure(track: track,
                   downloaded: track.downloaded,
                   download: downloadService.activeDownloads[track.previewURL])
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return searchResults.count
  }
}

// MARK: - Table View Delegate
extension SearchViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    //When user taps cell, play the local file, if it's downloaded.
    
    let track = searchResults[indexPath.row]
    
    if track.downloaded {
      playDownload(track)
    }
    
    tableView.deselectRow(at: indexPath, animated: true)
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 62.0
  }
}

// MARK: - Track Cell Delegate
extension SearchViewController: TrackCellDelegate {
  func cancelTapped(_ cell: TrackCell) {
    if let indexPath = tableView.indexPath(for: cell) {
      let track = searchResults[indexPath.row]
      downloadService.cancelDownload(track)
      reload(indexPath.row)
    }
  }
  
  func downloadTapped(_ cell: TrackCell) {
    if let indexPath = tableView.indexPath(for: cell) {
      let track = searchResults[indexPath.row]
      downloadService.startDownload(track)
      reload(indexPath.row)
    }
  }
  
  func pauseTapped(_ cell: TrackCell) {
    if let indexPath = tableView.indexPath(for: cell) {
      let track = searchResults[indexPath.row]
      downloadService.pauseDownload(track)
      reload(indexPath.row)
    }
  }
  
  func resumeTapped(_ cell: TrackCell) {
    if let indexPath = tableView.indexPath(for: cell) {
      let track = searchResults[indexPath.row]
      downloadService.resumeDownload(track)
      reload(indexPath.row)
    }
  }
}

// MARK: - URLSessionDelegate
extension SearchViewController: URLSessionDelegate {
  func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
    DispatchQueue.main.async {
      if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
        let completionHandler = appDelegate.backgroundSessionCompletionHandler {
        appDelegate.backgroundSessionCompletionHandler = nil
        
        completionHandler()
      }
    }
  }
}

// MARK: - URLSessionDownloadDelegate
extension SearchViewController: URLSessionDownloadDelegate {
  func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                  didFinishDownloadingTo location: URL) {
    print("\n LOG Finished downloading to \(location).")

    guard let sourceURL = downloadTask.originalRequest?.url else {
      return
    }

    let download = downloadService.activeDownloads[sourceURL]
    downloadService.activeDownloads[sourceURL] = nil
  
    let destinationURL = localFilePath(for: sourceURL)
    print(" LOG destinationURL: ", destinationURL)
 
    let fileManager = FileManager.default
    try? fileManager.removeItem(at: destinationURL)

    do {
      try fileManager.copyItem(at: location, to: destinationURL)
      download?.track.downloaded = true
    } catch let error {
      print(" LOG Could not copy file to disk: \(error.localizedDescription)")
    }
    // 4
    if let index = download?.track.index {
      DispatchQueue.main.async { [weak self] in
        self?.tableView.reloadRows(at: [IndexPath(row: index, section: 0)],
                                   with: .none)
      }
    }
  }
  
  func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64, totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {
    guard let url = downloadTask.originalRequest?.url,
          let download = downloadService.activeDownloads[url]
      else {
        return
    }

    download.progress =
      Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
    let totalSize =
      ByteCountFormatter.string(fromByteCount: totalBytesExpectedToWrite,
                                countStyle: .file)
    DispatchQueue.main.async {
      if let trackCell =
        self.tableView.cellForRow(at: IndexPath(row: download.track.index,
                                                section: 0)) as? TrackCell {
        trackCell.updateDisplay(progress: download.progress,
                                totalSize: totalSize)
      }
    }
  }
}
