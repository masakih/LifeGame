//
//  FeildTests.swift
//  LifeGameTests
//
//  Created by Hori,Masaki on 2025/12/11.
//

import Combine

import Testing
@testable import LifeGame

struct FeildTests {
    
    @Test func testInitialize() {
        
        let feild = Feild(width: 4, height: 4)
        
        #expect(feild.width == 4)
        #expect(feild.height == 4)
        #expect(feild.storage.count == 4)
        #expect(feild.storage.allSatisfy{ $0.count == 4 })
        #expect(feild.storage.allSatisfy { $0.allSatisfy { $0 == 0 } })
    }
    
    @Test func testToggle() {
        
        let feild = Feild(width: 4, height: 4)
        feild.toggle(1, 1)
        feild.toggle(2, 1)
        feild.toggle(2, 2)
        
        #expect(
            feild.storage ==
            [
                [0, 0, 0, 0],
                [0, 1, 1, 0],
                [0, 0, 1, 0],
                [0, 0, 0, 0]
            ]
        )
    }
    
    @Test func testGrow() {
        
        // ヒキガエル
        let feild = Feild(width: 6, height: 6)
        feild.toggle(2, 2)
        feild.toggle(3, 2)
        feild.toggle(4, 2)
        feild.toggle(1, 3)
        feild.toggle(2, 3)
        feild.toggle(3, 3)

        #expect(
            feild.storage ==
            [
                [0, 0, 0, 0, 0, 0],
                [0, 0, 0, 0, 0, 0],
                [0, 0, 1, 1, 1, 0],
                [0, 1, 1, 1, 0, 0],
                [0, 0, 0, 0, 0, 0],
                [0, 0, 0, 0, 0, 0]
            ]
        )
        
        feild.grow()
        #expect(
            feild.storage ==
            [
                [0, 0, 0, 0, 0, 0],
                [0, 0, 0, 1, 0, 0],
                [0, 1, 0, 0, 1, 0],
                [0, 1, 0, 0, 1, 0],
                [0, 0, 1, 0, 0, 0],
                [0, 0, 0, 0, 0, 0]
            ]
        )
        
        feild.grow()
        #expect(
            feild.storage ==
            [
                [0, 0, 0, 0, 0, 0],
                [0, 0, 0, 0, 0, 0],
                [0, 0, 1, 1, 1, 0],
                [0, 1, 1, 1, 0, 0],
                [0, 0, 0, 0, 0, 0],
                [0, 0, 0, 0, 0, 0]
            ]
        )
    }
    
    @Test func testPublish() {
        
        func f(_ p: (Int, Int)) -> [Int] {
            [p.0, p.1]
        }
        
        // ヒキガエル
        let feild = Feild(width: 6, height: 6)
        feild.toggle(2, 2)
        feild.toggle(3, 2)
        feild.toggle(4, 2)
        feild.toggle(1, 3)
        feild.toggle(2, 3)
        feild.toggle(3, 3)
        
        let publisher = feild.publisher()
        var cancellables: [AnyCancellable] = []
        
        let changed01 = [(3, 1),
                         (1, 2), (2, 2), (3, 2),
                         (2, 3), (3, 3), (4, 3),
                         (2, 4)]
        publisher.first().sink { cells in
            let cc = changed01
                .sorted { $0.0 < $1.0 || ($0.0 == $1.0 && $0.1 < $1.1) }
                .map(f)
            let ce: [[Int]] = cells
                .sorted { $0.0 < $1.0 || ($0.0 == $1.0 && $0.1 < $1.1) }
                .map(f)
            #expect(cc == ce)
        }
        .store(in: &cancellables)
        feild.grow()
        
        let changed02 = [(3, 1),
                         (1, 2), (2, 2), (3, 2),
                         (2, 3), (3, 3), (4, 3),
                         (2, 4)]
        publisher.first().sink { cells in
            let cc = changed02
                .sorted { $0.0 < $1.0 || ($0.0 == $1.0 && $0.1 < $1.1) }
                .map(f)
            let ce: [[Int]] = cells
                .sorted { $0.0 < $1.0 || ($0.0 == $1.0 && $0.1 < $1.1) }
                .map(f)
            #expect(cc == ce)
        }
        .store(in: &cancellables)
        feild.grow()
    }
    
    @Test func togglePublishTest() {
        
        let feild = Feild(width: 4, height: 4)
        var cancellables: [AnyCancellable] = []
        feild.publisher().first()
            .sink { cells in
                #expect(cells[0].0 == 1)
                #expect(cells[0].1 == 1)
            }
            .store(in: &cancellables)

        feild.toggle(1, 1)
        
    }
    
    @Test func growPerformanceTest()  {
        let clock = ContinuousClock()
        
        let feild = Feild(width: 109, height: 217)
        feild.random(5)
        
        // 計測開始
        let startTime = clock.now
        
        for _ in 0..<200 {
            feild.grow()
        }
        
        // 計測終了
        let endTime = clock.now
        let duration = endTime - startTime
        
        // 結果を出力 (秒単位)
        debugPrint("実行時間: \(duration)")
        
        // 必要に応じてしきい値を設定
        #expect(duration < .seconds(1.2))
    }
}
