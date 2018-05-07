//
//  ProxyConfig.swift
//  V2ray-X
//
//  Created by LEI on 2018/5/4.
//  Copyright © 2018年 LEI. All rights reserved.
//

import Foundation
import SystemConfiguration

class ProxyUtil: NSObject {
    
    static let shared: ProxyUtil = ProxyUtil()
    
    private var authRef: AuthorizationRef?
    
    override init() {
        let error = AuthorizationCreate(nil, nil, [], &authRef)
        assert(error == errAuthorizationSuccess)
    }
    
    func setProxy(mode: proxyMode, pacUrl: String, globalHost: String, globalPort: Int) {
        
        // set system proxy
        let prefRef = SCPreferencesCreateWithAuthorization(nil, "systemProxySet" as CFString, nil, self.authRef)!
        let sets = SCPreferencesGetValue(prefRef, kSCPrefNetworkServices)!
        
        var proxies = [NSObject: AnyObject]()
        
        proxies[kCFNetworkProxiesHTTPEnable] = 0 as NSNumber
        proxies[kCFNetworkProxiesHTTPSEnable] = 0 as NSNumber
        proxies[kCFNetworkProxiesProxyAutoConfigEnable] = 0 as NSNumber
        proxies[kCFNetworkProxiesSOCKSEnable] = 0 as NSNumber
        // proxy enabled set
        if (mode == proxyMode.pac){
            log.info("Set proxy mode pac with \(pacUrl)")
            proxies[kCFNetworkProxiesProxyAutoConfigEnable] = 1 as NSNumber
            proxies[kCFNetworkProxiesProxyAutoConfigURLString] = pacUrl as NSString
        } else if (mode == proxyMode.global){
            log.info("Set proxy mode global to \(globalHost):\(globalPort)")
            proxies[kCFNetworkProxiesSOCKSEnable] = 1 as NSNumber
            proxies[kCFNetworkProxiesSOCKSProxy] = globalHost as AnyObject?
            proxies[kCFNetworkProxiesSOCKSPort] = globalPort as NSNumber
            proxies[kCFNetworkProxiesExcludeSimpleHostnames] = 1 as NSNumber
        }
        
        sets.allKeys!.forEach { (key) in
            let dict = sets.object(forKey: key)!
            let hardware = (dict as AnyObject).value(forKeyPath: "Interface.Hardware")
            
            if hardware != nil && ["AirPort","Wi-Fi","Ethernet"].contains(hardware as! String) {
                SCPreferencesPathSetValue(prefRef, "/\(kSCPrefNetworkServices)/\(key)/\(kSCEntNetProxies)" as CFString, proxies as CFDictionary)
            }
        }
        
        // commit to system preferences.
        let commitRet = SCPreferencesCommitChanges(prefRef)
        let applyRet = SCPreferencesApplyChanges(prefRef)
        SCPreferencesSynchronize(prefRef)
        
        if commitRet && applyRet {
            log.info("Proxy preferences changed")
        }
    }
    
    func removeProxy() {
        log.info("Remove system proxy")
        setProxy(mode: proxyMode.none, pacUrl: "", globalHost: "", globalPort: 0)
    }
    
    func setPacProxy() {
        setProxy(mode: proxyMode.pac, pacUrl: "http://127.0.0.1:\(DefaultsUtil.shared.getPacPort())\(DefaultsUtil.shared.getPacPath())", globalHost: "", globalPort: 0)
    }
    
    func setGlobalProxy() {
        setProxy(mode: proxyMode.global, pacUrl: "", globalHost: "127.0.0.1", globalPort: DefaultsUtil.shared.getGlobalPort())
    }
    
}

