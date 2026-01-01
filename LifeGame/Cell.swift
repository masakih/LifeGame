//
//  Cell.swift
//  LifeGame
//
//  Created by Hori,Masaki on 2025/12/18.
//

import Cocoa

final class Cell: NSCell {
    
    override func draw(withFrame cellFrame: NSRect, in controlView: NSView) {
        
        switch state {
            case .on:
                self.color.setFill()
                cellFrame.insetBy(dx: 0.25, dy: 0.25).fill()
            default:
                ()
        }
    }
    
    var color: NSColor {
        get {
            self.objectValue as? NSColor ?? .black
        }
        set {
            self.objectValue = newValue
        }
    }
}
