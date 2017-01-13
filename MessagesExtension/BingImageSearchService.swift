/**
 * Copyright (c) 2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import Foundation
import Alamofire

class BingImageSearchService {
  let subscriptionKey: String

  init(subscriptionKey: String) {
    self.subscriptionKey = subscriptionKey
  }

  func search(imagesNamed query: String, completion: @escaping ([SearchResult]) -> Void) {
    Alamofire.request("https://api.cognitive.microsoft.com/bing/v5.0/images/search",
                      method: .get,
                      parameters: ["q": query, "mkt": "en-US"],
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
