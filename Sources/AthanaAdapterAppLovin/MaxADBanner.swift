//
//  ADBannerMax.swift
//  Athana
//
//  Created by CWJoy on 2025/7/28.
//

import AppLovinSDK
import AthanaCore
import Foundation
import UIKit

class MaxADBanner: NSObject, MAAdViewAdDelegate, AdBanner {

    final let adUnitId: String
    private var size: AdSize
    private var alignment: AdAlignment

    private var adView: MAAdView?

    var listener: AdServiceListener? = nil

    init(
        adUnitId: String,
        placement: String?,
        size: AdSize,
        alignment: AdAlignment
    ) {
        self.adUnitId = adUnitId
        self.size = size
        self.alignment = alignment

        let config = MAAdViewConfiguration { builder in
            builder.adaptiveType = .anchored
        }
        self.adView = MAAdView(
            adUnitIdentifier: adUnitId,
            adFormat: MAAdFormat.banner,
            configuration: config
        )
        self.adView?.placement = placement
    }

    /// 展示
    func show() throws {
        let width =
            size.width <= 0 ? UIScreen.main.bounds.width : Double(size.width)
        let height =
            size.height <= 0
            ? MAAdFormat.banner.adaptiveSize(forWidth: Double(size.width))
                .height : Double(size.height)
        let y: Double =
            switch alignment {
            case .TOP_START, .TOP_CENTER, .TOP_END:
                kStatusBarHeight()
            case .BOTTOM_START, .BOTTOM_CENTER, .BOTTOM_END:
                UIScreen.main.bounds.height - height
            }

        let userId = PlatformService.shared.dataRepository().getUserId()
        if userId != nil {
            adView?.customData = String(userId!)
        } else {
            adView?.customData = nil
        }

        adView?.backgroundColor = .clear
        adView?.delegate = self
        adView?.frame = CGRect(x: 0.0, y: y, width: width, height: height)

        let viewController = UIApplication.shared.topViewController()
        if viewController != nil {
            viewController?.view?.addSubview(self.adView!)
            adView?.loadAd()
        } else {
            throw BannerCreateException(
                "Failed to craete Banner. Cannot to add View"
            )
        }
    }

    /// 隐藏
    func hide() {
        adView?.delegate = nil
        adView?.removeFromSuperview()
    }

    /// 更新尺寸
    func updateSize(_ size: AdSize) {
        self.size = size
        adView?.frame.size.width =
            (size.width <= 0 ? UIScreen.main.bounds.width : Double(size.width))
        adView?.frame.size.height =
            (size.height <= 0
                ? MAAdFormat.banner.adaptiveSize(forWidth: Double(size.height))
                    .height : Double(size.height))
    }

    /// 更新位置
    func updateAlignment(_ alignment: AdAlignment) {
        self.alignment = alignment
        if adView == nil {
            return
        }
        let height =
            (size.height <= 0
                ? MAAdFormat.banner.adaptiveSize(forWidth: Double(size.height))
                    .height : Double(size.height))
        let y: Double =
            switch alignment {
            case .TOP_START, .TOP_CENTER, .TOP_END:
                kStatusBarHeight()
            case .BOTTOM_START, .BOTTOM_CENTER, .BOTTOM_END:
                UIScreen.main.bounds.height - height
            }
        adView?.frame.origin.y = y
    }

    /// 销毁
    func destroy() {
        adView?.removeFromSuperview()
        adView?.delegate = nil
        adView = nil
        listener = nil
    }

    func didExpand(_ ad: MAAd) {

    }

    func didCollapse(_ ad: MAAd) {

    }

    func didLoad(_ ad: MAAd) {
        listener?.onLoaded(ad: ad.toProxyAd())
    }

    func didFailToLoadAd(
        forAdUnitIdentifier adUnitIdentifier: String,
        withError error: MAError
    ) {
        listener?.onLoadFailed(
            ad: error.toProxyAd(adUnitId: adUnitIdentifier, type: 2),
            error: error.toAdError()
        )
    }

    func didDisplay(_ ad: MAAd) {
        listener?.onDisplayed(ad: ad.toProxyAd())
    }

    func didHide(_ ad: MAAd) {
        listener?.onClosed(ad: ad.toProxyAd())
    }

    func didClick(_ ad: MAAd) {
        listener?.onClick(ad: ad.toProxyAd())
    }

    func didFail(toDisplay ad: MAAd, withError error: MAError) {
        listener?.onDisplayFailed(ad: ad.toProxyAd(), error: error.toAdError())
    }
}
