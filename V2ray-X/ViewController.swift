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
import RxCocoa
import RxSwift

class ViewController: NSViewController {
    
    @IBOutlet weak var startSwitch: NSSwitch!
    @IBOutlet weak var proxySetting: NSPopUpButton!
    @IBOutlet weak var textView: NSTextView!
    
    private func updateStatus() {
        if DefaultsUtil.shared.getOn() {
            log.info("Start v2ray-x")
            ServiceUtil.shared.startV2ray()
            updateProxy()
        } else {
            log.info("Stop v2ray-x")
            ProxyUtil.shared.removeProxy()
            ServiceUtil.shared.stopV2ray()
        }
    }
    
    private func updateProxy() {
        log.info("Set proxy status \(DefaultsUtil.shared.getMode())")
        PacUtil.shared.stopPacServer()
        switch DefaultsUtil.shared.getMode() {
        case proxyMode.none.rawValue:
            ProxyUtil.shared.removeProxy()
        case proxyMode.pac.rawValue:
            PacUtil.shared.startPacServer()
            ProxyUtil.shared.setPacProxy()
        case proxyMode.global.rawValue:
            ProxyUtil.shared.setGlobalProxy()
        default:
            ProxyUtil.shared.removeProxy()
        }
    }
    
    var disposeBag = DisposeBag()
    
    var asyncWorker = DispatchQueue(label: "async_worker")
    
    private func asyncUpdateStatus() {
        asyncWorker.async {
            DefaultsUtil.shared.setOn(on: self.startSwitch.on)
            self.updateStatus()
        }
    }
    
    private func asyncUpdateProxy() {
        let item = proxySetting.selectedItem?.title
        asyncWorker.async {
            switch item {
            case "None":
                DefaultsUtil.shared.setMode(mode: proxyMode.none.rawValue)
            case "Pac":
                DefaultsUtil.shared.setMode(mode: proxyMode.pac.rawValue)
            case "Global":
                DefaultsUtil.shared.setMode(mode: proxyMode.global.rawValue)
            default:
                DefaultsUtil.shared.setMode(mode: proxyMode.none.rawValue)
            }
            if DefaultsUtil.shared.getOn() {
                self.updateProxy()
            }
        }
    }
    
    private func statusRecover() {
        startSwitch.setOn(on: DefaultsUtil.shared.getOn(), animated: true)
        switch DefaultsUtil.shared.getMode() {
        case proxyMode.none.rawValue:
            self.proxySetting.selectItem(at: 0)
        case proxyMode.pac.rawValue:
            self.proxySetting.selectItem(at: 1)
        case proxyMode.global.rawValue:
            self.proxySetting.selectItem(at: 2)
        default:
            self.proxySetting.selectItem(at: 0)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.backgroundColor = NSColor.black
        textView.textColor = NSColor.green
        
        LogUtil.shared.addTextView(textView)
        PacUtil.shared.generatePac()
        
        statusRecover()
        asyncUpdateStatus()
        
        startSwitch.rx.controlEvent.asObservable()
            .subscribe(onNext: {
                self.asyncUpdateStatus()
            })
            .disposed(by: disposeBag)
        proxySetting.rx.tap.asObservable()
            .subscribe(onNext: {
                self.asyncUpdateProxy()
            })
            .disposed(by: disposeBag)
        
        // Do any additional setup after loading the view.
    }


    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
}

