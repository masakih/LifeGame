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
    
    var field = Feild(width: 30, height: 21)
    
    private var cancellables: [AnyCancellable] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        guard fieldView != nil else {
            
            fatalError("Main.storyboard に FieldView が見つかりません")
        }
        
        fieldView
            .publisher()
            .sink { [weak self] (x, y) in
                
                self?.field.toggle(x, y)
            }
            .store(in: &self.cancellables)
        
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

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    @IBAction func grow(_ sender: Any) {
        
        field.grow()
    }


}

