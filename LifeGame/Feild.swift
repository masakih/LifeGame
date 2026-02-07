//
//  Feild.swift
//  LifeGame
//
//  Created by Hori,Masaki on 2025/12/11.
//

import Combine

final class Feild {
    
    private(set) var generation: Int = 0 {
        didSet {
            self.generationSubject.send(generation)
        }
    }

    private(set) var width: Int
    private(set) var height: Int

    private var buffer: [[[Bool]]] = []
    
    // grow()によって変更されたセルをpublishする
    private var subject: PassthroughSubject<[(Int, Int)], Never> = .init()
    private var generationSubject: PassthroughSubject<Int, Never> = .init()

    private enum CurrentBuffer: Int {
        case first = 0, second = 1

        mutating func toggle() {
            switch self {
                case .first: self = .second
                case .second: self = .first
            }
        }
        
        var backing: CurrentBuffer {
            switch self {
                case .first: return .second
                case .second: return .first
            }
        }
    }
    private var currentBuffer = CurrentBuffer.first
    private var nextIndex: Int { currentBuffer.backing.rawValue }

    var storage: [[Bool]] { buffer[currentBuffer.rawValue] }

    init(width: Int, height: Int) {
        assert(width > 2)
        assert(height > 2)

        self.width = width
        self.height = height

        self.buildBuffer()
    }
    
    private func buildBuffer() {
        
        buffer = Array(
            repeating: Array(
                repeating: Array(
                    repeating: false,
                    count: width
                ),
                count: height
            ),
            count: 2
        )
        
        self.generation = 0
    }
    
    /// cellの一世代後の値を返す
    /// - Parameters:
    ///   - p: 対象セルの値
    ///   - around: 対象セルの隣接8方のセルの値
    /// - Returns: 対象セルの一世代後の値
    @inline(__always)
    private func grow1(p: Bool,
                       _ a0: Bool, _ a1: Bool, _ a2: Bool,
                       _ a3: Bool, _ a4: Bool,
                       _ a5: Bool, _ a6: Bool, _ a7: Bool) -> Bool {

        let f: (Bool) -> Int = { $0 ? 1 : 0 }
        let aliveCount = f(a0) + f(a1) + f(a2) + f(a3) + f(a4) + f(a5) + f(a6) + f(a7)

        switch (p, aliveCount) {
            case (false, 3):  return true
            case (true, 2...3): return true

            default: return false
        }
    }
    
    /// 一世代進める
    func grow() {
        
        var changedCells: [(Int, Int)] = []
        
        for i in 1..<(height - 1) {
            let rowPrev = storage[i - 1]
            let row     = storage[i]
            let rowNext = storage[i + 1]
                        
            for j in 1..<(width - 1) {
                
                let next = grow1(
                    p: row[j],
                    rowPrev[j - 1], rowPrev[j], rowPrev[j + 1],
                    row[j - 1], row[j + 1],
                    rowNext[j - 1], rowNext[j], rowNext[j + 1]
                )
                if row[j] != next {
                    changedCells.append( (j, i) )
                }
                buffer[nextIndex][i][j] = next
            }
        }

        currentBuffer.toggle()
        
        subject.send(changedCells)
        
        self.generation += 1
    }
    
    
    /// 全てをfalseにする。
    func reset() {
        
        self.buildBuffer()
        
        subject.send(
            (1..<(width - 1)).flatMap { x in
                (1..<(height - 1)).map { y in (x, y) }
            }
        )
    }
    
    /// リセットしランダムに配置する
    /// - Parameter n: 粗密度。大きいほど粗。
    func random(_ n: Int) {
        
        self.buildBuffer()
        
        subject.send(
            (1..<(width - 1)).flatMap { x in
                (1..<(height - 1)).map { y in
                    buffer[currentBuffer.rawValue][y][x] =
                    switch (1...n).randomElement()! {
                        case 3: true
                        default: false
                    }
                    return (x, y)
                }
            }
        )
    }
    
    /// 指定座標のOn/Offを切り替える
    /// - Parameters:
    ///   - x: ｘ座標(0-base)
    ///   - y: Ｙ座標(0-base)
    func toggle(_ x: Int, _ y: Int) {
        assert(x>=0)
        assert(y>=0)
        assert(x<=(width - 1))
        assert(y<=(height - 1))
        
        // 端はfalseで固定
        if x == 0, y == 0, x == width - 1, y == height - 1 {
            return
        }
        
        buffer[currentBuffer.rawValue][y][x].toggle()
        
        subject.send([(x, y)])
    }
    
    /// 変更されたセルの座標(0-base)の配列をPublishするPublisher
    func publisher() -> AnyPublisher<[(Int, Int)], Never> {
        
        subject.eraseToAnyPublisher()
    }
    
    func generationPublisher() -> AnyPublisher<Int, Never> {
        
        generationSubject.eraseToAnyPublisher()
    }

}
