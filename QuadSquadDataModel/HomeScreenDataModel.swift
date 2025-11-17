//import Foundation
//
//// MARK: - HOME SCREEN DATA MODEL
//struct HomeScreenDataModel: Identifiable, Codable, Hashable {
//    let id: UUID
//    let userName: String
//    let dailyProgressID: UUID?
//    let recentActivityIDs: [UUID]
//    let motivationQuote: String
//    
//    var greeting: String {
//        "Hello, \(userName)!"
//    }
//    
//    init(
//        id: UUID = UUID(),
//        userName: String,
//        dailyProgressID: UUID? = nil,
//        recentActivityIDs: [UUID] = [],
//        motivationQuote: String
//    ) {
//        self.id = id
//        self.userName = userName
//        self.dailyProgressID = dailyProgressID
//        self.recentActivityIDs = recentActivityIDs
//        self.motivationQuote = motivationQuote
//    }
//}
//
//// MARK: - DAILY PROGRESS MODEL
//struct DailyProgress: Identifiable, Codable, Hashable {
//    let id: UUID
//    let totalStudyTime: TimeInterval
//    let accuracy: Double
//    let masteredCards: Int
//    let chaptersRevised: Int
//    
//    var formattedStudyTime: String {
//        let hours = Int(totalStudyTime) / 3600
//        let minutes = (Int(totalStudyTime) % 3600) / 60
//        return "Studied \(hours)h \(minutes)m today"
//    }
//    
//    var formattedAccuracy: String {
//        "Quiz accuracy: \(Int(accuracy))%"
//    }
//    
//    var formattedMastered: String {
//        "Mastered \(masteredCards) flashcards"
//    }
//    
//    var formattedChapters: String {
//        "Revised \(chaptersRevised) chapters"
//    }
//}
//
//// MARK: - RECENT ACTIVITY MODEL
//struct RecentActivityItem: Identifiable, Codable, Hashable {
//    let id: UUID
//    let title: String
//    let icon: String
//    let relatedChapterID: UUID?
//    let relatedQuizResultID: UUID?
//    let relatedFlashcardID: UUID?
//    let date: Date
//    
//    var formattedDate: String {
//        let formatted = DateFormatter()
//        formatted.dateStyle = .medium
//        formatted.timeStyle = .short
//        return formatted.string(from: date)
//    }
//}
//
//// MARK: - HOME SCREEN MANAGER
//final class HomeScreenManager {
//    static let shared = HomeScreenManager()
//    private init() {}
//    
//    private var progressRecords: [UUID: DailyProgress] = [:]
//    private var activityRecords: [UUID: RecentActivityItem] = [:]
//    
//    // MARK: - Generate Home Data for User
//    func generateHomeData(for userName: String) -> HomeScreenDataModel {
//        let usageDates = getUsageDates()
//        let today = Calendar.current.startOfDay(for: Date())
//        let isNewUser = !usageDates.contains(today)
//        
//        recordUsage()
//        
//        if isNewUser {
//            return makeNewUserHomeData(userName: userName)
//        } else {
//            return makeExistingUserHomeData(userName: userName)
//        }
//    }
//    
//    // MARK: - NEW USER DATA
//    private func makeNewUserHomeData(userName: String) -> HomeScreenDataModel {
//        HomeScreenDataModel(
//            userName: userName,
//            motivationQuote: "Welcome \(userName)! Every journey begins with one step."
//        )
//    }
//    
//    // MARK: - EXISTING USER DATA
//    private func makeExistingUserHomeData(userName: String) -> HomeScreenDataModel {
//        let progress = calculateDailyProgress()
//        progressRecords[progress.id] = progress
//        
//        let activities = fetchRecentActivities()
//        for activity in activities { activityRecords[activity.id] = activity }
//        
//        let quote = StudyQuote.allCases.randomElement()?.rawValue ?? "Keep learning every day!"
//        
//        return HomeScreenDataModel(
//            userName: userName,
//            dailyProgressID: progress.id,
//            recentActivityIDs: activities.map { $0.id },
//            motivationQuote: quote
//        )
//    }
//}
//
//// MARK: - DATA HELPERS
//extension HomeScreenManager {
//    
//    private func calculateDailyProgress() -> DailyProgress {
//        // Fetch flashcards
//        let flashcards = FlashcardManager.shared.all()
//        let mastered = flashcards.filter { ($0.accuracy ?? 0) >= 0.9 }.count
//        
//        // Fetch quiz accuracy
//        let quizResults = QuizResultManager.shared.all()
//        let totalCorrect = quizResults.reduce(0) { $0 + $1.totalCorrect }
//        let totalQuestions = quizResults.reduce(0) { $0 + $1.totalQuestions }
//        let accuracy = totalQuestions > 0 ? (Double(totalCorrect) / Double(totalQuestions)) * 100 : 0
//        
//        // Fetch chapters revised
//        let chapters = ChapterManager.shared.all()
//        let chaptersRevised = chapters.filter { $0.isRevised }.count
//        
//        // Calculate study time = based on each chapter’s actual timeSpent if available
//        let totalStudyTime = chapters.reduce(0) { $0 + ($1.timeSpent ?? 0) }
//        
//        return DailyProgress(
//            id: UUID(),
//            totalStudyTime: totalStudyTime,
//            accuracy: accuracy,
//            masteredCards: mastered,
//            chaptersRevised: chaptersRevised
//        )
//    }
//    
//    private func fetchRecentActivities() -> [RecentActivityItem] {
//        var items: [RecentActivityItem] = []
//        let now = Date()
//        
//        // Last revised chapter
//        if let chapter = ChapterManager.shared.all().sorted(by: { ($0.lastAccessed ?? .distantPast) > ($1.lastAccessed ?? .distantPast) }).first {
//            items.append(
//                RecentActivityItem(
//                    id: UUID(),
//                    title: "Revised chapter \(chapter.name)",
//                    icon: "book.closed",
//                    relatedChapterID: chapter.id,
//                    relatedQuizResultID: nil,
//                    relatedFlashcardID: nil,
//                    date: chapter.lastAccessed ?? now
//                )
//            )
//        }
//        
//        // Last quiz attempted
//        if let quiz = QuizResultManager.shared.all().sorted(by: { $0.date > $1.date }).first {
//            items.append(
//                RecentActivityItem(
//                    id: UUID(),
//                    title: "Quiz completed — \(Int(quiz.accuracy))% accuracy",
//                    icon: "questionmark.circle",
//                    relatedChapterID: nil,
//                    relatedQuizResultID: quiz.id,
//                    relatedFlashcardID: nil,
//                    date: quiz.date
//                )
//            )
//        }
//        
//        // Last flashcard reviewed
//        if let flashcard = FlashcardManager.shared.all().sorted(by: { ($0.lastReviewed ?? .distantPast) > ($1.lastReviewed ?? .distantPast) }).first {
//            items.append(
//                RecentActivityItem(
//                    id: UUID(),
//                    title: "Reviewed flashcard: \(flashcard.question)",
//                    icon: "rectangle.on.rectangle.angled",
//                    relatedChapterID: nil,
//                    relatedQuizResultID: nil,
//                    relatedFlashcardID: flashcard.id,
//                    date: flashcard.lastReviewed ?? now
//                )
//            )
//        }
//        
//        return Array(items.prefix(3))
//    }
//    
//    func getProgress(by id: UUID) -> DailyProgress? {
//        progressRecords[id]
//    }
//    
//    func getActivity(by id: UUID) -> RecentActivityItem? {
//        activityRecords[id]
//    }
//}
//
//// MARK: - USAGE TRACKER
//extension HomeScreenManager {
//    private var usageKey: String { "usageDates" }
//    
//    func recordUsage() {
//        var dates = getUsageDates()
//        let today = Calendar.current.startOfDay(for: Date())
//        if !dates.contains(today) {
//            dates.append(today)
//            saveUsageDates(dates)
//        }
//    }
//    
//    func getUsageDates() -> [Date] {
//        guard let data = UserDefaults.standard.array(forKey: usageKey) as? [Date] else { return [] }
//        return data
//    }
//    
//    private func saveUsageDates(_ dates: [Date]) {
//        UserDefaults.standard.set(dates, forKey: usageKey)
//    }
//}


//import Foundation
//
//// MARK: - RECENT ACTIVITY MODEL
//struct RecentActivityItem: Identifiable, Codable {
//    let id = UUID()
//    var chapterName: String
//    var subjectName: String
//    let date: Date
//
//    private static let formatter: DateFormatter = {
//        let f = DateFormatter()
//        f.dateStyle = .medium
//        f.timeStyle = .short
//        return f
//    }()
//
//    var formattedDate: String {
//        Self.formatter.string(from: date)
//    }
//}
//
//// MARK: - DAILY PROGRESS MODEL
//struct DailyProgress {
//    var date: Date
//    var masteredToday: Int
//    var studyMinutes: Int
//    var accuracy: Double
//}
//
//// MARK: - USAGE TRACKER (MERGED HERE)
//final class UsageTracker {
//    static let shared = UsageTracker()
//    private init() {}
//
//    private let key = "usageDates"
//
//    func recordUsage() {
//        var dates = getUsageDates()
//        let today = Calendar.current.startOfDay(for: Date())
//        if !dates.contains(today) {
//            dates.append(today)
//            saveUsageDates(dates)
//        }
//    }
//
//    func getUsageDates() -> [Date] {
//        let saved = UserDefaults.standard.array(forKey: key) as? [Date] ?? []
//        return saved
//    }
//
//    private func saveUsageDates(_ dates: [Date]) {
//        UserDefaults.standard.set(dates, forKey: key)
//    }
//}
//
//// MARK: - HOME SCREEN MODEL
//struct HomeScreenModel {
//    var dailyProgress: DailyProgress?
//    var recentActivity: [RecentActivityItem]
//    var streakDays: Int
//    var totalUsageDays: Int
//    var quote: String
//}
//
//// MARK: - HOME SCREEN DATA MODEL
//final class HomeScreenDataModel {
//    static let shared = HomeScreenDataModel()
//    private init() {}
//
//    func generateHomeScreen(
//        masteredToday: Int,
//        studyMinutes: Int,
//        accuracy: Double,
//        recentActivityIDs: [UUID],
//        allNotes: [UUID: (chapter: String, subject: String, date: Date)]
//    ) -> HomeScreenModel {
//
//        // MARK: - 1) Daily Progress
//        let progress = DailyProgress(
//            date: Date(),
//            masteredToday: masteredToday,
//            studyMinutes: studyMinutes,
//            accuracy: accuracy
//        )
//
//        // MARK: - 2) Recent Activity (IDs → actual items)
//        let recent = recentActivityIDs.compactMap { id -> RecentActivityItem? in
//            guard let info = allNotes[id] else { return nil }
//            return RecentActivityItem(
//                chapterName: info.chapter,
//                subjectName: info.subject,
//                date: info.date
//            )
//        }
//
//        // MARK: - 3) Usage Tracker Stats
//        UsageTracker.shared.recordUsage()
//        let usageDates = UsageTracker.shared.getUsageDates()
//
//        let streak = calculateStreak(from: usageDates)
//
//        // MARK: - 4) Random Quote
//        let quotes = [
//            "Progress over perfection.",
//            "Small steps daily → big results.",
//            "Keep learning, keep growing.",
//            "Your effort today builds tomorrow."
//        ]
//
//        let quote = quotes.randomElement() ?? quotes[0]
//
//        // MARK: - Final Output Model
//        return HomeScreenModel(
//            dailyProgress: progress,
//            recentActivity: recent,
//            streakDays: streak,
//            totalUsageDays: usageDates.count,
//            quote: quote
//        )
//    }
//
//    // MARK: - STREAK CALCULATOR
//    private func calculateStreak(from dates: [Date]) -> Int {
//        let sorted = dates.sorted(by: >)
//        var streak = 0
//        var current = Calendar.current.startOfDay(for: Date())
//
//        for day in sorted {
//            if Calendar.current.isDate(day, inSameDayAs: current) {
//                streak += 1
//                current = Calendar.current.date(byAdding: .day, value: -1, to: current)!
//            } else {
//                break
//            }
//        }
//        return streak
//    }
//}


import Foundation

// MARK: - RECENT ACTIVITY MODEL
struct RecentActivityItem: Identifiable, Codable {
    let id: UUID
    var chapterName: String
    var subjectName: String
    let date: Date

    private static let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f
    }()

    var formattedDate: String {
        Self.formatter.string(from: date)
    }
}

// MARK: - DAILY PROGRESS MODEL
struct DailyProgress: Codable {
    var date: Date
    var masteredToday: Int
    var studyMinutes: Int
    var accuracy: Double
}

// MARK: - STUDY QUOTES
enum StudyQuote: String, CaseIterable {
    case progress = "Progress over perfection."
    case steps = "Small steps daily → big results."
    case grow = "Keep learning, keep growing."
    case build = "Your effort today builds tomorrow."
}

// MARK: - USAGE TRACKER (MERGED HERE)
final class UsageTracker {
    static let shared = UsageTracker()
    private init() {}

    private let key = "usageDates"

    func recordUsage() {
        var dates = getUsageDates()
        let today = Calendar.current.startOfDay(for: Date())
        if !dates.contains(today) {
            dates.append(today)
            saveUsageDates(dates)
        }
    }

    func getUsageDates() -> [Date] {
        UserDefaults.standard.array(forKey: key) as? [Date] ?? []
    }

    private func saveUsageDates(_ dates: [Date]) {
        UserDefaults.standard.set(dates, forKey: key)
    }
}

// MARK: - HOME SCREEN MODEL
struct HomeScreenModel: Codable {
    var dailyProgress: DailyProgress?
    var recentActivity: [RecentActivityItem]
    var streakDays: Int
    var totalUsageDays: Int
    var quote: String
}

// MARK: - HOME SCREEN DATA MODEL
final class HomeScreenDataModel {
    static let shared = HomeScreenDataModel()
    private init() {}

    /// Main generator for Home Screen
    func generateHomeScreen(
        masteredToday: Int,
        studyMinutes: Int,
        accuracy: Double,
        recentActivityIDs: [UUID],
        allNotes: [UUID: (chapter: String, subject: String, date: Date)]
    ) -> HomeScreenModel {

        // MARK: 1) Daily Progress
        let progress = DailyProgress(
            date: Date(),
            masteredToday: masteredToday,
            studyMinutes: studyMinutes,
            accuracy: accuracy
        )

        // MARK: 2) Map recent activity IDs → Actual items
        let recent = recentActivityIDs.compactMap { id -> RecentActivityItem? in
            guard let info = allNotes[id] else { return nil }
            return RecentActivityItem(
                id: id,
                chapterName: info.chapter,
                subjectName: info.subject,
                date: info.date
            )
        }

        // MARK: 3) Usage Tracking
        UsageTracker.shared.recordUsage()
        let usageDates = UsageTracker.shared.getUsageDates()

        let streak = calculateStreak(from: usageDates)

        // MARK: 4) Random Quote
        let quote = StudyQuote.allCases.randomElement()?.rawValue
            ?? StudyQuote.progress.rawValue

        // MARK: Final Output
        return HomeScreenModel(
            dailyProgress: progress,
            recentActivity: recent,
            streakDays: streak,
            totalUsageDays: usageDates.count,
            quote: quote
        )
    }

    // MARK: - STREAK CALCULATOR
    private func calculateStreak(from dates: [Date]) -> Int {
        let sorted = dates.sorted(by: >)
        var streak = 0
        var current = Calendar.current.startOfDay(for: Date())

        for day in sorted {
            if Calendar.current.isDate(day, inSameDayAs: current) {
                streak += 1
                current = Calendar.current.date(byAdding: .day, value: -1, to: current)!
            } else {
                break
            }
        }
        return streak
    }
}


