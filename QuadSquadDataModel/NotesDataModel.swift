import Foundation

// MARK: - SUBJECT MODEL
struct Subject: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var chapterIDs: [UUID]
    
    var chapterCount: Int {
        chapterIDs.count
    }
    
    init(id: UUID = UUID(), name: String, chapterIDs: [UUID] = []) {
        self.id = id
        self.name = name
        self.chapterIDs = chapterIDs
    }
}
// MARK: - CHAPTER MODEL
struct Chapter: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var summaryID: UUID?
    var flashcardIDs: [UUID]
    var quizID: UUID?
    var activeRecallIDs: [UUID]
    var lastQuizResultID: UUID?
    let createdOn: Date
    
    init(
        id: UUID = UUID(),
        name: String,
        summaryID: UUID? = nil,
        flashcardIDs: [UUID] = [],
        quizID: UUID? = nil,
        activeRecallIDs: [UUID] = [],
        lastQuizResultID: UUID? = nil,
        createdOn: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.summaryID = summaryID
        self.flashcardIDs = flashcardIDs
        self.quizID = quizID
        self.activeRecallIDs = activeRecallIDs
        self.lastQuizResultID = lastQuizResultID
        self.createdOn = createdOn
    }
}

// MARK: - OTHER MODELS
struct ChapterSummary: Identifiable, Codable, Hashable {
    let id: UUID
    var topicIDs: [UUID]
}

struct SummaryTopic: Identifiable, Codable, Hashable {
    let id: UUID
    let title: String
    let pointIDs: [UUID]
}

struct SummaryPoint: Identifiable, Codable, Hashable {
    let id: UUID
    let text: String
}

struct FlashcardModel: Identifiable, Codable, Hashable {
    let id: UUID
    let question: String
    let answer: String
    var isFlipped: Bool
}

struct ActiveRecallQuestion: Identifiable, Codable, Hashable {
    let id: UUID
    let question: String
    let answer: String
}

struct QuizScreenModel: Identifiable, Codable, Hashable {
    let id: UUID
    let mcqIDs: [UUID]
    let trueFalseIDs: [UUID]
}

struct QuestionModel: Identifiable, Codable, Hashable {
    let id: UUID
    let question: String
    let explanation: String?
    let options: [String]?
    let correctIndex: Int?
    let isTrueOrFalse: Bool?
}

// MARK: - UPDATED QUIZ RESULT MODEL
struct QuizResultModel: Identifiable, Codable, Hashable {
    let id: UUID
    
    // Base data
    let correctMCQs: Int
    let totalMCQs: Int
    let correctTF: Int
    let totalTF: Int
    
    let daysUntilNextQuiz: Int
    let allTopics: [String]
    let incorrectTopics: [String]
    
    // MARK: - Computed Properties
    
    /// Total correct answers
    var totalCorrect: Int {
        correctMCQs + correctTF
    }
    
    /// Total questions attempted
    var totalQuestions: Int {
        totalMCQs + totalTF
    }
    
    /// Accuracy in percentage
    var accuracy: Double {
        guard totalQuestions > 0 else { return 0 }
        return (Double(totalCorrect) / Double(totalQuestions)) * 100
    }
    
    /// "You got 14 out of 18 correct"
    var performanceLine: String {
        "You got \(totalCorrect) out of \(totalQuestions) correct"
    }
    
    /// Dynamic performance title
    var resultTitle: String {
        switch accuracy {
        case 90...100:
            return "Amazing! You’re mastering this topic"
        case 70..<90:
            return "Good job! Accuracy improving every session"
        case 50..<70:
            return "Keep practicing! You’re learning steadily"
        default:
            return "Don’t worry! Every mistake teaches you something new"
        }
    }
    
    /// "8/10"
    var mcqSummary: String {
        "\(correctMCQs)/\(totalMCQs)"
    }
    
    /// "6/8"
    var tfSummary: String {
        "\(correctTF)/\(totalTF)"
    }
    
    /// "Next quiz in 3 days"
    var nextReminderLine: String {
        "Next quiz in \(daysUntilNextQuiz) days"
    }
    
    /// Topics to revise (incorrect ones)
    var topicsToRevise: [String] {
        incorrectTopics
    }
}

class SubjectManager {
    static let shared = SubjectManager()
    private init() {}

    private(set) var subjects: [UUID: Subject] = [:]

    func add(_ subject: Subject) {
        subjects[subject.id] = subject
    }

    func get(_ id: UUID) -> Subject? {
        subjects[id]
    }

    func all() -> [Subject] {
        Array(subjects.values)
    }

    func delete(_ id: UUID) {
        subjects.removeValue(forKey: id)
    }

    func addChapter(_ chapterID: UUID, to subjectID: UUID) {
        subjects[subjectID]?.chapterIDs.append(chapterID)
    }
}
class ChapterManager {
    static let shared = ChapterManager()
    private init() {}

    private(set) var chapters: [UUID: Chapter] = [:]

    func add(_ chapter: Chapter) {
        chapters[chapter.id] = chapter
    }

    func get(_ id: UUID) -> Chapter? {
        chapters[id]
    }

    func all() -> [Chapter] {
        Array(chapters.values)
    }

    func delete(_ id: UUID) {
        chapters.removeValue(forKey: id)
    }

    func linkSummary(_ summaryID: UUID, to chapterID: UUID) {
        chapters[chapterID]?.summaryID = summaryID
    }

    func linkQuiz(_ quizID: UUID, to chapterID: UUID) {
        chapters[chapterID]?.quizID = quizID
    }

    func linkFlashcards(_ flashcardIDs: [UUID], to chapterID: UUID) {
        chapters[chapterID]?.flashcardIDs.append(contentsOf: flashcardIDs)
    }

    func linkActiveRecalls(_ recallIDs: [UUID], to chapterID: UUID) {
        chapters[chapterID]?.activeRecallIDs.append(contentsOf: recallIDs)
    }

    func linkQuizResult(_ resultID: UUID, to chapterID: UUID) {
        chapters[chapterID]?.lastQuizResultID = resultID
    }
}
class SummaryManager {
    static let shared = SummaryManager()
    private init() {}

    private(set) var summaries: [UUID: ChapterSummary] = [:]

    func add(_ summary: ChapterSummary) {
        summaries[summary.id] = summary
    }

    func get(_ id: UUID) -> ChapterSummary? {
        summaries[id]
    }

    func all() -> [ChapterSummary] {
        Array(summaries.values)
    }

    func delete(_ id: UUID) {
        summaries.removeValue(forKey: id)
    }
}
class FlashcardManager {
    static let shared = FlashcardManager()
    private init() {}

    private(set) var flashcards: [UUID: FlashcardModel] = [:]

    func add(_ flashcard: FlashcardModel) {
        flashcards[flashcard.id] = flashcard
    }

    func addMultiple(_ list: [FlashcardModel]) {
        for card in list {
            flashcards[card.id] = card
        }
    }

    func get(_ id: UUID) -> FlashcardModel? {
        flashcards[id]
    }

    func all() -> [FlashcardModel] {
        Array(flashcards.values)
    }

    func delete(_ id: UUID) {
        flashcards.removeValue(forKey: id)
    }
}
class ActiveRecallManager {
    static let shared = ActiveRecallManager()
    private init() {}

    private(set) var recalls: [UUID: ActiveRecallQuestion] = [:]

    func add(_ question: ActiveRecallQuestion) {
        recalls[question.id] = question
    }

    func get(_ id: UUID) -> ActiveRecallQuestion? {
        recalls[id]
    }

    func all() -> [ActiveRecallQuestion] {
        Array(recalls.values)
    }

    func delete(_ id: UUID) {
        recalls.removeValue(forKey: id)
    }
}
class QuizManager {
    static let shared = QuizManager()
    private init() {}

    private(set) var quizzes: [UUID: QuizScreenModel] = [:]

    func add(_ quiz: QuizScreenModel) {
        quizzes[quiz.id] = quiz
    }

    func get(_ id: UUID) -> QuizScreenModel? {
        quizzes[id]
    }

    func all() -> [QuizScreenModel] {
        Array(quizzes.values)
    }

    func delete(_ id: UUID) {
        quizzes.removeValue(forKey: id)
    }
}
class QuizResultManager {
    static let shared = QuizResultManager()
    private init() {}

    private(set) var results: [UUID: QuizResultModel] = [:]

    func add(_ result: QuizResultModel) {
        results[result.id] = result
    }

    func get(_ id: UUID) -> QuizResultModel? {
        results[id]
    }

    func all() -> [QuizResultModel] {
        Array(results.values)
    }

    func delete(_ id: UUID) {
        results.removeValue(forKey: id)
    }
}

