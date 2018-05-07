//
//  LogUtil.swift
//  V2ray-X
//
//  Created by LEI on 2018/5/5.
//  Copyright © 2018年 LEI. All rights reserved.
//

import Foundation
import SwiftyBeaver

class LogUtil: NSObject {
    
    let logsb = SwiftyBeaver.self
    
    static let shared = LogUtil()
    
    private var textView: NSTextView? = nil
    
    override init() {
        logsb.addDestination(ConsoleDestination())
    }
    
    private func getTime() -> String {
        let dateFormatter : DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        let date = Date()
        return dateFormatter.string(from: date)
    }
    
    private func tvloginfo(level: String, msg: String) {
        if let tv = textView {
            DispatchQueue.main.async {
                tv.string = "\(tv.string)\(self.getTime()) \(level) \(msg)\n"
                if (tv.visibleRect.maxY <= tv.bounds.maxY) {
                    tv.scrollToEndOfDocument(self)
                }
            }
        }
    }
    
    func addTextView(_ tv: NSTextView) {
        if textView == nil {
            textView = tv
        }
    }
    
    func info(_ message: @autoclosure () -> Any, _ file: String = #file, _ function: String = #function, line: Int = #line, context: Any? = nil) {
        logsb.info(message, file, function, line: line, context: context)
        tvloginfo(level: "INFO", msg: "\(message())")
    }
    
    func warning(_ message: @autoclosure () -> Any, _ file: String = #file, _ function: String = #function, line: Int = #line, context: Any? = nil) {
        logsb.warning(message, file, function, line: line, context: context)
        tvloginfo(level: "WARN", msg: "\(message())")
    }
    
    func error(_ message: @autoclosure () -> Any, _ file: String = #file, _ function: String = #function, line: Int = #line, context: Any? = nil) {
        logsb.error(message, file, function, line: line, context: context)
        tvloginfo(level: "ERROR", msg: "\(message())")
    }
    
}
