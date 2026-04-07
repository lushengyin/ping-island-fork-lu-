import AppKit
import Foundation
import CoreServices

actor TerminalAutomationPermissionCoordinator {
    static let shared = TerminalAutomationPermissionCoordinator()

    private var attemptedBundleIdentifiers: Set<String> = []

    private init() {}

    func prepareIfNeeded(
        provider: SessionProvider,
        clientInfo: SessionClientInfo,
        sessionId: String
    ) {
        guard provider == .claude || provider == .codex,
              let bundleIdentifier = scriptableTerminalBundleIdentifier(for: clientInfo)
        else {
            return
        }

        guard attemptedBundleIdentifiers.insert(bundleIdentifier).inserted else {
            return
        }

        Task.detached(priority: .utility) {
            await FocusDiagnosticsStore.shared.record(
                "AutomationPermission preflight-start session=\(sessionId) bundle=\(bundleIdentifier)"
            )

            let runningApplication = await MainActor.run {
                NSRunningApplication.runningApplications(withBundleIdentifier: bundleIdentifier)
                    .first { !$0.isTerminated }
            }

            guard let runningApplication else {
                await FocusDiagnosticsStore.shared.record(
                    "AutomationPermission preflight-skip-no-running-app session=\(sessionId) bundle=\(bundleIdentifier)"
                )
                return
            }

            let targetDescriptor = NSAppleEventDescriptor(
                processIdentifier: runningApplication.processIdentifier
            )
            guard let address = targetDescriptor.aeDesc else {
                await FocusDiagnosticsStore.shared.record(
                    "AutomationPermission preflight-skip-no-descriptor session=\(sessionId) bundle=\(bundleIdentifier) pid=\(runningApplication.processIdentifier)"
                )
                return
            }

            let status = AEDeterminePermissionToAutomateTarget(
                address,
                AEEventClass(typeWildCard),
                AEEventID(typeWildCard),
                true
            )

            await FocusDiagnosticsStore.shared.record(
                "AutomationPermission preflight-result session=\(sessionId) bundle=\(bundleIdentifier) pid=\(runningApplication.processIdentifier) status=\(status)"
            )
        }
    }

    private func scriptableTerminalBundleIdentifier(for clientInfo: SessionClientInfo) -> String? {
        switch clientInfo.terminalBundleIdentifier {
        case "com.googlecode.iterm2":
            if clientInfo.iTermSessionIdentifier?.isEmpty == false
                || clientInfo.terminalSessionIdentifier?.isEmpty == false {
                return "com.googlecode.iterm2"
            }
            return nil
        case "com.mitchellh.ghostty":
            return "com.mitchellh.ghostty"
        default:
            return nil
        }
    }
}
