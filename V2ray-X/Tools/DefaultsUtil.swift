//
//  DefaultsUtil.swift
//  V2ray-X
//
//  Created by LEI on 2018/5/5.
//  Copyright © 2018年 LEI. All rights reserved.
//

import Foundation

class DefaultsUtil: NSObject {
    
    static let shared: DefaultsUtil = DefaultsUtil()
    
    private let defaults = UserDefaults.standard
    
    private let Kon = "V2ray-XOn"
    private let Kmode = "ProxyMode"
    private let KpacPort = "PacPort"
    private let KpacPath = "PacPath"
    private let KglobalPort = "GlobalPort"
    
    override init() {
        defaults.register(defaults: [
            Kon: false,
            Kmode: "pac",
            KpacPort: 1086,
            KpacPath: "/proxy.pac",
            KglobalPort: 1080,
            ])
    }
    
    func getOn() -> Bool {
        return defaults.bool(forKey: Kon)
    }
    
    func setOn(on: Bool) {
        defaults.set(on, forKey: Kon)
    }
    
    func getMode() -> String {
        if let m = defaults.string(forKey: Kmode) {
            return m
        } else {
            return "none"
        }
    }
    
    func setMode(mode: String) {
        defaults.set(mode, forKey: Kmode)
    }
    
    func getPacPort() -> Int {
        return defaults.integer(forKey: KpacPort)
    }
    
    func setPacPort(port: Int) {
        defaults.set(port, forKey: KpacPort)
    }
    
    func getPacPath() -> String {
        if let p = defaults.string(forKey: KpacPath) {
            return p
        } else {
            return "/proxy.pac"
        }
    }
    
    func getGlobalPort() -> Int {
        return defaults.integer(forKey: KglobalPort)
    }
    
    func setGlobalPort(port: Int) {
        defaults.set(port, forKey: KglobalPort)
    }
    
}
