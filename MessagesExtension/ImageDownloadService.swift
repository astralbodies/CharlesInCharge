//
//  ImageDownloadService.swift
//  CharlesInCharge
//
//  Created by Aaron Douglas on 1/8/17.
//  Copyright © 2017 Automattic Inc. All rights reserved.
//

import Foundation
import Alamofire
import UIKit

class ImageDownloadService {
    let destination: DownloadRequest.DownloadFileDestination = { url, response in
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]

        let fileExtension: String = {
            guard let mimeType = response.mimeType else {
                return ""
            }

            switch mimeType {
            case "image/jpeg":
                return "jpg"
            case "image/png":
                return "png"
            default:
                return ""
            }
        }()

        let filename = UUID().uuidString
        let fileURL = documentsURL.appendingPathComponent("\(filename).\(fileExtension)")

        return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
    }

    func download(imageUrl url: URL, completion: @escaping (_ filename: String?) -> Void) {
        Alamofire.download(url, to: destination)
            .validate()
            .responseData { response in
                guard response.result.isSuccess,
                    let imagePath = response.destinationURL?.path else {
                        completion(nil)
                        return
                }

                completion(imagePath)
        }
    }

    func deletePreviouslyDownloadedImages() {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]

        guard let contents = try? fileManager.contentsOfDirectory(atPath: documentsURL.path) else {
            return
        }

        contents.forEach({ (item) in
            try? fileManager.removeItem(atPath: documentsURL.appendingPathComponent(item).path)
        })
    }
}
