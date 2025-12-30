//
//  FieldView.swift
//  LifeGame
//
//  Created by Hori,Masaki on 2025/12/18.
//

import Cocoa
import Combine

final class FieldView: NSView {
    
    enum PointState {
        case on(Int, Int)
        case off(Int, Int)
    }
    
    private(set) var width: Int
    private(set) var height: Int
    
    private var cells: [Cell] = []
    
    private(set) var cellSize = 23
    
    private var subject: PassthroughSubject<(Int, Int), Never> = .init()
    
    init(width: Int, height: Int) {
        
        self.width = width
        self.height = height
        
        super.init(
            frame: NSRect(
                origin: .zero,
                size: CGSize(
                    width: width * cellSize,
                    height: height * cellSize
                )
            )
        )
        
        self.setupCells()
    }
    
    required init?(coder: NSCoder) {
        
        self.width = 30
        self.height = 21
        
        super.init(coder: coder)
        
        (self.width, self.height) = self.matrixSize(self.frame.size)
        
        self.setupCells()
    }
    
    override func draw(_ dirtyRect: NSRect) {
        
        super.draw(dirtyRect)
        
//        NSColor.red.setFill()
//        self.bounds.fill()

        (0..<height).forEach { y in
            (0..<width).forEach { x in
                
                let rect = cellRect(x: x, y: y)
                if rect.intersects(dirtyRect) {
                    
                    cells[y * width + x].draw(withFrame: rect, in: self)
                }
            }
        }
    }
    
    override var frame: NSRect {
        
        willSet(newValue) {
                        
            (self.width, self.height) = self.matrixSize(newValue.size)
        }
        
        didSet {
            
            self.setupCells()
        }
    }
    
    override func mouseDown(with event: NSEvent) {
        
        let mouse = self.convert(event.locationInWindow, from: nil)
        let x = Int(Int(mouse.x) / cellSize)
        let y = Int(Int(mouse.y) / cellSize)
        
        // 外周はoff固定
        guard x > 0, x < self.width - 1, y > 0, y < self.height - 1 else {
            
            return
        }
        
        cells[y * width + x].setNextState()
        
        self.setNeedsDisplay(cellRect(x: x, y: y))
        
        self.subject.send((x, y))
    }
    
    func setPointStates(states: [PointState]) {
        
        var changedCellRect = NSRect.zero
        
        states.forEach { state in
            
            switch state {
                case let .on(x, y) where cells[y * width + x].state == .off:
                    cells[y * width + x].state = .on
                    changedCellRect = changedCellRect.union(self.cellRect(x: x, y: y))
                case let .off(x, y) where cells[y * width + x].state == .on:
                    cells[y * width + x].state = .off
                    changedCellRect = changedCellRect.union(self.cellRect(x: x, y: y))
                default:
                    ()
            }
        }
        
        self.setNeedsDisplay(changedCellRect)
    }
    
    func reset() {
        
        cells.forEach { $0.state = .off }
        
        self.setNeedsDisplay(self.bounds)
    }
    
    func publisher() -> AnyPublisher<(Int, Int), Never> {
        
        subject.eraseToAnyPublisher()
    }
    
    private func matrixSize(_ frameSize: NSSize) -> (w: Int, h: Int) {
        
        let w = Int(floor(Double(frameSize.width) / Double(self.cellSize)))
        let h = Int(floor(Double(frameSize.height) / Double(self.cellSize)))
        
        return (w, h)
    }
    
    private func cellRect(x: Int, y: Int) -> NSRect {
        
        /// TODO: 効率悪い。
        let cellFrameSize = NSSize(width: self.cellSize * width, height: self.cellSize * height)
        let (wMergin, hMergin) = (
            (self.bounds.size.width - cellFrameSize.width) / 2,
            (self.bounds.size.height - cellFrameSize.height) / 2
        )
        
        return NSRect(
            x: wMergin + CGFloat(cellSize * x),
            y: hMergin + CGFloat(cellSize * y),
            width: CGFloat(cellSize),
            height: CGFloat(cellSize)
        )
    }
    
    private func setupCells() {
        
        self.cells.removeAll()
                
        (0..<self.height).forEach { _ in
            (0..<self.width).forEach { _ in
                
                self.cells.append(Cell())
            }
        }
    }
}
