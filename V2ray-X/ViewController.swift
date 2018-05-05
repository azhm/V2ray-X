//
//  ViewController.swift
//  V2ray-X
//
//  Created by LEI on 2018/5/2.
//  Copyright © 2018年 LEI. All rights reserved.
//

import Cocoa
import NSSwitch
import os

class ViewController: NSViewController {
    
    @IBOutlet weak var proxyOutlet: NSPopUpButton!
    @IBOutlet var textView: NSTextView!
    
    private var started = false
    private var mode = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.backgroundColor = NSColor.black
        textView.textColor = NSColor.green
        
        LogUtil.shared.addTextView(textView)
        PacUtil.shared.generatePac()
        
        
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func switchAction(_ sender: NSSwitch) {
        if (sender.on) {
            log.info("start v2ray-x")
            ServiceUtil.shared.startV2ray()
            started = true
            updateProxy()
        } else {
            log.info("stop v2ray-x")
            ServiceUtil.shared.stopV2ray()
            proxyOutlet.selectItem(at: 0)
            updateProxy()
            started = false
        }
    }
    
    private func updateProxy() {
        if let item = proxyOutlet.selectedItem {
            if item.title == mode {
                return
            }
            log.info("set proxy status \(item.title)")
            mode = item.title
            PacUtil.shared.stopPacServer()
            if (item.title == "None") {
                ProxyConfig.shared.removeProxy()
            } else if (item.title == "Pac") {
                PacUtil.shared.startPacServer()
                ProxyConfig.shared.setPacProxy()
            } else if (item.title == "Global") {
                ProxyConfig.shared.setGlobalProxy()
            }
        }
    }

    @IBAction func proxyAction(_ sender: NSPopUpButton) {
        if !started {
            return
        }
        updateProxy()
    }
    
}

