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
        #expect(feild.storage.allSatisfy { $0.allSatisfy { $0 == false } })
    }
    
    @Test func testToggle() {
        
        let feild = Feild(width: 4, height: 4)
        feild.toggle(1, 1)
        feild.toggle(2, 1)
        feild.toggle(2, 2)
        
        #expect(
            feild.storage ==
            [
                [false, false, false, false],
                [false, true,  true,  false],
                [false, false, true,  false],
                [false, false, false, false]
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
                [false, false, false, false, false, false],
                [false, false, false, false, false, false],
                [false, false, true,  true,  true,  false],
                [false, true,  true,  true,  false, false],
                [false, false, false, false, false, false],
                [false, false, false, false, false, false]
            ]
        )
        
        feild.grow()
        #expect(
            feild.storage ==
            [
                [false, false, false, false, false, false],
                [false, false, false, true,  false, false],
                [false, true,  false, false, true,  false],
                [false, true,  false, false, true,  false],
                [false, false, true,  false, false, false],
                [false, false, false, false, false, false]
            ]
        )
        
        feild.grow()
        #expect(
            feild.storage ==
            [
                [false, false, false, false, false, false],
                [false, false, false, false, false, false],
                [false, false, true,  true,  true,  false],
                [false, true,  true,  true,  false, false],
                [false, false, false, false, false, false],
                [false, false, false, false, false, false]
            ]
        )
    }
    
    @Test func testPublish() {
        
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
            #expect(
                zip(cells, changed01)
                    .allSatisfy {
                        $0.0 == $1.0 && $0.1 == $1.1
                    }
            )
        }
        .store(in: &cancellables)
        feild.grow()
        
        let changed02 = [(3, 1),
                         (1, 2), (2, 2), (3, 2),
                         (2, 3), (3, 3), (4, 3),
                         (2, 4)]
        publisher.first().sink { cells in
            #expect(
                zip(cells, changed02)
                    .allSatisfy {
                        $0.0 == $1.0 && $0.1 == $1.1
                    }
            )
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
    
    @Test func growPerformanceTest() async throws {
        let clock = ContinuousClock()
        
        let feild = await Feild(width: 109, height: 217)
        await feild.random(5)
        
        // 計測開始
        let startTime = clock.now
        
        for _ in 0..<200 {
            await feild.grow()
        }
        
        // 計測終了
        let endTime = clock.now
        let duration = endTime - startTime
        
        // 結果を出力 (秒単位)
        debugPrint("実行時間: \(duration)")
        
        // 必要に応じてしきい値を設定
        #expect(duration < .seconds(1.5))
    }
}
