//
//  ServiceUtil.swift
//  V2ray-X
//
//  Created by LEI on 2018/5/5.
//  Copyright © 2018年 LEI. All rights reserved.
//

import Foundation

class ServiceUtil: NSObject {
    
    static var shared = ServiceUtil()
    
    private func runCommand(cmd : String, _ args : String...) -> (output: String, error: String, exitCode: Int32) {
        
        var output: String = ""
        var error: String = ""
        
        let task = Process()
        task.launchPath = cmd
        task.arguments = args
        
        let outpipe = Pipe()
        task.standardOutput = outpipe
        let errpipe = Pipe()
        task.standardError = errpipe
        
        task.launch()
        
        let outdata = outpipe.fileHandleForReading.readDataToEndOfFile()
        if let string = String(data: outdata, encoding: .utf8) {
            output = string.trimmingCharacters(in: .newlines)
        }
        
        let errdata = errpipe.fileHandleForReading.readDataToEndOfFile()
        if let string = String(data: errdata, encoding: .utf8) {
            error = string.trimmingCharacters(in: .newlines)
        }
        
        task.waitUntilExit()
        let status = task.terminationStatus
        
        return (output, error, status)
    }
    
    func startV2ray() {
        let res = runCommand(cmd: "/usr/local/bin/brew", "services", "run", "v2ray-core")
        if (res.exitCode != 0) {
            log.error(res.error)
            log.error("Start v2ray failed")
        } else {
            log.info(res.output)
        }
    }
    
    func stopV2ray() {
        let res = runCommand(cmd: "/usr/local/bin/brew", "services", "stop", "v2ray-core")
        if (res.exitCode != 0) {
            log.error(res.error)
            log.error("Stop v2ray failed")
        } else {
            log.info(res.output)
        }
    }
    
}
