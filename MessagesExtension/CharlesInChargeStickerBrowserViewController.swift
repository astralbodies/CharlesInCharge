//
//  CharlesInChargeStickerBrowserVC.swift
//  CharlesInCharge
//
//  Created by Aaron Douglas on 1/8/17.
//  Copyright © 2017 Automattic Inc. All rights reserved.
//

import UIKit
import Messages

protocol ActivityIndicatorViewDelegate {
    func startAnimating()
    func stopAnimating()
}

class CharlesInChargeStickerBrowserViewController: MSStickerBrowserViewController {
    var stickers = [MSSticker]()
    var activityIndicatorViewDelegate: ActivityIndicatorViewDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        let charlesInChargeService = CharlesInChargeService()
        charlesInChargeService.findAndDownloadImages { (searchResults) in
            self.stickers = searchResults.flatMap({ (searchResult) -> MSSticker? in
                return try? MSSticker(contentsOfFileURL: searchResult.thumbnailUrl, localizedDescription: searchResult.title)
            })

            self.activityIndicatorViewDelegate?.stopAnimating()
            self.stickerBrowserView.reloadData()
        }

        activityIndicatorViewDelegate?.startAnimating()
    }

    override func numberOfStickers(in stickerBrowserView: MSStickerBrowserView) -> Int {
        return stickers.count
    }

    override func stickerBrowserView(_ stickerBrowserView: MSStickerBrowserView, stickerAt index: Int) -> MSSticker {
        return stickers[index]
    }
}
