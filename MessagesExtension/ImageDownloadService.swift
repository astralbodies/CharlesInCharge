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
