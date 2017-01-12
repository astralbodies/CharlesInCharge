//
//  CharlesInChargeService.swift
//  CharlesInCharge
//
//  Created by Aaron Douglas on 1/9/17.
//  Copyright © 2017 Automattic Inc. All rights reserved.
//

import Foundation

class CharlesInChargeService {
    func findAndDownloadImages(completion: @escaping ([CharlesImageResult]) -> Void) {
        let bingSearchService = BingImageSearchService(subscriptionKey: "")

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
