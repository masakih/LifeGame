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
                NSColor.black.setFill()
                cellFrame.insetBy(dx: 1, dy: 1).fill()
            case .off:
                NSColor.black.set()
                cellFrame.frame(withWidth: 1)
            default:
                ()
        }
    }
}
