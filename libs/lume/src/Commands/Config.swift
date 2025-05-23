import ArgumentParser
import Foundation

struct Config: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "config",
        abstract: "Get or set lume configuration",
        subcommands: [Get.self, Storage.self, Cache.self, Caching.self],
        defaultSubcommand: Get.self
    )

    // MARK: - Basic Configuration Subcommands

    struct Get: ParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "get",
            abstract: "Get current configuration"
        )

        func run() throws {
            let controller = LumeController()
            let settings = controller.getSettings()

            // Display default location
            print(
                "Default VM storage: \(settings.defaultLocationName) (\(settings.defaultLocation?.path ?? "not set"))"
            )

            // Display cache directory
            print("Cache directory: \(settings.cacheDirectory)")

            // Display caching enabled status
            print("Caching enabled: \(settings.cachingEnabled)")

            // Display all locations
            if !settings.vmLocations.isEmpty {
                print("\nConfigured VM storage locations:")
                for location in settings.sortedLocations {
                    let isDefault = location.name == settings.defaultLocationName
                    let defaultMark = isDefault ? " (default)" : ""
                    print("  - \(location.name): \(location.path)\(defaultMark)")
                }
            }
        }
    }

    // MARK: - Debug Command

    struct Debug: ParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "debug",
            abstract: "Output detailed debug information about current configuration",
            shouldDisplay: false
        )

        func run() throws {
            let debugInfo = SettingsManager.shared.debugSettings()
            print(debugInfo)
        }
    }

    // MARK: - Caching Management Subcommands

    struct Caching: ParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "caching",
            abstract: "Manage image caching settings",
            subcommands: [GetCaching.self, SetCaching.self]
        )

        struct GetCaching: ParsableCommand {
            static let configuration = CommandConfiguration(
                commandName: "get",
                abstract: "Show current caching status"
            )

            func run() throws {
                let controller = LumeController()
                let cachingEnabled = controller.isCachingEnabled()
                print("Caching enabled: \(cachingEnabled)")
            }
        }

        struct SetCaching: ParsableCommand {
            static let configuration = CommandConfiguration(
                commandName: "set",
                abstract: "Enable or disable image caching"
            )

            @Argument(help: "Enable or disable caching (true/false)")
            var enabled: Bool

            func run() throws {
                let controller = LumeController()
                try controller.setCachingEnabled(enabled)
                print("Caching \(enabled ? "enabled" : "disabled")")
            }
        }
    }

    // MARK: - Cache Management Subcommands

    struct Cache: ParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "cache",
            abstract: "Manage cache settings",
            subcommands: [GetCache.self, SetCache.self]
        )

        struct GetCache: ParsableCommand {
            static let configuration = CommandConfiguration(
                commandName: "get",
                abstract: "Get current cache directory"
            )

            func run() throws {
                let controller = LumeController()
                let cacheDir = controller.getCacheDirectory()
                print("Cache directory: \(cacheDir)")
            }
        }

        struct SetCache: ParsableCommand {
            static let configuration = CommandConfiguration(
                commandName: "set",
                abstract: "Set cache directory"
            )

            @Argument(help: "Path to cache directory")
            var path: String

            func run() throws {
                let controller = LumeController()
                try controller.setCacheDirectory(path: path)
                print("Cache directory set to: \(path)")
            }
        }
    }

    // MARK: - Storage Management Subcommands

    struct Storage: ParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "storage",
            abstract: "Manage VM storage locations",
            subcommands: [Add.self, Remove.self, List.self, Default.self]
        )

        struct Add: ParsableCommand {
            static let configuration = CommandConfiguration(
                commandName: "add",
                abstract: "Add a new VM storage location"
            )

            @Argument(help: "Storage name (alphanumeric with dashes/underscores)")
            var name: String

            @Argument(help: "Path to VM storage directory")
            var path: String

            func run() throws {
                let controller = LumeController()
                try controller.addLocation(name: name, path: path)
                print("Added VM storage location: \(name) at \(path)")
            }
        }

        struct Remove: ParsableCommand {
            static let configuration = CommandConfiguration(
                commandName: "remove",
                abstract: "Remove a VM storage location"
            )

            @Argument(help: "Storage name to remove")
            var name: String

            func run() throws {
                let controller = LumeController()
                try controller.removeLocation(name: name)
                print("Removed VM storage location: \(name)")
            }
        }

        struct List: ParsableCommand {
            static let configuration = CommandConfiguration(
                commandName: "list",
                abstract: "List all VM storage locations"
            )

            func run() throws {
                let controller = LumeController()
                let settings = controller.getSettings()

                if settings.vmLocations.isEmpty {
                    print("No VM storage locations configured")
                    return
                }

                print("VM Storage Locations:")
                for location in settings.sortedLocations {
                    let isDefault = location.name == settings.defaultLocationName
                    let defaultMark = isDefault ? " (default)" : ""
                    print("  - \(location.name): \(location.path)\(defaultMark)")
                }
            }
        }

        struct Default: ParsableCommand {
            static let configuration = CommandConfiguration(
                commandName: "default",
                abstract: "Set the default VM storage location"
            )

            @Argument(help: "Storage name to set as default")
            var name: String

            func run() throws {
                let controller = LumeController()
                try controller.setDefaultLocation(name: name)
                print("Set default VM storage location to: \(name)")
            }
        }
    }
}
