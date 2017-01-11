import Foundation
import Alamofire

final class BingImageSearchService {
    let subscriptionKey: String

    init(subscriptionKey: String) {
        self.subscriptionKey = subscriptionKey
    }

    func search(imagesNamed query: String, completion: @escaping ([SearchResult]) -> Void) {
        Alamofire.request("https://api.cognitive.microsoft.com/bing/v5.0/images/search",
                          method: .get,
                          parameters: ["q": query],
                          headers: ["Ocp-Apim-Subscription-Key": subscriptionKey])
        .validate()
        .responseJSON { (response) in
            guard response.result.isSuccess,
                let json = response.result.value as? [String: Any],
                let searchResultHits = json["value"] as? [[String: Any]] else {
                    completion([SearchResult]())
                    return
            }

            let searchResults = searchResultHits.flatMap({ (hit) -> SearchResult? in
                guard let title = hit["name"] as? String,
                    let fullSizeUrlString = hit["contentUrl"] as? String,
                    let fullSizeUrl = URL(string: fullSizeUrlString),
                    let thumbnailUrlString = hit["thumbnailUrl"] as? String,
                    let thumbnailUrl = URL(string: thumbnailUrlString),
                    let thumbnailSizes = hit["thumbnail"] as? [String: Any],
                    let thumbnailWidth = thumbnailSizes["width"] as? Float,
                    let thumbnailHeight = thumbnailSizes["height"] as? Float else {
                        return nil
                }

                let thumbnailSize = SearchResult.ThumbnailSize(width: thumbnailWidth, height: thumbnailHeight)

                return SearchResult(thumbnailSize: thumbnailSize,
                    thumbnailUrl: thumbnailUrl,
                    fullSizeUrl: fullSizeUrl,
                    title: title)
            })

            print("Bing search result count: \(searchResults.count)")

            completion(searchResults)
        }
    }

    struct SearchResult {
        let thumbnailSize: ThumbnailSize
        let thumbnailUrl: URL
        let fullSizeUrl: URL
        let title: String

        struct ThumbnailSize {
            public let width: Float
            public let height: Float
        }
    }
}
