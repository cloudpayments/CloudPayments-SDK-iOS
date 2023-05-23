//
//  CloudPaymentsSDK.swift
//  sdk
//
//  Created by a.ignatov on 19.09.2022.
//  Copyright © 2022 Cloudpayments. All rights reserved.
//

import Foundation
import YandexPaySDK

final public class CloudPaymentsSDK {

    private(set) static var yandexPayAppId: String?
    private static var initialized: Bool = false

    public static var instance: CloudPaymentsSDK = {
        guard initialized == true else {
            fatalError("CloudPaymentsSDK should be initialized using initialize(yandexPayAppId:sandboxMode:) method before use")
        }
        return CloudPaymentsSDK()
    }()

    public static func initialize(yandexPayAppId: String?, yandexPaySandboxMode: Bool? = false) throws {
        Self.yandexPayAppId = yandexPayAppId

        let configuration = YandexPaySDKConfiguration(environment: (yandexPaySandboxMode ?? false) ? .sandbox : .production,
                                                      merchant: YandexPaySDKMerchant.init(id: yandexPayAppId ?? "",
                                                                                          name: "Cloud", origin: "https://cp.ru", url: "https://cp.ru"), locale: .ru)
        try YandexPaySDKApi.initialize(configuration: configuration)

        initialized = true
    }

    final public func applicationWillEnterForeground() {
        if Self.yandexPayAppId != nil {
            YandexPaySDKApi.instance.applicationWillEnterForeground()
        }
    }

    final public func applicationDidBecomeActive() {
        if Self.yandexPayAppId != nil {
            YandexPaySDKApi.instance.applicationDidBecomeActive()
        }
    }

    final public func applicationDidReceiveOpen(_ url: URL, sourceApplication: String?) -> Bool {
        if Self.yandexPayAppId != nil {
            return YandexPaySDKApi.instance.applicationDidReceiveOpen(url, sourceApplication: sourceApplication)
        }
        return true
    }

    final public func applicationDidReceiveUserActivity(_ userActivity: NSUserActivity) -> Bool {
        if Self.yandexPayAppId != nil {
            return YandexPaySDKApi.instance.applicationDidReceiveUserActivity(userActivity)
        }
        return true
    }
}
