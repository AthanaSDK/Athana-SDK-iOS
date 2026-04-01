import AthanaCore
import GameKit

/// Game Center 游戏服务提供器
@available(iOS 14.0, *)
public class GameCenterGamingServiceProvider: NSObject, GamingServiceProvider, GKGameCenterControllerDelegate {
    
    public var name: String = "GameCenterGamingServiceProvider"
    
    private let authLock = NSLock()
    private var isAuthenticating = false
    private var pendingAuthContinuations: [CheckedContinuation<Bool, Never>] = []
    
    public override init() {}
    
    public func initialize(config: (any ServiceProviderConfig)?) {
        LoggingService.shared.debug(tag: GamingService.TAG, message: "[\(name)] initialized")
    }
    
    /// 打开排行榜UI
    ///
    /// - Parameters:
    ///   - leaderboardId: 排行榜ID，不传递则默认打开总排行榜入口
    ///   - playerScope: 排行榜范围。如果需要加载 [LeaderboardPlayerScope.FRIENDS] 范围的数据，则需要先通过 [requestFriendListPermission] 获得授权后调用
    ///   - timeScope: 排行榜时间范围（全部、最近7天、今天）
    public func openLeaderboardUI(
        leaderboardId: String?,
        playerScope: LeaderboardPlayerScope,
        timeScope: LeaderboardTimeSpan
    ) async -> Bool {
        let chkResult = await checkGameCenterAuth()
        if (!chkResult) {
            return false
        }

        guard let topViewController = UIApplication.shared.topViewController() else {
            LoggingService.shared.error(
                tag: GamingService.TAG, message: "Top view controller is nil")
            return false
        }
        
        if let id = leaderboardId {
            let controller = GKGameCenterViewController(
                leaderboardID: id,
                playerScope: playerScope.toPlayerScope(),
                timeScope: timeScope.toTimeScope()
            )
            controller.gameCenterDelegate = self
            topViewController.present(controller, animated: true)
        } else {
            let controller = GKGameCenterViewController(state: .leaderboards)
            controller.gameCenterDelegate = self
            topViewController.present(controller, animated: true)
        }
        
        return true
    }
    
    /// 获取排行榜信息
    ///
    /// - Parameters:
    ///   - leaderboardId: 排行榜ID，传 null 表示查询所有
    /// - Returns: 排行榜信息
    public func getLeaderboardInfo(leaderboardId: String?) async throws -> [LeaderboardInfo] {
        let chkResult = await checkGameCenterAuth()
        if (!chkResult) {
            return []
        }
        
        if let id = leaderboardId {
            let result = try await GKLeaderboard.loadLeaderboards(IDs: [id])
            return result.map { $0.toLeaderboardInfo() }
        } else {
            let result = try await GKLeaderboard.loadLeaderboards(IDs: nil)
            return result.map { $0.toLeaderboardInfo() }
        }
    }
    
    /// 提交分数
    ///
    /// - Parameters:
    ///   - leaderboardId: 排行榜ID
    ///   - score: 分数
    ///   - context: 上下文，例如：游戏等级、场景ID等
    /// - Returns: 是否提交成功
    public func submitScore(
        leaderboardId: String,
        score: Int,
        context: Int
    ) async throws -> Bool {
        let chkResult = await checkGameCenterAuth()
        if (!chkResult) {
            return false
        }
        try await GKLeaderboard.submitScore(score, context: context, player: GKLocalPlayer.local, leaderboardIDs: [leaderboardId])
        return true
    }
    
    /// 获取分数
    ///
    /// - Parameters:
    ///   - leaderboardId: 排行榜ID
    ///   - scope: 排行榜范围（全部、好友）
    ///   - timeScope: 时间范围（全部、最近7天、今天）
    /// - Returns: 排行榜分数数据
    public func getScore(
        leaderboardId: String,
        scope: LeaderboardPlayerScope,
        timeScope: LeaderboardTimeSpan
    ) async throws -> ScoreData? {
        let chkResult = await checkGameCenterAuth()
        if (!chkResult) {
            return nil
        }
        let leaderboards = try await GKLeaderboard.loadLeaderboards(IDs: [leaderboardId])
        if let leaderboard = leaderboards.first {
            let scores = try await leaderboard.loadEntries(for: scope.toPlayerScope(), timeScope: timeScope.toTimeScope(), range: NSRange(location: 1, length: 1))
            let score = scores.0
            if score?.rank == 0 {
                return nil
            }
            return score?.toScoreData()
        }
        return nil
    }
    
    /// 分页获取排行榜数据
    /// - Parameters:
    ///   - leaderboardId: 排行榜ID
    ///   - scope: 排行榜范围（全部、好友）
    ///   - timeScope: 时间范围（全部、最近7天、今天）
    ///   - range: 数据量范围（例如：10-20）
    /// - Returns: 排行榜分页数据
    public func loadLeaderboardScores(
        leaderboardId: String,
        scope: LeaderboardPlayerScope,
        timeScope: LeaderboardTimeSpan,
        range: NSRange
    ) async throws -> ScoreList {
        let chkResult = await checkGameCenterAuth()
        if (!chkResult) {
            return ScoreList()
        }
        let leaderboards = try await GKLeaderboard.loadLeaderboards(IDs: [leaderboardId])
        if let leaderboard = leaderboards.first {
            let scores = try await leaderboard.loadEntries(for: scope.toPlayerScope(), timeScope: timeScope.toTimeScope(), range: range)
            let list = scores.1
            let hasMore = range.length > list.count
            return ScoreList(
                scoreList: list.map { $0.toScoreData() }, hasMore: hasMore
            )
        }
        
        return ScoreList()
    }
    
    /// ------------------- 成就
    
    /// 打开成就UI
    public func openAchievementUI() async -> Bool {
        let chkResult = await checkGameCenterAuth()
        if (!chkResult) {
            return false
        }

        guard let topViewController = UIApplication.shared.topViewController() else {
            LoggingService.shared.error(
                tag: GamingService.TAG, message: "Top view controller is nil")
            return false
        }
        
        let controller = GKGameCenterViewController(state: .achievements)
        controller.gameCenterDelegate = self
        topViewController.present(controller, animated: true)
        
        return true
    }
    
    /// 获取成就列表
    public func getAchievementList() async throws -> [Achievement] {
        let chkResult = await checkGameCenterAuth()
        if (!chkResult) {
            return []
        }
        let descList = try await GKAchievementDescription.loadAchievementDescriptions()
        let achievements = try await GKAchievement.loadAchievements()
        return descList.map { d in d.toAchievement(state: achievements.first { a in a.identifier == d.identifier }) }
    }
    
    /// 解锁成就
    public func unlockAchievement(achievementId: String) async throws -> Bool {
        let chkResult = await checkGameCenterAuth()
        if (!chkResult) {
            return false
        }
        let achievement = GKAchievement(identifier: achievementId, player: GKLocalPlayer.local)
        achievement.percentComplete = 100
        try await GKAchievement.report([achievement])
        return true
    }
    
    /// 更新分步成就数据
    public func updateAchievementProgress(
        achievementId: String,
        currentValue: Int
    ) async throws -> Bool {
        let chkResult = await checkGameCenterAuth()
        if (!chkResult) {
            return false
        }
        let achievements = try await GKAchievement.loadAchievements()
        
        let achievement: GKAchievement
        if let a = achievements.first(where: { $0.identifier == achievementId }) {
            a.percentComplete = a.percentComplete + Double(currentValue)
            achievement = a
        } else {
            let a = GKAchievement(identifier: achievementId, player: GKLocalPlayer.local)
            a.percentComplete = Double(currentValue)
            achievement = a
        }
        
        try await GKAchievement.report([achievement])
        return true
    }
    
    /// ------------------- 好友
    
    /// 申请访问好友列表权限
    public func requestFriendListPermission() async throws -> Bool {
        let chkResult = await checkGameCenterAuth()
        if (!chkResult) {
            return false
        }

        if #available(iOS 14.5, *) {
            let status = try await GKLocalPlayer.local.loadFriendsAuthorizationStatus()
            switch status {
            case .notDetermined:
                return true
            case .restricted:
                return false
            case .denied:
                return false
            case .authorized:
                return true
            @unknown default:
                return true
            }
        } else {
            return false
        }
    }
    
    /// 分页获取好友列表
    public func loadFriendList(range: Range<Int>) async throws -> PlayerList {
        let chkResult = await checkGameCenterAuth()
        if (!chkResult) {
            return PlayerList()
        }

        if #available(iOS 14.5, *) {
            let results = try await GKLocalPlayer.local.loadFriends()
            let list: [PlayerProfile]
            if range.count >= results.count {
                list = results.map { $0.toPlayerProfile() }
            } else {
                list = results[range].map { $0.toPlayerProfile() }
            }
            return PlayerList(friends: list, hasMore: list.count == range.count)
        } else {
            return PlayerList()
        }
    }
    
    /// 打开玩家资料UI
    @objc public func openPlayerProfileUI(player: PlayerProfile) async {
        let chkResult = await checkGameCenterAuth()
        if (!chkResult) {
            return
        }

        if let p = player as? GamingGKPlayerProfile {
            await p.openProfileUI()
        }
    }

    public func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true)
    }
    
    private func checkGameCenterAuth() async -> Bool {
        if GKLocalPlayer.local.isAuthenticated {
            return true
        }
        
        return await withCheckedContinuation { continuation in
            authLock.lock()
            
            if GKLocalPlayer.local.isAuthenticated {
                authLock.unlock()
                continuation.resume(returning: true)
                return
            }
            
            if isAuthenticating {
                pendingAuthContinuations.append(continuation)
                authLock.unlock()
                return
            }
            
            isAuthenticating = true
            pendingAuthContinuations.append(continuation)
            authLock.unlock()
            
            GKLocalPlayer.local.authenticateHandler = { [weak self] viewController, error in
                guard let self = self else { return }
                
                if let controller = viewController {
                    guard let topViewController = UIApplication.shared.topViewController() else {
                        LoggingService.shared.warn(tag: GamingService.TAG, message: "[\(self.name)] Failed to show Game Center Sign-In View. Cannot access Top UIViewController.")
                        self.resolveAuthContinuations(result: false)
                        return
                    }
                    topViewController.present(controller, animated: true)
                    return
                }
                
                if let err = error {
                    LoggingService.shared.warn(tag: GamingService.TAG, message: "[\(self.name)] Game Center authenticate is failure.", error: err)
                    ErrorRecordService.shared.recordError(err)
                    self.resolveAuthContinuations(result: false)
                    return
                }
                
                if GKLocalPlayer.local.isAuthenticated {
                    self.resolveAuthContinuations(result: true)
                }
            }
        }
    }
    
    private func resolveAuthContinuations(result: Bool) {
        authLock.lock()
        isAuthenticating = false
        let continuations = pendingAuthContinuations
        pendingAuthContinuations.removeAll()
        GKLocalPlayer.local.authenticateHandler = nil
        authLock.unlock()
        
        for continuation in continuations {
            continuation.resume(returning: result)
        }
    }
}

extension LeaderboardPlayerScope {
    
    func toPlayerScope() -> GKLeaderboard.PlayerScope {
        switch self {
        case .ALL:
            return .global
        case .FRIENDS:
            return .friendsOnly
        }
    }
    
}

extension LeaderboardTimeSpan {
    
    func toTimeScope() -> GKLeaderboard.TimeScope {
        switch self {
        case .ALL_TIME:
            return .allTime
        case .WEEK:
            return .week
        case .TODAY:
            return .today
        }
    }
    
}

@available(iOS 14.0, *)
extension GKLeaderboard.LeaderboardType {
    
    func toLeaderboardType() -> LeaderboardType {
        switch self {
        case .classic:
            return .classic
        case .recurring:
            return .recurring
        }
    }
    
}

extension GKLeaderboard {
    
    @available(iOS 14.0, *)
    func toLeaderboardInfo() -> LeaderboardInfo {
        // TODO: 缓存图片到沙盒内
        //        self.loadImage()
        return LeaderboardInfo(
            type: self.type.toLeaderboardType(),
            leaderboardId: self.baseLeaderboardID,
            name: self.title ?? "unknown",
            imageUrl: ""
        )
    }
    
}

@available(iOS 14.0, *)
extension GKLeaderboard.Entry {
    
    func toScoreData() -> ScoreData {
        return ScoreData(
            rank: self.rank,
            score: self.score,
            displayScore: self.formattedScore,
            player: self.player.toPlayerProfile(),
            extraInfo: ScoreExtraInfo(
                timestamp: Int(self.date.timeIntervalSince1970)
            )
        )
    }
    
}

extension GKAchievementDescription {
    
    @available(iOS 14.0, *)
    func toAchievement(state: GKAchievement?) -> Achievement {
        // TODO: 缓存图片到沙盒内
        // if (state.isCompleted) {
        //     loadImage()
        // } else {
        //     incompleteAchievementImage()
        // }
        return Achievement(
            achievementId: self.identifier,
            title: self.title,
            desc: (state?.isCompleted == true) ? self.achievedDescription : self.unachievedDescription,
            imageUrl: "",
            type: .INCREMENTAL,
            state: (state?.isCompleted == true) ? .UNLOCKED : self.isHidden ? .HIDDEN : .VISIBLE,
            progress: state?.percentComplete ?? 0.0
        )
    }
    
}

extension GKPlayer {
    
    @available(iOS 14.0, *)
    func toPlayerProfile() -> PlayerProfile {
        return GamingGKPlayerProfile(player: self)
    }
    
}

class GamingGKPlayerProfile: PlayerProfile, GKGameCenterControllerDelegate {
    
    private let player: GKPlayer?
    
    required init(player: GKPlayer) {
        self.player = player
        // TODO: 缓存图片到沙盒内
        //        self.loadPhoto()
        super.init(playerId: player.teamPlayerID, playerName: player.alias, avatarUrl: "")
    }
    
    required init(from decoder: any Decoder) throws {
        self.player = nil
        try super.init(from: decoder)
    }
    
    override func openProfileUI() async {
        LoggingService.shared.error(tag: GamingService.TAG, message: "Opening Profile UI")
        
        if #available(iOS 18.0, *) {
            guard let topViewController = UIApplication.shared.topViewController() else {
                LoggingService.shared.error(
                    tag: GamingService.TAG, message: "Failed to Open Profile UI. Top view controller is nil")
                return
            }
            
            guard let player = self.player else {
                LoggingService.shared.error(
                    tag: GamingService.TAG, message: "Failed to Open Profile UI. Player is empty")
                return
            }
            
            let controller = GKGameCenterViewController(player: player)
            controller.gameCenterDelegate = self
            topViewController.present(controller, animated: true)
        } else {
            LoggingService.shared.error(
                tag: GamingService.TAG, message: "Failed to open Profile UI. Not supported on this OS version")
        }
    }
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true)
    }
}
