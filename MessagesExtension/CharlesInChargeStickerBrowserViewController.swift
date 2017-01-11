//
//  CharlesInChargeStickerBrowserVC.swift
//  CharlesInCharge
//
//  Created by Aaron Douglas on 1/8/17.
//  Copyright © 2017 Automattic Inc. All rights reserved.
//

import UIKit
import Messages

class CharlesInChargeStickerBrowserViewController: MSStickerBrowserViewController {
    var stickers = [MSSticker]()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let charlesInChargeService = CharlesInChargeService()
        charlesInChargeService.findAndDownloadImages { (searchResults) in
            self.stickers = searchResults.flatMap({ (searchResult) -> MSSticker? in
                return try? MSSticker(contentsOfFileURL: searchResult.thumbnailUrl, localizedDescription: searchResult.title)
            })

            self.stickerBrowserView.reloadData()
        }
    }

    override func numberOfStickers(in stickerBrowserView: MSStickerBrowserView) -> Int {
        return stickers.count
    }

    override func stickerBrowserView(_ stickerBrowserView: MSStickerBrowserView, stickerAt index: Int) -> MSSticker {
        return stickers[index]
    }
}
