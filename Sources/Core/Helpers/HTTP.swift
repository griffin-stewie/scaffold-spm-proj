import Foundation

/// Simple HTTP Client
public struct HTTP {

    /// GET request
    /// - Parameters:
    ///   - url: URL
    ///   - completionHandler: completion handler
    public static func get(url: URL, completionHandler: @escaping (Result<Data, Error>) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { (taskData, _, error) in
            if error != nil {
                completionHandler(.failure(error!))
            } else {
                completionHandler(.success(taskData!))
            }
        }
        task.resume()
    }

    /// Download
    /// - Parameters:
    ///   - url: URL
    ///   - destination: Where to save the downloaded data
    ///   - overwrite: overwrite if exists
    ///   - completionHandler: completion handler
    public static func download(url: URL, to destination: URL, overwrite: Bool = true, completionHandler: @escaping (Result<URL, Error>) -> Void) {
        let task = URLSession.shared.downloadTask(with: url) { (downloadedURL, _, error) in
            if error != nil {
                completionHandler(.failure(error!))
            } else {
                do {
                    let fs = FileManager.default
                    if overwrite {
                        try fs.removeItemIfExists(at: destination)
                    }
                    try fs.copyItem(at: downloadedURL!, to: destination)
                } catch (let e) {
                    completionHandler(.failure(e))
                }
                completionHandler(.success(destination))
            }
        }
        task.resume()
    }
}
