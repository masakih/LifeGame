//
//  ResizeView.swift
//  LifeGame
//
//  Created by Hori,Masaki on 2025/12/29.
//

import Cocoa

class ResizeView: NSView {
    
    var cellSize = 23
    
    init(cellSize: Int = 23) {
        
        self.cellSize = cellSize
        
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        NSColor.lightGray.setStroke()
        NSBezierPath(rect: bounds).stroke()
        
        let size = self.currentSize()
        let text = "\(size.w) X \(size.h)"
        let attributes: [NSAttributedString.Key: Any] = [
                    .font: NSFont.systemFont(ofSize: 48),
                    .foregroundColor: NSColor.blue,
                    .strokeColor: NSColor.black, // 文字の縁取り
                    .strokeWidth: -1.0 // 縁取りの太さ
                ]
        let attributedString = NSAttributedString(string: text, attributes: attributes)
                
        let textSize = attributedString.boundingRect(with: self.bounds.size).size
        let textDrawRect = NSRect(
            x: self.bounds.midX - textSize.width / 2,
            y: self.bounds.midY - textSize.height / 2,
            width: textSize.width,
            height: textSize.height
        )
        
        attributedString.draw(in: textDrawRect)
    }
    
    func currentSize() -> (w: Int, h: Int) {
        
        let w = Int(floor(Double(self.bounds.width) / Double(self.cellSize)))
        let h = Int(floor(Double(self.bounds.height) / Double(self.cellSize)))
        
        return (w, h)
    }
    
}
