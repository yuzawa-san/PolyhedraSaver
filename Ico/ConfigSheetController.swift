//
//  ConfigSheetController.swift
//  Ico
//
//  Created by James Yuzawa on 1/1/21.
//

import Foundation

import Cocoa

class ConfigSheetController : NSObject {
    @IBOutlet var window: NSWindow?
    
    override init() {
        super.init()
        let myBundle = Bundle(for: ConfigSheetController.self)
        myBundle.loadNibNamed("ConfigSheet", owner: self, topLevelObjects: nil)
    }
    
    @IBAction func closeConfigureSheet(_ sender: AnyObject) {
        NSApp.endSheet(window!)
    }
}
