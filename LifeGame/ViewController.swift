//
//  ViewController.swift
//  LifeGame
//
//  Created by Hori,Masaki on 2025/12/11.
//

import Cocoa
import Combine

final class ViewController: NSViewController {
    
    enum Setting {
        case autoGrow(Bool)
        case generation(Int)
        case cellSize(Int)
        case maxCellSize(Int)
        case minCellSize(Int)
    }
    
    @IBOutlet weak var fieldView: FieldView!
    
    /// for CocoaBindings
    @IBOutlet var settings: NSMutableDictionary! = [:]
        
    var width = 30
    var height = 21
    
    var field = Feild(width: 5, height: 5) {
        
        didSet {
            fieldCacellables = []
            
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
                .store(in: &self.fieldCacellables)
            
            field
                .generationPublisher()
                .sink { [weak self] generation in
                    self?.setting(.generation(generation))
                }
                .store(in: &self.fieldCacellables)
            
            setting(.generation(0))
        }
    }
    
    private var viewHolder: NSView!
    private var resizeView: ResizeView!
    
    private var growTimer: AnyPublisher<Void, Never>?
    private var growTimerCanceler: AnyCancellable?
    
    private var cancellables: [AnyCancellable] = []
    private var fieldCacellables: [AnyCancellable] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard fieldView != nil else {
            
            fatalError("Main.storyboard に FieldView が見つかりません")
        }
        
        cocoaBindingsSetup()

        field = Feild(width: width, height: height)
        
        fieldView
            .publisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (x, y) in
                
                self?.field.toggle(x, y)
            }
            .store(in: &self.cancellables)
        
        setupResizing()
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
    
    @IBAction func growTimer(_ sender: Any) {
        
        guard let button = sender as? NSButton else {
            fatalError("Sender not an NSButton")
        }
        
        if growTimerCanceler == nil {
            
            growTimerCanceler = Timer
                .publish(every: 0.3, on: .main, in: .default)
                .autoconnect()
                .sink { [weak self] _ in
                    
                    self?.field.grow()
                }
            button.title = "Stop"
            
            self.setting(.autoGrow(true))
        }
        else {
            growTimerCanceler?.cancel()
            growTimerCanceler = nil
            
            button.title = "Start"
            
            self.setting(.autoGrow(false))
        }
        
    }
    
    @IBAction func changeCellSize(_ sender: Any) {
        
        guard let c = sender as? NSControl else {
            return
        }
        self.setting(.cellSize(c.integerValue))
    }
    
    func cocoaBindingsSetup() {
        
        self.setting(.autoGrow(false))
        self.setting(.generation(0))
        
        self.setting(.maxCellSize(20))
        self.setting(.minCellSize(3))
        self.setting(.cellSize(self.fieldView.cellSize))
    }
    
    private func setupResizing() {
        
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
    
    private func setting(_ value: Setting) {
        
        switch value {
            case .autoGrow(let flag):
                self.settings.setValue(flag, forKey: "autoGrow")
            case .generation(let generation):
                self.settings.setValue(generation, forKey: "generation")
            case .cellSize(let size):
                self.settings.setValue(size, forKey: "cellSize")
                UserDefaults.standard.setValue(size, forKey: "cellSize")
                (self.width, self.height) = fieldView.setCellSize(size: size)
                field = Feild(width: self.width, height: self.height)
            case .maxCellSize(let max):
                self.settings.setValue(max, forKey: "cellMaxSize")
            case .minCellSize(let min):
                self.settings.setValue(min, forKey: "cellMinSize")

        }
    }
}

