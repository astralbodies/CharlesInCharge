//
//  CharlesInChargeService.swift
//  CharlesInCharge
//
//  Created by Aaron Douglas on 1/9/17.
//  Copyright © 2017 Automattic Inc. All rights reserved.
//

import Foundation

class CharlesInChargeService {
    func findAndDownloadImages(completion: @escaping ([BingImageSearchService.SearchResult]) -> Void) {
        let bingSearchService = BingImageSearchService(subscriptionKey: "fbae700fb0af4546819c51f8585acf8a")

        bingSearchService.search(imagesNamed: "Charles in Charge") { (bingSearchResults) in
            guard bingSearchResults.count > 0 else {
                completion([])
                return
            }

            let imageDownloadService = ImageDownloadService()

//            let dispatchGroup = DispatchGroup()

            bingSearchResults.forEach({ (searchResult) in
//                dispatchGroup.enter()

                imageDownloadService.download(imageUrl: searchResult.thumbnailUrl, completion: { (filename) in
                    print("Downloaded \(filename)")
//                    dispatchGroup.leave()
                })
            })

//            dispatchGroup.wait()

//            completion(bingSearchResults)
        }
    }
}
