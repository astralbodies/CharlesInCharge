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

class CharlesInChargeService {
  func findAndDownloadImages(completion: @escaping ([CharlesImageResult]) -> Void) {
    let bingSearchService = BingImageSearchService(subscriptionKey: "ff9111f55f2c4454b1b4135533e1b3a0")

    bingSearchService.search(imagesNamed: "Charles in Charge") { (bingSearchResults) in
      guard bingSearchResults.count > 0 else {
        completion([])
        return
      }

      let imageDownloadService = ImageDownloadService()
      imageDownloadService.deletePreviouslyDownloadedImages()

      let dispatchGroup = DispatchGroup()

      var charlesInChargeImages = [CharlesImageResult]()
      bingSearchResults.forEach({ (searchResult) in
        dispatchGroup.enter()

        imageDownloadService.download(imageUrl: searchResult.thumbnailUrl, completion: { (filename) in
          defer {
            dispatchGroup.leave()
          }

          guard let filename = filename else {
            return
          }

          let thumbnailSize = CharlesImageResult.ThumbnailSize(width: searchResult.thumbnailSize.width, height: searchResult.thumbnailSize.height)
          let charlesImageResult = CharlesImageResult(thumbnailSize: thumbnailSize, thumbnailUrl: URL(fileURLWithPath: filename), title: searchResult.title)
          charlesInChargeImages.append(charlesImageResult)
        })
      })

      let queue = DispatchQueue.main
      dispatchGroup.notify(queue: queue) {
        completion(charlesInChargeImages)
      }
    }
  }

  struct CharlesImageResult {
    let thumbnailSize: ThumbnailSize
    let thumbnailUrl: URL
    let title: String

    struct ThumbnailSize {
      public let width: Float
      public let height: Float
    }
  }
}
