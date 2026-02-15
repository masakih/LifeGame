//
//  TypedSettings.swift
//  LifeGame
//
//  Created by Hori,Masaki on 2026/02/13.
//

import Combine
import Foundation

struct TypedSettingsKey<Value> {
    let rawValue: String
    init(_ rawValue: String) { self.rawValue = rawValue }
}

extension TypedSettingsKey where Value == Bool {
    static let autoGrow = TypedSettingsKey("autoGrow")
}
extension TypedSettingsKey where Value == Int {
    static let generation = TypedSettingsKey("generation")
    static let cellSize = TypedSettingsKey("cellSize")
    static let cellMaxSize = TypedSettingsKey("cellMaxSize")
    static let cellMinSize = TypedSettingsKey("cellMinSize")
}

final class TypedSettings {
    private let storage: NSMutableDictionary
    private var subjects: [String: PassthroughSubject<Any?, Never>] = [:]

    init(_ storage: NSMutableDictionary) { self.storage = storage }

    subscript<V>(_ key: TypedSettingsKey<V>) -> V? {
        get { storage[key.rawValue] as? V }
        set {
            storage[key.rawValue] = newValue
            subjects[key.rawValue]?.send(newValue)
        }
    }

    func publisher<V>(for key: TypedSettingsKey<V>) -> AnyPublisher<V?, Never> {
        let subject = subjects[key.rawValue] ?? {
            let s = PassthroughSubject<Any?, Never>()
            subjects[key.rawValue] = s
            return s
        }()
        return subject
            .map { $0 as? V }
            .eraseToAnyPublisher()
    }
}
