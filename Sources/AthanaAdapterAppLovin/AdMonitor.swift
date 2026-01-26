import Foundation
import AppLovinSDK
import AthanaCore

class CommonAdListener: NSObject, MAAdDelegate {
    
    private let type: Int
    private let maxRetryAttempt: Int
    private let reload: (() -> Void)?
    private let onHidden: (() -> Void)?
    public var retryAttempt = 0.0
    
    private var preloadAd: ProxyAd? = nil
    
    public var listener: AdServiceListener? = nil
    
    public init(type: Int,
                maxRetryAttempt: Int = 4,
                reload: (() -> Void)? = nil,
                onHidden: (() -> Void)? = nil) {
        self.type = type
        self.maxRetryAttempt = maxRetryAttempt
        self.reload = reload
        self.onHidden = onHidden
    }
    
    func onPreLoaded() {
        if let ad = preloadAd {
            listener?.onLoaded(ad: ad)
        }
    }
    
    func didLoad(_ ad: MAAd) {
        retryAttempt = 0.0
        let proxyAd = ad.toProxyAd()
        listener?.onLoaded(ad: proxyAd)
        if (listener == nil) {
            preloadAd = proxyAd
        }
    }

    func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) {
        retryAttempt+=1
        if (Int(retryAttempt) == maxRetryAttempt) {
            listener?.onLoadFailed(ad: error.toProxyAd(adUnitId: adUnitIdentifier, type: type), error: error.toAdError())
            return
        }
        let delaySec = pow(2.0, min(6.0, retryAttempt))
        DispatchQueue.main.asyncAfter(deadline: .now() + delaySec) {
            self.onHidden?()
        }
    }

    func didDisplay(_ ad: MAAd) {
        listener?.onDisplayed(ad: ad.toProxyAd())
    }

    func didHide(_ ad: MAAd) {
        onHidden?()
        listener?.onClosed(ad: ad.toProxyAd())
    }

    func didClick(_ ad: MAAd) {
        listener?.onClick(ad: ad.toProxyAd())
    }

    func didFail(toDisplay ad: MAAd, withError error: MAError) {
        reload?()
        listener?.onDisplayFailed(ad: ad.toProxyAd(), error: error.toAdError())
    }
    
}

class RewardedAdListener: NSObject, MARewardedAdDelegate {
    
    private let maxRetryAttempt: Int
    private let reload: (() -> Void)?
    private let onHidden: (() -> Void)?
    public var retryAttempt = 0.0
    
    private var preloadAd: ProxyAd? = nil
    
    public var listener: AdServiceListener? = nil
    
    public init(maxRetryAttempt: Int = 4,
                reload: (() -> Void)? = nil,
                onHidden: (() -> Void)? = nil) {
        self.maxRetryAttempt = maxRetryAttempt
        self.reload = reload
        self.onHidden = onHidden
    }
    
    func onPreLoaded() {
        if let ad = preloadAd {
            listener?.onLoaded(ad: ad)
        }
    }
    
    func didRewardUser(for ad: MAAd, with reward: MAReward) {
        listener?.onRewarded(ad: ad.toProxyAd())
    }

    func didLoad(_ ad: MAAd) {
        retryAttempt = 0.0
        let proxyAd = ad.toProxyAd()
        listener?.onLoaded(ad: proxyAd)
        if (listener == nil) {
            preloadAd = proxyAd
        }
    }

    func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) {
        retryAttempt+=1
        if (Int(retryAttempt) == maxRetryAttempt) {
            listener?.onLoadFailed(ad: error.toProxyAd(adUnitId: adUnitIdentifier, type: 1), error: error.toAdError())
            return
        }
        let delaySec = pow(2.0, min(6.0, retryAttempt))
        DispatchQueue.main.asyncAfter(deadline: .now() + delaySec) {
            self.onHidden?()
        }
    }

    func didDisplay(_ ad: MAAd) {
        listener?.onDisplayed(ad: ad.toProxyAd())
    }

    func didHide(_ ad: MAAd) {
        onHidden?()
        listener?.onClosed(ad: ad.toProxyAd())
    }

    func didClick(_ ad: MAAd) {
        listener?.onClick(ad: ad.toProxyAd())
    }

    func didFail(toDisplay ad: MAAd, withError error: MAError) {
        reload?()
        listener?.onDisplayFailed(ad: ad.toProxyAd(), error: error.toAdError())
    }
}

extension MAAdFormat {
    func toType() -> Int {
        switch(self) {
        case MAAdFormat.rewarded:
            return 1
        case MAAdFormat.banner:
            return 2
        case MAAdFormat.native:
            return 3
        case MAAdFormat.interstitial:
            return 4
        case MAAdFormat.appOpen:
            return 5
        case MAAdFormat.mrec:
            return 6
        default:
            return 0
        }
    }
}

extension Int {
    func adTypeToClassify() -> Int {
        if ([1, 4, 5].contains(self)) {
            return 1
        } else if (2 == self) {
            return 2
        } else {
            return 0
        }
    }
}

extension MAAd {
    
    func toProxyAd() -> ProxyAd {
        let adType = self.format.toType()
        return ProxyAd(
            type: adType,
            classify: adType.adTypeToClassify(),
            platform: "Max",
            source: self.networkName,
            adUnitId: self.adUnitIdentifier,
            placement: self.placement,
            currency: "USD",
            revenue: self.revenue,
            revenuePrecision: self.revenuePrecision
        )
    }
    
}

extension MAError {
    
    func toProxyAd(adUnitId: String, type: Int, placement: String? = nil) -> ProxyAd {
        let waterfall = self.waterfall
        var mediatedNetwork = ""
        if (waterfall != nil) {
            let size = waterfall?.networkResponses.count ?? 0
            if (size > 0) {
                let nr = waterfall!.networkResponses.first
                if (nr != nil) {
                    let mn = nr!.mediatedNetwork
                    mediatedNetwork = mn.name
                }
            }
        }
        return ProxyAd(
            type: type,
            classify: type.adTypeToClassify(),
            platform: "Max",
            source: mediatedNetwork,
            adUnitId: adUnitId,
            placement: placement,
            currency: "USD",
            revenue: 0.0,
            revenuePrecision: nil
        )
    }
    
    func toAdError() -> AdError {
        return AdError(
            code: self.code.rawValue,
            message: self.message,
            networkErrorCode: self.mediatedNetworkErrorCode,
            networkErrormessage: self.mediatedNetworkErrorMessage
        )
    }
}
