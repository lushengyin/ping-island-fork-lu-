import Foundation

/// Mascot animation states
enum MascotStatus: String, Codable, CaseIterable, Sendable {
    case idle = "idle"
    case working = "working"
    case warning = "warning"
    
    var displayName: String {
        switch self {
        case .idle: return "空闲中"
        case .working: return "运行中"
        case .warning: return "警告状态"
        }
    }
}

/// Extension to map session status to mascot status
extension MascotStatus {
    /// Convert from session phase to mascot status
    init(from sessionPhase: SessionPhase) {
        switch sessionPhase {
        case .idle, .ended:
            self = .idle
        case .waitingForApproval, .waitingForInput:
            self = .warning
        case .processing, .compacting:
            self = .working
        }
    }
}
