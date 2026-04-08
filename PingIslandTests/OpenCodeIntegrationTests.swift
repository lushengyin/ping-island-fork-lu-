import XCTest
@testable import Ping_Island

final class OpenCodeIntegrationTests: XCTestCase {
    func testOpenCodeManagedProfileUsesPluginFileInstallation() {
        let profile = ClientProfileRegistry.managedHookProfile(id: "opencode-hooks")

        XCTAssertNotNil(profile)
        XCTAssertEqual(profile?.title, "OpenCode")
        XCTAssertEqual(profile?.installationKind, .pluginFile)
        XCTAssertEqual(profile?.brand, .opencode)
        XCTAssertEqual(profile?.localAppBundleIdentifiers, ["ai.opencode.desktop"])
        XCTAssertEqual(profile?.primaryConfigurationURL.path, NSHomeDirectory() + "/.config/opencode/plugins/ping-island.js")
        XCTAssertTrue(profile?.reinstallDescriptionFormat.contains("插件文件") == true)
    }

    func testOpenCodeRuntimeProfileResolvesBrandAndMascot() {
        let profile = ClientProfileRegistry.matchRuntimeProfile(
            provider: .claude,
            explicitKind: "OpenCode",
            explicitName: "OpenCode",
            explicitBundleIdentifier: nil,
            terminalBundleIdentifier: nil,
            origin: "cli",
            originator: "OpenCode",
            threadSource: "opencode-plugin",
            processName: nil
        )

        XCTAssertEqual(profile?.id, "opencode")
        XCTAssertEqual(profile?.brand, .opencode)
        XCTAssertEqual(profile?.defaultBundleIdentifier, "ai.opencode.desktop")
        XCTAssertEqual(profile?.bundleIdentifiers, ["ai.opencode.desktop"])

        let clientInfo = SessionClientInfo(
            kind: .custom,
            profileID: "opencode",
            name: "OpenCode",
            origin: "cli",
            originator: "OpenCode",
            threadSource: "opencode-plugin"
        )

        XCTAssertEqual(clientInfo.brand, .opencode)
        XCTAssertEqual(MascotClient(clientInfo: clientInfo, provider: .claude), .opencode)
        XCTAssertEqual(MascotKind(clientInfo: clientInfo, provider: .claude), .opencode)
        XCTAssertEqual(clientInfo.badgeLabel(for: .claude), "OpenCode")
    }
}
