//
//  ViewController.swift
//  LifeGame
//
//  Created by Hori,Masaki on 2025/12/11.
//

import Cocoa
import Combine

final class ViewController: NSViewController {
    
    @IBOutlet weak var fieldView: FieldView!
    
    var width = 30
    var height = 21
    
    var field = Feild(width: 5, height: 5) {
        
        didSet {
            field
                .publisher()
                .sink { [weak self] points in
                    
                    guard let self else { return }
                    
                    fieldView.setPointStates(
                        states: points
                            .map { (x, y) -> FieldView.PointState in
                                switch self.field.storage[y][x] {
                                    case true: .on(x, y)
                                    case false: .off(x, y)
                                }
                            }
                    )
                }
                .store(in: &self.cancellables)
        }
    }
    
    private var viewHolder: NSView!
    private var resizeView: ResizeView!
    
    private var cancellables: [AnyCancellable] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        guard fieldView != nil else {
            
            fatalError("Main.storyboard に FieldView が見つかりません")
        }
        
        field = Feild(width: width, height: height)
        
        fieldView
            .publisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (x, y) in
                
                self?.field.toggle(x, y)
            }
            .store(in: &self.cancellables)
        
        fieldView.postsFrameChangedNotifications = true
        NotificationCenter
            .default
            .publisher(
                for: NSView.frameDidChangeNotification,
                object: self.fieldView
            )
            .sink { [weak self] _ in
                
                guard let self else { return }
                
                self.width = self.fieldView.width
                self.height = self.fieldView.height
                
                self.field = Feild(width: self.fieldView.width, height: self.fieldView.height)
            }
            .store(in: &self.cancellables)
        
        NotificationCenter
            .default
            .publisher(
                for: NSWindow.willStartLiveResizeNotification,
                object: self.view.window
            )
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                
                guard let self else { return }
                
                self.resizeView = self.resizeView ?? ResizeView(cellSize: self.fieldView.cellSize)
                self.resizeView.autoresizingMask = self.fieldView.autoresizingMask
                self.resizeView.frame = self.fieldView.frame
                
                self.viewHolder = self.fieldView
                self.view.replaceSubview(self.fieldView, with: self.resizeView)
                
            }
            .store(in: &self.cancellables)
        
        NotificationCenter
            .default
            .publisher(
                for: NSWindow.didEndLiveResizeNotification,
                object: self.view.window)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                
                guard let self else { return }
                
                self.viewHolder.frame = self.resizeView.frame
                self.view.replaceSubview(self.resizeView, with: self.viewHolder)
                self.viewHolder = nil
            }
            .store(in: &self.cancellables)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    @IBAction func grow(_ sender: Any) {
        
        field.grow()
    }
    
    @IBAction func reset(_ sender: Any) {
        
        field.reset()
    }
    
    @IBAction func random(_ sender: Any) {
        
        field.random(5)
    }
}

