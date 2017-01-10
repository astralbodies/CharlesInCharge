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

    override func numberOfStickers(in stickerBrowserView: MSStickerBrowserView) -> Int {
        return stickers.count
    }

    override func stickerBrowserView(_ stickerBrowserView: MSStickerBrowserView, stickerAt index: Int) -> MSSticker {
        return stickers[index]
    }
}
