//
//  FeildTests.swift
//  LifeGameTests
//
//  Created by Hori,Masaki on 2025/12/11.
//

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

}
