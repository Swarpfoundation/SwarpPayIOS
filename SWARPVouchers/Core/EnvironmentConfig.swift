import Foundation

struct EnvironmentConfig {
    let apiBaseURL: URL
    let demoMode: Bool

    static let localDemo = EnvironmentConfig(
        apiBaseURL: URL(string: "http://localhost:3000")!,
        demoMode: true
    )
}
