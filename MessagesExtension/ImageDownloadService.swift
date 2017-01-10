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
        let documentsURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask)[0]

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

    func download(imageUrl url: URL, completion: (_ filename: String?) -> Void) {
        Alamofire.download(url, to: destination)
            .validate()
            .response { response in
                print(response)

                if response.error == nil, let imagePath = response.destinationURL?.path {
                    let image = UIImage(contentsOfFile: imagePath)
                }
        }
    }
}
