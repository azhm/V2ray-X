//
//  PacUtil.swift
//  V2ray-X
//
//  Created by LEI on 2018/5/5.
//  Copyright © 2018年 LEI. All rights reserved.
//

import Foundation
import Alamofire
import GCDWebServer

class PacUtil: NSObject {
    
    static let shared: PacUtil = PacUtil()
    
    private let PACRulesDirPath: String
    private let PACUserRuleFilePath: String
    private let PACFilePath: String
    private let GFWListFilePath: String
    private let pacUrl = "https://raw.githubusercontent.com/gfwlist/gfwlist/master/gfwlist.txt"
    
    private let server = GCDWebServer()
    
    override init() {
        PACRulesDirPath = NSHomeDirectory() + "/.V2ray-X/"
        PACUserRuleFilePath = PACRulesDirPath + "user-rule.txt"
        PACFilePath = PACRulesDirPath + "gfwlist.js"
        GFWListFilePath = PACRulesDirPath + "gfwlist.txt"
    }
    
    func GeneratePACFile() -> Bool {
        let fileMgr = FileManager.default
        // Maker the dir if rulesDirPath is not exesited.
        if !fileMgr.fileExists(atPath: PACRulesDirPath) {
            try! fileMgr.createDirectory(atPath: PACRulesDirPath, withIntermediateDirectories: true, attributes: nil)
        }
        
        // If gfwlist.txt is not exsited, copy from bundle
        if !fileMgr.fileExists(atPath: GFWListFilePath) {
            let src = Bundle.main.path(forResource: "gfwlist", ofType: "txt")
            try! fileMgr.copyItem(atPath: src!, toPath: GFWListFilePath)
        }
        
        // If user-rule.txt is not exsited, copy from bundle
        if !fileMgr.fileExists(atPath: PACUserRuleFilePath) {
            let src = Bundle.main.path(forResource: "user-rule", ofType: "txt")
            try! fileMgr.copyItem(atPath: src!, toPath: PACUserRuleFilePath)
        }
        
        let socks5Port = DefaultsUtil.shared.getGlobalPort()
        
        do {
            let gfwlist = try String(contentsOfFile: GFWListFilePath, encoding: String.Encoding.utf8)
            if let data = Data(base64Encoded: gfwlist, options: .ignoreUnknownCharacters) {
                let str = String(data: data, encoding: String.Encoding.utf8)
                var lines = str!.components(separatedBy: CharacterSet.newlines)
                
                do {
                    let userRuleStr = try String(contentsOfFile: PACUserRuleFilePath, encoding: String.Encoding.utf8)
                    let userRuleLines = userRuleStr.components(separatedBy: CharacterSet.newlines)
                    
                    lines = userRuleLines + lines
                } catch {
                    log.warning("Not found user-rule.txt")
                }
                
                // Filter empty and comment lines
                lines = lines.filter({ (s: String) -> Bool in
                    if s.isEmpty {
                        return false
                    }
                    let c = s[s.startIndex]
                    if c == "!" || c == "[" {
                        return false
                    }
                    return true
                })
                
                do {
                    // rule lines to json array
                    let rulesJsonData: Data = try JSONSerialization.data(withJSONObject: lines, options: .prettyPrinted)
                    let rulesJsonStr = String(data: rulesJsonData, encoding: String.Encoding.utf8)
                    
                    // Get raw pac js
                    let jsPath = Bundle.main.url(forResource: "abp", withExtension: "js")
                    let jsData = try? Data(contentsOf: jsPath!)
                    var jsStr = String(data: jsData!, encoding: String.Encoding.utf8)
                    
                    // Replace rules placeholder in pac js
                    jsStr = jsStr!.replacingOccurrences(of: "__RULES__", with: rulesJsonStr!)
                    // Replace __SOCKS5PORT__ palcholder in pac js
                    let result = jsStr!.replacingOccurrences(of: "__SOCKS5PORT__", with: "\(socks5Port)")
                    
                    // Write the pac js to file.
                    try result.data(using: String.Encoding.utf8)?.write(to: URL(fileURLWithPath: PACFilePath), options: .atomic)

                    return true
                } catch {
                }
            }
        } catch {
            log.error("Not found gfwlist.txt")
        }
        return false
    }
    
    func updateGFWList() {
        // Make the dir if rulesDirPath is not exesited.
        if !FileManager.default.fileExists(atPath: PACRulesDirPath) {
            do {
                try FileManager.default.createDirectory(atPath: PACRulesDirPath, withIntermediateDirectories: true, attributes: nil)
            } catch {
            }
        }
        Alamofire.request(pacUrl).responseString {
            response in
            if response.result.isSuccess {
                if let v = response.result.value {
                    do {
                        try v.write(toFile: PacUtil.shared.GFWListFilePath, atomically: true, encoding: String.Encoding.utf8)
                        if PacUtil.shared.GeneratePACFile() {
                            // gen pac success
                            
                        } else {
                            // gen pac fail
                            
                        }
                    } catch {
                    }
                }
            } else {
                // response fail
                
            }
        }
    }
    
    func generatePac() {
        if GeneratePACFile() {
            log.info("generated pac file")
        } else {
            log.error("generate pac file error")
        }
    }
    
    func startPacServer() {
        stopPacServer()
        if let data = try? Data(contentsOf: URL(fileURLWithPath: PACFilePath)) {
            log.info("starting pac server...")
            server.addHandler(forMethod: "GET", path: DefaultsUtil.shared.getPacPath(), request: GCDWebServerRequest.self, processBlock: {
                request in
                return GCDWebServerDataResponse(data: data, contentType: "application/x-ns-proxy-autoconfig")
            })
            do {
                try server.start(options: ["Port": DefaultsUtil.shared.getPacPort(), "BindToLocalhost": true])
                log.info("pac server started")
            } catch {
                log.info("pac server start failed")
            }
        }
    }
    
    func stopPacServer() {
        if server.isRunning {
            log.info("stop pac server")
            server.stop()
        }
    }
    
}
