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
        
    /// for CocoaBindings
    @IBOutlet var settings: NSMutableDictionary! = [:]
    lazy var typedSettings: TypedSettings = .init(self.settings)
        
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
                                    case 1: .on(x, y)
                                    case 0: .off(x, y)
                                    default : fatalError()
                                }
                            }
                    )
                }
                .store(in: &self.fieldCacellables)
            
            field
                .generationPublisher()
                .sink { [weak self] generation in
                    self?.typedSettings[.generation] = generation
                }
                .store(in: &self.fieldCacellables)
            
            typedSettings[.generation] = 0
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
        
        typedSettings.publisher(for: .cellSize)
            .sink { [weak self] size in
                
                guard let size, let self else { return }
                
                UserDefaults.standard.setValue(size, forKey: "cellSize")
                (self.width, self.height) = fieldView.setCellSize(size: size)
                field = Feild(width: self.width, height: self.height)
            }
            .store(in: &self.cancellables)

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
    
    @IBAction func grow(_ sender: Any) {
        
        field.grow()
    }
    
    @IBAction func reset(_ sender: Any) {
        
        field.reset()
    }
    
    @IBAction func random(_ sender: Any) {
        
        field.random(5)
    }
    
    @IBAction func autoGrow(_ sender: Any) {
        
        if growTimerCanceler == nil {
            
            growTimerCanceler = Timer
                .publish(every: 0.3, on: .main, in: .default)
                .autoconnect()
                .sink { [weak self] _ in
                    
                    self?.field.grow()
                }
            
            typedSettings[.autoGrow] = true
        }
        else {
            growTimerCanceler?.cancel()
            growTimerCanceler = nil
                        
            typedSettings[.autoGrow] = false
        }
        
    }
    
    @IBAction func biggerCell(_ sender: Any) {
                
        self.typedSettings[.cellSize]? += 1
    }
    
    @IBAction func smallerCell(_ sender: Any) {
                
        self.typedSettings[.cellSize]? -= 1
    }
    
    func cocoaBindingsSetup() {
        
        self.typedSettings[.autoGrow] = false
        self.typedSettings[.generation] = 0
        self.typedSettings[.cellMaxSize] = 20
        self.typedSettings[.cellMinSize] = 3
        self.typedSettings[.cellSize] = self.fieldView.cellSize
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
}

extension ViewController: NSMenuItemValidation, NSToolbarItemValidation {
    
    func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        
        guard let action = menuItem.action else {
            return false
        }
        
        let (flag, title) = validateAction(action)
        
        title.map { menuItem.title = $0 }
        
        return flag
    }
    
    func validateToolbarItem(_ item: NSToolbarItem) -> Bool {
        
        guard let action = item.action else {
            return false
        }
                        
        let (flag, title) = validateAction(action)
        
        switch title {
            case "Start":
                item.image = NSImage(
                    systemSymbolName: "play.fill",
                    accessibilityDescription: nil
                )
            case "Stop":
                item.image = NSImage(
                    systemSymbolName: "pause.fill",
                    accessibilityDescription: nil
                )
            default:
                ()
        }
        
        return flag
    }
    
    func validateAction(_ action: Selector) -> (flag: Bool, title: String?) {
        
        guard let flag = self.typedSettings[.autoGrow] else {
            
            return (false, nil)
        }
        
        switch action {
            case #selector(biggerCell):
                if let l = self.typedSettings[.cellMaxSize],
                   self.fieldView.cellSize >= l {
                    
                    return (false, nil)
                }
                return (!flag, nil)
                
            case #selector(smallerCell):
                
                if let s = self.typedSettings[.cellMinSize],
                   self.fieldView.cellSize <= s {
                    
                    return (false, nil)
                }
                return (!flag, nil)
                
            case #selector(grow),
                #selector(reset),
                #selector(random):
                
                return (!flag, nil)
                
            case #selector(autoGrow):
                if flag {
                    return (true, "Stop")
                }
                else {
                    return (true, "Start")
                }
                
            default:
                return (false, nil)
        }
    }
    
}
