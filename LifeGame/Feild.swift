//
//  Feild.swift
//  LifeGame
//
//  Created by Hori,Masaki on 2025/12/11.
//

final class Feild {

    var width: Int
    var height: Int

    private var buffer: [[[Bool]]]

    private enum CurrentBuffer: Int {
        case first = 0, second = 1

        mutating func toggle() {
            switch self {
                case .first: self = .second
                case .second: self = .first
            }
        }
    }
    private var currentBuffer = CurrentBuffer.first
    private var nextIndex: Int { (currentBuffer.rawValue + 1) % 2 }

    var storage: [[Bool]] { buffer[currentBuffer.rawValue] }

    init(width: Int, height: Int) {
        assert(width > 2)
        assert(height > 2)

        self.width = width
        self.height = height

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
    }

    private func topLeft(_ x: Int, _ y: Int) -> Bool {
        storage[y - 1][x - 1]
    }
    private func top(_ x: Int, _ y: Int) -> Bool {
        storage[y - 1][x]
    }
    private func topRight(_ x: Int, _ y: Int) -> Bool {
        storage[y - 1][x + 1]
    }
    private func left(_ x: Int, _ y: Int) -> Bool {
        storage[y][x - 1]
    }
    private func right(_ x: Int, _ y: Int) -> Bool {
        storage[y][x + 1]
    }
    private func bottomLeft(_ x: Int, _ y: Int) -> Bool {
        storage[y + 1][x - 1]
    }
    private func bottom(_ x: Int, _ y: Int) -> Bool {
        storage[y + 1][x]
    }
    func bottomRight(_ x: Int, _ y: Int) -> Bool {
        storage[y + 1][x + 1]
    }
    
    /// cellの一世代後の値を返す
    /// - Parameters:
    ///   - p: 対象セルの値
    ///   - around: 対象セルの隣接8方のセルの値
    /// - Returns: 対象セルの一世代後の値
    private func grow1(p: Bool, _ around: Bool...) -> Bool {
        assert(around.count == 8)

        let aliveCount = around.count { $0 }

        switch (p, aliveCount) {
            case (false, 3):  return true
            case (true, 2...3): return true

            case (false, _): return false
            case (true, _): return false
        }
    }

    func grow() {
        
        for i in 1..<(height - 1) {
            for j in 1..<(width - 1) {
                
                buffer[nextIndex][i][j] = grow1(
                    p: storage[i][j],
                    topLeft(j, i), top(j, i), topRight(j, i),
                    left(j, i),  right(j, i),
                    bottomLeft(j, i), bottom(j, i), bottomRight(j, i)
                )
            }
        }

        currentBuffer.toggle()
    }
    
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
    }

}
