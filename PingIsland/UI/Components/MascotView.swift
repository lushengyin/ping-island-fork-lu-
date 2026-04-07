import SwiftUI

enum MascotClient: String, CaseIterable, Identifiable, Sendable {
    case claude
    case codex
    case cursor
    case qoder
    case codebuddy
    case trae
    case copilot

    var id: String { rawValue }

    var title: String {
        switch self {
        case .claude:
            return "Claude Code"
        case .codex:
            return "Codex"
        case .cursor:
            return "Cursor"
        case .qoder:
            return "Qoder"
        case .codebuddy:
            return "CodeBuddy"
        case .trae:
            return "Trae"
        case .copilot:
            return "Copilot"
        }
    }

    var subtitle: String {
        switch self {
        case .claude:
            return "Claude Hooks 与默认 Claude Code 会话"
        case .codex:
            return "Codex App 与 Codex CLI"
        case .cursor:
            return "Cursor IDE 中的 Claude 会话"
        case .qoder:
            return "Qoder、QoderWork 与 JetBrains 插件"
        case .codebuddy:
            return "CodeBuddy 客户端"
        case .trae:
            return "Trae IDE 中的 Claude 会话"
        case .copilot:
            return "GitHub Copilot Hooks 客户端"
        }
    }

    nonisolated var defaultMascotKind: MascotKind {
        switch self {
        case .claude:
            return .claude
        case .codex:
            return .codex
        case .cursor:
            return .cursor
        case .qoder:
            return .qoder
        case .codebuddy:
            return .codebuddy
        case .trae:
            return .trae
        case .copilot:
            return .copilot
        }
    }

    nonisolated init(provider: SessionProvider) {
        switch provider {
        case .codex:
            self = .codex
        case .claude:
            self = .claude
        }
    }

    nonisolated init(clientInfo: SessionClientInfo, provider: SessionProvider) {
        if let profileID = clientInfo.resolvedProfile(for: provider)?.id {
            let resolvedClient: MascotClient? = switch profileID {
            case "cursor":
                .cursor
            case "qoder", "qoderwork", "qoder-cli", "jb-plugin":
                .qoder
            case "codebuddy":
                .codebuddy
            case "trae":
                .trae
            case "codex-app", "codex-cli":
                .codex
            default:
                nil
            }

            if let resolvedClient {
                self = resolvedClient
                return
            }
        }

        switch clientInfo.brand {
        case .codebuddy:
            self = .codebuddy
        case .codex:
            self = .codex
        case .qoder:
            self = .qoder
        case .copilot:
            self = .copilot
        case .claude, .neutral:
            self = provider == .codex ? .codex : .claude
        }
    }
}

enum MascotKind: String, CaseIterable, Identifiable, Sendable {
    case claude
    case codex
    case cursor
    case qoder
    case codebuddy
    case trae
    case copilot

    var id: String { rawValue }

    var title: String {
        switch self {
        case .claude:
            return "Claude Code"
        case .codex:
            return "Codex"
        case .cursor:
            return "Cursor"
        case .qoder:
            return "Qoder"
        case .codebuddy:
            return "CodeBuddy"
        case .trae:
            return "Trae"
        case .copilot:
            return "Copilot"
        }
    }

    var subtitle: String {
        switch self {
        case .claude:
            return "桌前橘猫"
        case .codex:
            return "终端云团"
        case .cursor:
            return "黑曜晶体"
        case .qoder:
            return "Q仔"
        case .codebuddy:
            return "宇航员猫"
        case .trae:
            return "深绿小龙"
        case .copilot:
            return "黑框眼镜机器人"
        }
    }

    var alertColor: Color {
        switch self {
        case .claude:
            return Color(red: 1.0, green: 0.49, blue: 0.24)
        case .codex:
            return Color(red: 1.0, green: 0.67, blue: 0.12)
        case .cursor:
            return Color(red: 1.0, green: 0.52, blue: 0.24)
        case .qoder:
            return Color(red: 0.98, green: 0.53, blue: 0.18)
        case .codebuddy:
            return Color(red: 1.0, green: 0.45, blue: 0.34)
        case .trae:
            return Color(red: 1.0, green: 0.61, blue: 0.28)
        case .copilot:
            return Color(red: 1.0, green: 0.56, blue: 0.28)
        }
    }

    nonisolated init(client: MascotClient) {
        self = client.defaultMascotKind
    }

    nonisolated init(provider: SessionProvider) {
        self = MascotKind(client: MascotClient(provider: provider))
    }

    nonisolated init(clientInfo: SessionClientInfo, provider: SessionProvider) {
        self = MascotKind(client: MascotClient(clientInfo: clientInfo, provider: provider))
    }
}

extension SessionState {
    nonisolated var mascotClient: MascotClient {
        MascotClient(clientInfo: clientInfo, provider: provider)
    }

    nonisolated var defaultMascotKind: MascotKind {
        MascotKind(client: mascotClient)
    }
}

extension MascotStatus {
    init(session: SessionState) {
        if session.needsManualAttention {
            self = .warning
        } else if session.phase.isActive {
            self = .working
        } else {
            self = .idle
        }
    }
}

struct MascotView: View {
    let kind: MascotKind
    let status: MascotStatus
    var size: CGFloat = 40

    init(kind: MascotKind, status: MascotStatus, size: CGFloat = 40) {
        self.kind = kind
        self.status = status
        self.size = size
    }

    init(provider: SessionProvider, status: MascotStatus, size: CGFloat = 40) {
        self.init(kind: MascotKind(provider: provider), status: status, size: size)
    }

    var body: some View {
        ZStack {
            switch status {
            case .idle:
                idleScene
            case .working:
                workingScene
            case .warning:
                warningScene
            }
        }
        .frame(width: size, height: size)
        .clipped()
        .accessibilityLabel("\(kind.title) \(status.displayName)")
    }

    private var idleScene: some View {
        ZStack(alignment: .topTrailing) {
            animatedCanvas(interval: 0.06, mode: .idle)
            FloatingZOverlay(size: size)
        }
    }

    private var workingScene: some View {
        animatedCanvas(interval: 0.03, mode: .working)
    }

    private var warningScene: some View {
        ZStack {
            AlertHalo(tint: kind.alertColor, size: size)
            animatedCanvas(interval: 0.03, mode: .warning)
        }
    }

    private func animatedCanvas(interval: TimeInterval, mode: MascotRenderMode) -> some View {
        TimelineView(.periodic(from: .now, by: interval)) { context in
            Canvas { graphicsContext, canvasSize in
                drawMascot(
                    in: graphicsContext,
                    canvasSize: canvasSize,
                    time: context.date.timeIntervalSinceReferenceDate,
                    mode: mode
                )
            }
        }
        .frame(width: size, height: size)
    }

    private func drawMascot(
        in context: GraphicsContext,
        canvasSize: CGSize,
        time: TimeInterval,
        mode: MascotRenderMode
    ) {
        switch kind {
        case .claude:
            drawClaude(in: context, canvasSize: canvasSize, time: time, mode: mode)
        case .codex:
            drawCodex(in: context, canvasSize: canvasSize, time: time, mode: mode)
        case .cursor:
            drawCursor(in: context, canvasSize: canvasSize, time: time, mode: mode)
        case .qoder:
            drawQoder(in: context, canvasSize: canvasSize, time: time, mode: mode)
        case .codebuddy:
            drawCodeBuddy(in: context, canvasSize: canvasSize, time: time, mode: mode)
        case .trae:
            drawTrae(in: context, canvasSize: canvasSize, time: time, mode: mode)
        case .copilot:
            drawCopilot(in: context, canvasSize: canvasSize, time: time, mode: mode)
        }
    }

    private func drawClaude(
        in context: GraphicsContext,
        canvasSize: CGSize,
        time: TimeInterval,
        mode: MascotRenderMode
    ) {
        let space = PixelSpace(canvasSize, logicalWidth: 17, logicalHeight: 14, yOffset: 2)
        let motion = motionValues(for: mode, time: time)
        let body = Color(red: 0.87, green: 0.53, blue: 0.43)
        let dark = Color(red: 0.63, green: 0.35, blue: 0.25)
        let eye = Color.black
        let keyboardBase = Color(red: 0.26, green: 0.29, blue: 0.34)
        let keyboardKey = Color(red: 0.55, green: 0.60, blue: 0.67)

        drawShadow(in: context, space: space, centerX: 8.5, y: 15.6, width: 8.2 - abs(motion.bounce) * 0.3, opacity: 0.24)

        if mode == .working {
            drawKeyboard(
                in: context,
                space: space,
                y: 12.5,
                base: keyboardBase,
                key: keyboardKey,
                highlight: .white,
                flashIndex: keyboardFlashIndex(time: time)
            )
        }

        let rows: [(CGFloat, CGFloat, CGFloat)] = [
            (13, 4, 9), (12, 3, 11), (11, 3, 11), (10, 3, 11),
            (9, 4, 9), (8, 4, 9), (7, 4, 9), (6, 5, 7)
        ]
        for row in rows {
            context.fill(Path(space.rect(row.1 + motion.shake, row.0 + motion.vertical, row.2 * motion.squashX, 1 * motion.squashY)), with: .color(body))
        }
        context.fill(Path(space.rect(4.2 + motion.shake, 4.7 + motion.vertical, 2.1 * motion.squashX, 1.8)), with: .color(body))
        context.fill(Path(space.rect(10.7 + motion.shake, 4.7 + motion.vertical, 2.1 * motion.squashX, 1.8)), with: .color(body))
        context.fill(Path(space.rect(5.0 + motion.shake, 5.3 + motion.vertical, 0.9, 0.8)), with: .color(Color(red: 0.98, green: 0.73, blue: 0.63).opacity(0.55)))
        context.fill(Path(space.rect(11.0 + motion.shake, 5.3 + motion.vertical, 0.9, 0.8)), with: .color(Color(red: 0.98, green: 0.73, blue: 0.63).opacity(0.55)))
        context.fill(Path(space.rect(12.8 + motion.shake, 11.1 + motion.vertical, 1.8, 0.8)), with: .color(dark))
        context.fill(Path(space.rect(13.7 + motion.shake, 10.2 + motion.vertical, 0.9, 0.8)), with: .color(dark))
        context.fill(Path(space.rect(5.0 + motion.shake, 13.8 + motion.vertical, 1.2, 1.2)), with: .color(dark))
        context.fill(Path(space.rect(10.8 + motion.shake, 13.8 + motion.vertical, 1.2, 1.2)), with: .color(dark))

        let eyeHeight: CGFloat = mode == .idle ? 0.45 : (mode == .warning ? 1.35 : blinkHeight(time: time, closedHeight: 0.2, openHeight: 1.35))
        context.fill(Path(space.rect(6.0 + motion.shake, 8.0 + motion.vertical, 1.0, eyeHeight)), with: .color(eye))
        context.fill(Path(space.rect(10.0 + motion.shake, 8.0 + motion.vertical, 1.0, eyeHeight)), with: .color(eye))

        if mode == .warning {
            drawAlertGlyph(in: context, space: space, x: 12.3 + motion.shake, y: 2.2, color: kind.alertColor)
        }
    }

    private func drawCodex(
        in context: GraphicsContext,
        canvasSize: CGSize,
        time: TimeInterval,
        mode: MascotRenderMode
    ) {
        let space = PixelSpace(canvasSize, logicalWidth: 16, logicalHeight: 14, yOffset: 2)
        let motion = motionValues(for: mode, time: time)
        let cloud = Color(red: 0.93, green: 0.93, blue: 0.94)
        let dark = Color(red: 0.67, green: 0.68, blue: 0.70)
        let prompt = Color.black
        let keyboardBase = Color(red: 0.18, green: 0.18, blue: 0.20)
        let keyboardKey = Color(red: 0.39, green: 0.40, blue: 0.43)

        drawShadow(in: context, space: space, centerX: 8, y: 15.5, width: 7.6 - abs(motion.bounce) * 0.3, opacity: 0.23)

        if mode == .working {
            drawKeyboard(
                in: context,
                space: space,
                y: 12.8,
                base: keyboardBase,
                key: keyboardKey,
                highlight: .white,
                flashIndex: keyboardFlashIndex(time: time)
            )
        }

        let rows: [(CGFloat, CGFloat, CGFloat)] = [
            (13, 4, 8), (12, 3, 10), (11, 2, 12), (10, 2, 12),
            (9, 2, 12), (8, 3, 10), (7, 3, 10), (6, 4, 3),
            (6, 7, 3), (6, 10, 3), (5, 4.5, 2), (5, 7.1, 2), (5, 9.7, 2)
        ]
        for row in rows {
            context.fill(Path(space.rect(row.1 + motion.shake, row.0 + motion.vertical, row.2 * motion.squashX, 1 * motion.squashY)), with: .color(cloud))
        }

        context.fill(Path(space.rect(5.1 + motion.shake, 13.7 + motion.vertical, 0.9, 1.1)), with: .color(dark))
        context.fill(Path(space.rect(9.6 + motion.shake, 13.7 + motion.vertical, 0.9, 1.1)), with: .color(dark))

        if mode == .idle {
            context.fill(Path(space.rect(6.7 + motion.shake, 11.0 + motion.vertical, 2.2, 0.6)), with: .color(prompt.opacity(0.32)))
        } else {
            context.fill(Path(space.rect(5.3 + motion.shake, 9.0 + motion.vertical, 0.9, 0.9)), with: .color(prompt))
            context.fill(Path(space.rect(6.2 + motion.shake, 9.9 + motion.vertical, 0.9, 0.9)), with: .color(prompt))
            context.fill(Path(space.rect(5.3 + motion.shake, 10.8 + motion.vertical, 0.9, 0.9)), with: .color(prompt))

            let cursorWidth: CGFloat = mode == .working && Int(time * 6).isMultiple(of: 2) ? 2.8 : 2.0
            context.fill(Path(space.rect(8.1 + motion.shake, 10.8 + motion.vertical, cursorWidth, 0.9)), with: .color(prompt))
        }

        if mode == .warning {
            drawAlertGlyph(in: context, space: space, x: 11.7 + motion.shake, y: 2.2, color: kind.alertColor)
        }
    }

    private func drawCursor(
        in context: GraphicsContext,
        canvasSize: CGSize,
        time: TimeInterval,
        mode: MascotRenderMode
    ) {
        let space = PixelSpace(canvasSize, logicalWidth: 16, logicalHeight: 14, yOffset: 2)
        let motion = motionValues(for: mode, time: time)
        let dark = Color(red: 0.08, green: 0.07, blue: 0.04)
        let mid = Color(red: 0.15, green: 0.14, blue: 0.12)
        let edge = Color(red: 0.30, green: 0.28, blue: 0.24)
        let light = Color(red: 0.93, green: 0.93, blue: 0.93)

        drawShadow(in: context, space: space, centerX: 8, y: 15.5, width: 7.4 - abs(motion.bounce) * 0.25, opacity: 0.22)

        if mode == .working {
            drawKeyboard(
                in: context,
                space: space,
                y: 12.9,
                base: Color(red: 0.12, green: 0.11, blue: 0.08),
                key: Color(red: 0.28, green: 0.27, blue: 0.23),
                highlight: light,
                flashIndex: keyboardFlashIndex(time: time)
            )
        }

        let top = space.point(8 + motion.shake, 5.1 + motion.vertical)
        let topRight = space.point(12.4 + motion.shake, 7.0 + motion.vertical)
        let bottomRight = space.point(12.4 + motion.shake, 11.0 + motion.vertical)
        let bottom = space.point(8 + motion.shake, 13.2 + motion.vertical)
        let bottomLeft = space.point(3.6 + motion.shake, 11.0 + motion.vertical)
        let topLeft = space.point(3.6 + motion.shake, 7.0 + motion.vertical)
        let center = space.point(8 + motion.shake, 9.2 + motion.vertical)

        var leftFacet = Path()
        leftFacet.move(to: topLeft)
        leftFacet.addLine(to: top)
        leftFacet.addLine(to: center)
        leftFacet.addLine(to: bottomLeft)
        leftFacet.closeSubpath()
        context.fill(leftFacet, with: .color(dark))

        var rightFacet = Path()
        rightFacet.move(to: top)
        rightFacet.addLine(to: topRight)
        rightFacet.addLine(to: bottomRight)
        rightFacet.addLine(to: center)
        rightFacet.closeSubpath()
        context.fill(rightFacet, with: .color(mid))

        var bottomFacet = Path()
        bottomFacet.move(to: bottomLeft)
        bottomFacet.addLine(to: center)
        bottomFacet.addLine(to: bottomRight)
        bottomFacet.addLine(to: bottom)
        bottomFacet.closeSubpath()
        context.fill(bottomFacet, with: .color(edge))

        var slash = Path()
        slash.move(to: space.point(8.6 + motion.shake, 5.8 + motion.vertical))
        slash.addLine(to: space.point(12.0 + motion.shake, 7.2 + motion.vertical))
        slash.addLine(to: space.point(8.4 + motion.shake, 9.4 + motion.vertical))
        slash.closeSubpath()
        context.fill(slash, with: .color(light.opacity(mode == .working ? 0.95 : 0.82)))

        var outline = Path()
        outline.move(to: top)
        outline.addLine(to: topRight)
        outline.addLine(to: bottomRight)
        outline.addLine(to: bottom)
        outline.addLine(to: bottomLeft)
        outline.addLine(to: topLeft)
        outline.closeSubpath()
        context.stroke(outline, with: .color(light.opacity(0.32)), lineWidth: max(1, space.pixel * 0.45))

        let eyeHeight: CGFloat = mode == .idle ? 0.45 : (mode == .warning ? 1.2 : blinkHeight(time: time, closedHeight: 0.25, openHeight: 1.2))
        context.fill(Path(space.rect(5.0 + motion.shake, 9.0 + motion.vertical, 1.1, eyeHeight)), with: .color(light))
        context.fill(Path(space.rect(7.4 + motion.shake, 9.0 + motion.vertical, 1.1, eyeHeight)), with: .color(light))

        if mode == .warning {
            drawAlertGlyph(in: context, space: space, x: 11.5 + motion.shake, y: 2.0, color: kind.alertColor)
        }
    }

    private func drawQoder(
        in context: GraphicsContext,
        canvasSize: CGSize,
        time: TimeInterval,
        mode: MascotRenderMode
    ) {
        let space = PixelSpace(canvasSize, logicalWidth: 17, logicalHeight: 15, yOffset: 1.5)
        let motion = motionValues(for: mode, time: time)
        let body = Color(red: 0.16, green: 0.84, blue: 0.37)
        let highlight = Color(red: 0.50, green: 0.97, blue: 0.62)
        let facePanel = Color.white
        let outline = Color(red: 0.06, green: 0.08, blue: 0.07)
        let pupil = Color(red: 0.07, green: 0.10, blue: 0.08)

        drawShadow(in: context, space: space, centerX: 8.5, y: 15.9, width: 7.9 - abs(motion.bounce) * 0.3, opacity: 0.22)

        if mode == .working {
            drawKeyboard(
                in: context,
                space: space,
                y: 13.1,
                base: Color(red: 0.10, green: 0.18, blue: 0.12),
                key: Color(red: 0.20, green: 0.37, blue: 0.24),
                highlight: body,
                flashIndex: keyboardFlashIndex(time: time)
            )
        }

        let rows: [(CGFloat, CGFloat, CGFloat)] = [
            (13.0, 4.9, 7.2), (12.0, 3.7, 9.8), (11.0, 2.9, 11.2), (10.0, 2.5, 11.9),
            (9.0, 2.4, 12.0), (8.0, 2.6, 11.5), (7.0, 3.4, 10.0), (6.0, 4.6, 7.4), (5.0, 6.2, 4.2)
        ]
        for row in rows {
            context.fill(Path(space.rect(row.1 + motion.shake, row.0 + motion.vertical, row.2 * motion.squashX, 1 * motion.squashY)), with: .color(body))
        }
        context.fill(Path(space.rect(10.8 + motion.shake, 12.1 + motion.vertical, 1.0, 1.0)), with: .color(body))
        context.fill(Path(space.rect(11.5 + motion.shake, 12.8 + motion.vertical, 0.9, 0.9)), with: .color(body))

        let highlightRows: [(CGFloat, CGFloat, CGFloat)] = [
            (6.0, 6.5, 2.2), (7.0, 5.3, 4.2), (8.0, 4.4, 5.6), (9.0, 4.1, 6.3)
        ]
        for row in highlightRows {
            context.fill(Path(space.rect(row.1 + motion.shake, row.0 + motion.vertical, row.2, 1)), with: .color(highlight.opacity(0.34)))
        }

        let faceRows: [(CGFloat, CGFloat, CGFloat)] = [
            (12.0, 5.1, 6.8), (11.0, 4.3, 8.1), (10.0, 3.8, 8.8), (9.0, 3.9, 8.7), (8.0, 4.5, 7.7)
        ]
        for row in faceRows {
            context.fill(Path(space.rect(row.1 + motion.shake, row.0 + motion.vertical, row.2, 1)), with: .color(facePanel))
        }

        context.fill(Path(space.rect(4.8 + motion.shake, 11.9 + motion.vertical, 0.8, 0.8)), with: .color(facePanel))
        context.fill(Path(space.rect(11.4 + motion.shake, 11.9 + motion.vertical, 0.8, 0.8)), with: .color(facePanel))
        context.fill(Path(space.rect(9.9 + motion.shake, 11.2 + motion.vertical, 1.0, 0.9)), with: .color(facePanel))
        context.fill(Path(space.rect(10.7 + motion.shake, 11.8 + motion.vertical, 0.8, 0.8)), with: .color(facePanel))

        var qTail = Path()
        qTail.move(to: space.point(9.9 + motion.shake, 10.9 + motion.vertical))
        qTail.addLine(to: space.point(11.6 + motion.shake, 12.5 + motion.vertical))
        qTail.addLine(to: space.point(11.0 + motion.shake, 13.2 + motion.vertical))
        qTail.addLine(to: space.point(9.5 + motion.shake, 11.6 + motion.vertical))
        qTail.closeSubpath()
        context.fill(qTail, with: .color(outline))

        var antenna = Path()
        antenna.move(to: space.point(8.5 + motion.shake, 4.7 + motion.vertical))
        antenna.addQuadCurve(
            to: space.point(9.7 + motion.shake, 3.0 + motion.vertical),
            control: space.point(8.7 + motion.shake, 3.4 + motion.vertical)
        )
        antenna.addQuadCurve(
            to: space.point(7.7 + motion.shake, 1.9 + motion.vertical),
            control: space.point(9.2 + motion.shake, 1.9 + motion.vertical)
        )
        context.stroke(antenna, with: .color(outline), lineWidth: max(1.2, space.pixel * 0.42))
        context.fill(Path(ellipseIn: space.rect(7.0 + motion.shake, 1.35 + motion.vertical, 1.1, 1.1)), with: .color(outline))

        let eyeHeight: CGFloat = mode == .idle ? 1.75 : (mode == .warning ? 1.6 : blinkHeight(time: time, closedHeight: 0.3, openHeight: 1.9))
        context.fill(
            Path(ellipseIn: space.rect(5.0 + motion.shake, 8.15 + motion.vertical, 2.7, max(0.9, eyeHeight + 0.72))),
            with: .color(outline)
        )
        context.fill(
            Path(ellipseIn: space.rect(8.7 + motion.shake, 8.15 + motion.vertical, 2.7, max(0.9, eyeHeight + 0.72))),
            with: .color(outline)
        )
        context.fill(
            Path(ellipseIn: space.rect(5.42 + motion.shake, 8.48 + motion.vertical, 2.02, max(0.45, eyeHeight))),
            with: .color(facePanel)
        )
        context.fill(
            Path(ellipseIn: space.rect(9.12 + motion.shake, 8.48 + motion.vertical, 2.02, max(0.45, eyeHeight))),
            with: .color(facePanel)
        )

        context.fill(Path(ellipseIn: space.rect(6.22 + motion.shake, 9.22 + motion.vertical, 0.74, 1.02)), with: .color(pupil))
        context.fill(Path(ellipseIn: space.rect(9.92 + motion.shake, 9.22 + motion.vertical, 0.74, 1.02)), with: .color(pupil))
        context.fill(Path(ellipseIn: space.rect(6.38 + motion.shake, 9.28 + motion.vertical, 0.20, 0.20)), with: .color(.white.opacity(0.92)))
        context.fill(Path(ellipseIn: space.rect(10.08 + motion.shake, 9.28 + motion.vertical, 0.20, 0.20)), with: .color(.white.opacity(0.92)))

        if mode != .idle {
            context.fill(Path(space.rect(7.1 + motion.shake, 11.85 + motion.vertical, 1.8, 0.34)), with: .color(pupil.opacity(0.55)))
        } else {
            context.fill(Path(space.rect(7.15 + motion.shake, 11.7 + motion.vertical, 1.7, 0.26)), with: .color(pupil.opacity(0.38)))
        }

        if mode == .warning {
            drawAlertGlyph(in: context, space: space, x: 12.1 + motion.shake, y: 2.3, color: kind.alertColor)
        }
    }

    private func drawCodeBuddy(
        in context: GraphicsContext,
        canvasSize: CGSize,
        time: TimeInterval,
        mode: MascotRenderMode
    ) {
        let space = PixelSpace(canvasSize, logicalWidth: 16, logicalHeight: 14, yOffset: 2)
        let motion = motionValues(for: mode, time: time)
        let body = Color(red: 0.42, green: 0.30, blue: 1.0)
        let dark = Color(red: 0.34, green: 0.24, blue: 0.83)
        let glow = Color(red: 0.20, green: 0.90, blue: 0.73)

        drawShadow(in: context, space: space, centerX: 8, y: 15.7, width: 8.0 - abs(motion.bounce) * 0.3, opacity: 0.22)

        if mode == .working {
            drawKeyboard(
                in: context,
                space: space,
                y: 13.0,
                base: Color(red: 0.18, green: 0.15, blue: 0.30),
                key: Color(red: 0.35, green: 0.30, blue: 0.55),
                highlight: glow,
                flashIndex: keyboardFlashIndex(time: time)
            )
        }

        let rows: [(CGFloat, CGFloat, CGFloat)] = [
            (13, 3, 9), (12, 2, 11), (11, 2, 11), (10, 2, 11),
            (9, 3, 9), (8, 3, 9), (7, 3, 9), (6, 4, 7)
        ]
        for row in rows {
            context.fill(Path(space.rect(row.1 + motion.shake, row.0 + motion.vertical, row.2 * motion.squashX, 1 * motion.squashY)), with: .color(body))
        }

        context.fill(Path(space.rect(2.8 + motion.shake, 4.5 + motion.vertical, 2.0, 1.9)), with: .color(body))
        context.fill(Path(space.rect(11.2 + motion.shake, 4.5 + motion.vertical, 2.0, 1.9)), with: .color(body))
        context.fill(Path(space.rect(3.4 + motion.shake, 5.1 + motion.vertical, 0.9, 0.8)), with: .color(glow.opacity(0.55)))
        context.fill(Path(space.rect(11.7 + motion.shake, 5.1 + motion.vertical, 0.9, 0.8)), with: .color(glow.opacity(0.55)))
        context.fill(Path(space.rect(4.1 + motion.shake, 7.2 + motion.vertical, 7.8, 2.6)), with: .color(dark))
        context.fill(Path(space.rect(12.0 + motion.shake, 11.0 + motion.vertical, 1.7, 0.8)), with: .color(body))
        context.fill(Path(space.rect(12.8 + motion.shake, 10.2 + motion.vertical, 0.9, 0.8)), with: .color(body))
        context.fill(Path(space.rect(4.1 + motion.shake, 14.0 + motion.vertical, 1.3, 1.0)), with: .color(dark))
        context.fill(Path(space.rect(10.6 + motion.shake, 14.0 + motion.vertical, 1.3, 1.0)), with: .color(dark))

        let eyeHeight: CGFloat = mode == .idle ? 0.45 : (mode == .warning ? 1.25 : blinkHeight(time: time, closedHeight: 0.2, openHeight: 1.25))
        context.fill(Path(space.rect(5.3 + motion.shake, 8.0 + motion.vertical, 1.0, eyeHeight)), with: .color(glow))
        context.fill(Path(space.rect(9.0 + motion.shake, 8.0 + motion.vertical, 1.0, eyeHeight)), with: .color(glow))

        if mode == .warning {
            drawAlertGlyph(in: context, space: space, x: 12.0 + motion.shake, y: 2.1, color: kind.alertColor)
        }
    }

    private func drawTrae(
        in context: GraphicsContext,
        canvasSize: CGSize,
        time: TimeInterval,
        mode: MascotRenderMode
    ) {
        let space = PixelSpace(canvasSize, logicalWidth: 17, logicalHeight: 14, yOffset: 2)
        let motion = motionValues(for: mode, time: time)
        let body = Color(red: 0.08, green: 0.42, blue: 0.21)
        let belly = Color(red: 0.66, green: 0.86, blue: 0.71)
        let spike = Color(red: 0.24, green: 0.66, blue: 0.38)
        let eye = Color(red: 0.97, green: 0.86, blue: 0.48)
        let shadow = Color(red: 0.05, green: 0.25, blue: 0.12)

        drawShadow(in: context, space: space, centerX: 8.5, y: 15.5, width: 8.0 - abs(motion.bounce) * 0.25, opacity: 0.22)

        if mode == .working {
            drawKeyboard(
                in: context,
                space: space,
                y: 12.9,
                base: Color(red: 0.07, green: 0.18, blue: 0.10),
                key: Color(red: 0.15, green: 0.31, blue: 0.19),
                highlight: belly,
                flashIndex: keyboardFlashIndex(time: time)
            )
        }

        let rows: [(CGFloat, CGFloat, CGFloat)] = [
            (13, 5.4, 7.2), (12, 4.2, 8.8), (11, 3.2, 10.0), (10, 3.0, 10.4),
            (9, 4.0, 9.6), (8, 5.2, 8.4), (7, 6.0, 6.6)
        ]
        for row in rows {
            context.fill(Path(space.rect(row.1 + motion.shake, row.0 + motion.vertical, row.2 * motion.squashX, 1 * motion.squashY)), with: .color(body))
        }
        context.fill(Path(space.rect(10.8 + motion.shake, 7.0 + motion.vertical, 2.3, 2.0)), with: .color(body))
        context.fill(Path(space.rect(1.8 + motion.shake, 9.5 + motion.vertical, 2.0, 1.0)), with: .color(body))
        context.fill(Path(space.rect(1.0 + motion.shake, 8.8 + motion.vertical, 1.6, 0.8)), with: .color(body))

        context.fill(Path(space.rect(6.1 + motion.shake, 9.3 + motion.vertical, 4.1, 2.6)), with: .color(belly))
        context.fill(Path(space.rect(4.6 + motion.shake, 5.7 + motion.vertical, 0.9, 1.0)), with: .color(spike))
        context.fill(Path(space.rect(6.2 + motion.shake, 5.1 + motion.vertical, 1.0, 1.0)), with: .color(spike))
        context.fill(Path(space.rect(7.8 + motion.shake, 5.4 + motion.vertical, 1.0, 0.9)), with: .color(spike))
        context.fill(Path(space.rect(10.6 + motion.shake, 7.9 + motion.vertical, 1.0, 1.0)), with: .color(eye))
        context.fill(Path(space.rect(11.3 + motion.shake, 8.2 + motion.vertical, 0.6, 0.6)), with: .color(shadow))
        context.fill(Path(space.rect(5.8 + motion.shake, 13.8 + motion.vertical, 1.0, 0.9)), with: .color(shadow))
        context.fill(Path(space.rect(9.2 + motion.shake, 13.8 + motion.vertical, 1.0, 0.9)), with: .color(shadow))
        context.fill(Path(space.rect(11.7 + motion.shake, 10.1 + motion.vertical, 1.0, 0.45)), with: .color(shadow.opacity(0.82)))

        if mode == .working {
            context.fill(Path(space.rect(2.6 + motion.shake, 8.3 + motion.vertical, 0.8, 0.5)), with: .color(spike.opacity(0.85)))
            context.fill(Path(space.rect(1.6 + motion.shake, 8.0 + motion.vertical, 0.8, 0.5)), with: .color(spike.opacity(0.58)))
        }

        if mode == .warning {
            drawAlertGlyph(in: context, space: space, x: 11.8 + motion.shake, y: 2.1, color: kind.alertColor)
        }
    }

    private func drawCopilot(
        in context: GraphicsContext,
        canvasSize: CGSize,
        time: TimeInterval,
        mode: MascotRenderMode
    ) {
        let space = PixelSpace(canvasSize, logicalWidth: 16, logicalHeight: 14, yOffset: 2)
        let motion = motionValues(for: mode, time: time)
        let shell = Color(red: 0.83, green: 0.87, blue: 0.92)
        let trim = Color(red: 0.34, green: 0.39, blue: 0.45)
        let face = Color(red: 0.96, green: 0.97, blue: 0.99)
        let glasses = Color(red: 0.07, green: 0.08, blue: 0.10)
        let eye = Color(red: 0.42, green: 0.82, blue: 1.0)
        let accent = Color(red: 0.33, green: 0.63, blue: 0.98)

        drawShadow(in: context, space: space, centerX: 8, y: 15.5, width: 7.0 - abs(motion.bounce) * 0.25, opacity: 0.21)

        context.fill(Path(space.rect(4.0 + motion.shake, 6.0 + motion.vertical, 8.0 * motion.squashX, 6.8 * motion.squashY)), with: .color(shell))
        context.fill(Path(space.rect(4.4 + motion.shake, 6.4 + motion.vertical, 7.2, 6.0)), with: .color(face))
        context.fill(Path(space.rect(5.0 + motion.shake, 13.3 + motion.vertical, 1.0, 1.1)), with: .color(trim))
        context.fill(Path(space.rect(10.0 + motion.shake, 13.3 + motion.vertical, 1.0, 1.1)), with: .color(trim))
        context.fill(Path(space.rect(6.8 + motion.shake, 4.6 + motion.vertical, 1.1, 1.4)), with: .color(trim))
        context.fill(Path(space.rect(6.2 + motion.shake, 3.8 + motion.vertical, 2.2, 0.8)), with: .color(accent))
        context.fill(Path(space.rect(3.3 + motion.shake, 8.0 + motion.vertical, 0.7, 2.2)), with: .color(trim))
        context.fill(Path(space.rect(12.0 + motion.shake, 8.0 + motion.vertical, 0.7, 2.2)), with: .color(trim))

        context.fill(Path(space.rect(5.0 + motion.shake, 7.5 + motion.vertical, 2.7, 2.2)), with: .color(glasses))
        context.fill(Path(space.rect(8.4 + motion.shake, 7.5 + motion.vertical, 2.7, 2.2)), with: .color(glasses))
        context.fill(Path(space.rect(7.7 + motion.shake, 8.2 + motion.vertical, 0.8, 0.6)), with: .color(glasses))
        context.fill(Path(space.rect(5.4 + motion.shake, 7.9 + motion.vertical, 1.9, 1.4)), with: .color(face))
        context.fill(Path(space.rect(8.8 + motion.shake, 7.9 + motion.vertical, 1.9, 1.4)), with: .color(face))

        let eyeHeight: CGFloat = mode == .idle ? 0.4 : (mode == .warning ? 1.0 : blinkHeight(time: time, closedHeight: 0.2, openHeight: 1.0))
        context.fill(Path(space.rect(6.0 + motion.shake, 8.2 + motion.vertical, 0.75, eyeHeight)), with: .color(eye))
        context.fill(Path(space.rect(9.4 + motion.shake, 8.2 + motion.vertical, 0.75, eyeHeight)), with: .color(eye))

        if mode == .working {
            context.fill(Path(space.rect(5.6 + motion.shake, 11.2 + motion.vertical, 4.8, 0.7)), with: .color(accent.opacity(0.85)))
        } else {
            context.fill(Path(space.rect(6.2 + motion.shake, 11.3 + motion.vertical, 3.6, 0.45)), with: .color(trim.opacity(0.65)))
        }

        if mode == .warning {
            drawAlertGlyph(in: context, space: space, x: 11.6 + motion.shake, y: 2.0, color: kind.alertColor)
        }
    }

    private func motionValues(for mode: MascotRenderMode, time: TimeInterval) -> MascotMotion {
        switch mode {
        case .idle:
            return MascotMotion(
                vertical: CGFloat(sin(time * 1.8) * 0.6),
                bounce: 0,
                shake: 0,
                squashX: 1,
                squashY: 1
            )
        case .working:
            let bounce = CGFloat(sin(time * .pi * 5) * 0.9)
            return MascotMotion(
                vertical: bounce,
                bounce: bounce,
                shake: 0,
                squashX: 1,
                squashY: 1
            )
        case .warning:
            let cycle = time.truncatingRemainder(dividingBy: 1.2)
            let pct = CGFloat(cycle / 1.2)
            let jump = lerp(
                [(0, 0), (0.10, -0.8), (0.18, -4.8), (0.28, 1.0), (0.36, -2.2), (0.50, 0.4), (1, 0)],
                at: pct
            )
            let shake = pct < 0.55 ? CGFloat(sin(time * 42) * 0.55) : 0
            let squashX: CGFloat = jump > 0.4 ? 1.06 : 1.0
            let squashY: CGFloat = jump > 0.4 ? 0.95 : 1.0
            return MascotMotion(
                vertical: jump,
                bounce: jump,
                shake: shake,
                squashX: squashX,
                squashY: squashY
            )
        }
    }

    private func keyboardFlashIndex(time: TimeInterval) -> Int {
        Int(time * 10) % 12
    }

    private func blinkHeight(time: TimeInterval, closedHeight: CGFloat, openHeight: CGFloat) -> CGFloat {
        let cycle = time.truncatingRemainder(dividingBy: 2.8)
        if cycle > 2.45 && cycle < 2.58 {
            return closedHeight
        }
        return openHeight
    }

    private func drawKeyboard(
        in context: GraphicsContext,
        space: PixelSpace,
        y: CGFloat,
        base: Color,
        key: Color,
        highlight: Color,
        flashIndex: Int
    ) {
        context.fill(Path(space.rect(0.5, y, 15.0, 2.6)), with: .color(base))
        for row in 0..<2 {
            for column in 0..<6 {
                let index = row * 6 + column
                let x = 1.1 + CGFloat(column) * 2.3
                let keyColor = index == flashIndex ? highlight.opacity(0.92) : key
                context.fill(Path(space.rect(x, y + 0.45 + CGFloat(row) * 1.0, 1.7, 0.55)), with: .color(keyColor))
            }
        }
    }

    private func drawAlertGlyph(
        in context: GraphicsContext,
        space: PixelSpace,
        x: CGFloat,
        y: CGFloat,
        color: Color
    ) {
        context.fill(Path(space.rect(x, y, 0.9, 2.0)), with: .color(color))
        context.fill(Path(space.rect(x, y + 2.5, 0.9, 0.9)), with: .color(color))
    }

    private func drawShadow(
        in context: GraphicsContext,
        space: PixelSpace,
        centerX: CGFloat,
        y: CGFloat,
        width: CGFloat,
        opacity: Double
    ) {
        context.fill(
            Path(roundedRect: space.rect(centerX - width / 2, y, width, 0.9), cornerRadius: max(0.8, space.pixel * 0.18)),
            with: .color(.black.opacity(opacity))
        )
    }

    private func lerp(_ frames: [(CGFloat, CGFloat)], at pct: CGFloat) -> CGFloat {
        guard let first = frames.first else { return 0 }
        if pct <= first.0 {
            return first.1
        }
        for index in 1..<frames.count {
            let previous = frames[index - 1]
            let next = frames[index]
            if pct <= next.0 {
                let progress = (pct - previous.0) / (next.0 - previous.0)
                return previous.1 + (next.1 - previous.1) * progress
            }
        }
        return frames.last?.1 ?? 0
    }
}

private enum MascotRenderMode {
    case idle
    case working
    case warning
}

private struct MascotMotion {
    let vertical: CGFloat
    let bounce: CGFloat
    let shake: CGFloat
    let squashX: CGFloat
    let squashY: CGFloat
}

private struct PixelSpace {
    let offsetX: CGFloat
    let offsetY: CGFloat
    let pixel: CGFloat
    let logicalWidth: CGFloat
    let yOffset: CGFloat

    init(_ canvasSize: CGSize, logicalWidth: CGFloat, logicalHeight: CGFloat, yOffset: CGFloat) {
        let scale = min(canvasSize.width / logicalWidth, canvasSize.height / logicalHeight)
        self.pixel = max(1, floor(scale))
        self.logicalWidth = logicalWidth
        self.offsetX = (canvasSize.width - logicalWidth * pixel) / 2
        self.offsetY = (canvasSize.height - logicalHeight * pixel) / 2
        self.yOffset = yOffset
    }

    func rect(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
        CGRect(
            x: offsetX + x * pixel,
            y: offsetY + (y - yOffset) * pixel,
            width: width * pixel,
            height: height * pixel
        )
    }

    func point(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
        CGPoint(
            x: offsetX + x * pixel,
            y: offsetY + (y - yOffset) * pixel
        )
    }
}

private struct FloatingZOverlay: View {
    let size: CGFloat

    var body: some View {
        TimelineView(.periodic(from: .now, by: 0.05)) { context in
            let time = context.date.timeIntervalSinceReferenceDate

            ZStack(alignment: .top) {
                ForEach(0..<3, id: \.self) { index in
                    let cycle = 2.7 + Double(index) * 0.3
                    let delay = Double(index) * 0.75
                    let progress = max(0, ((time - delay).truncatingRemainder(dividingBy: cycle)) / cycle)
                    let fontSize = max(6, size * CGFloat(0.16 + progress * 0.10))
                    let opacity = progress < 0.82
                        ? 0.72 - Double(index) * 0.12
                        : max(0, (1.0 - progress) * (2.9 - Double(index) * 0.4))

                    Text("z")
                        .font(.system(size: fontSize, weight: .black, design: .rounded))
                        .foregroundStyle(Color.white.opacity(opacity))
                        .offset(
                            x: size * CGFloat(-0.06 + Double(index) * 0.05 + sin(progress * .pi * 2) * 0.02),
                            y: -size * CGFloat(0.03 + progress * 0.28)
                        )
                }
            }
            .frame(width: size, height: size, alignment: .top)
        }
    }
}

private struct AlertHalo: View {
    let tint: Color
    let size: CGFloat

    var body: some View {
        TimelineView(.periodic(from: .now, by: 0.08)) { context in
            let pulse = CGFloat(sin(context.date.timeIntervalSinceReferenceDate * 6) * 0.5 + 0.5)

            Circle()
                .fill(tint.opacity(0.10 + pulse * 0.12))
                .frame(width: size * (0.78 + pulse * 0.10))
                .blur(radius: size * 0.07)
        }
    }
}

#Preview("Mascot Grid") {
    VStack(spacing: 20) {
        ForEach(MascotStatus.allCases, id: \.self) { status in
            HStack(spacing: 14) {
                ForEach(MascotKind.allCases) { kind in
                    VStack(spacing: 8) {
                        MascotView(kind: kind, status: status, size: 32)
                        Text(kind.title)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
    .padding()
    .background(Color.black)
}
