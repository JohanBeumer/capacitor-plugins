import Foundation

public struct PreferencesConfiguration: Equatable {
    public enum Group: Equatable {
        case named(String), cordovaNativeStorage
    }

    let group: Group

    public init(for group: Group = .named("CapacitorStorage")) {
        self.group = group
    }
    
    var suiteName: String {
           switch group {
           case .named(let name):
               return name
           case .cordovaNativeStorage:
               return "CapacitorStorage"
           }
       }
}

public class Preferences {
    private let configuration: PreferencesConfiguration

    private var defaults: UserDefaults {
        if (configuration.group == PreferencesConfiguration.Group.cordovaNativeStorage || configuration.suiteName.isEmpty) {
            return UserDefaults.standard
        }
        else {
            return UserDefaults(suiteName: configuration.suiteName)!
        }
    }

    private var prefix: String {
        switch configuration.group {
        case .cordovaNativeStorage:
            return ""
        case let .named(group):
            return group + "."
        }
    }

    private var rawKeys: [String] {
        return defaults.dictionaryRepresentation().keys.filter { $0.hasPrefix(prefix) }
    }

    public init(with configuration: PreferencesConfiguration) {
        self.configuration = configuration
    }

    public func get(by key: String) -> String? {
        return defaults.string(forKey: applyPrefix(to: key))
    }

    public func set(_ value: String, for key: String) {
        defaults.set(value, forKey: applyPrefix(to: key))
    }

    public func remove(by key: String) {
        defaults.removeObject(forKey: applyPrefix(to: key))
    }

    public func removeAll() {
        for key in rawKeys {
            defaults.removeObject(forKey: key)
        }
    }

    public func keys() -> [String] {
        return rawKeys.map { String($0.dropFirst(prefix.count)) }
    }

    private func applyPrefix(to key: String) -> String {
        return prefix + key
    }
}
