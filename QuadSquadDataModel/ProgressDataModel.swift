import Foundation

// MARK: - PROGRESS SUMMARY
struct ProgressSummary {
    let weeklyStudyTime: TimeInterval
    let weeklyAccuracy: Double
    let weeklyMasteredCards: Int
    let monthlyStreak: Int
    let subjectProgress: [String: Double]
    let studyInsight: String
}

// MARK: - PROGRESS DATA MODEL
class ProgressDataModel {
    static let shared = ProgressDataModel()
    private init() {}

    // MARK: - MAIN FUNCTION
    func calculateProgress(activityDates: [Date]) -> ProgressSummary {
        let subjects = SubjectManager.shared.all()

        let weeklyStudyTime = calculateWeeklyStudyTime(from: subjects)
        let weeklyMasteredCards = calculateWeeklyMasteredCards(from: subjects)
        let weeklyAccuracy = calculateWeeklyAccuracy(from: subjects)
        let monthlyStreak = calculateMonthlyStreak(from: activityDates)
        let subjectProgress = calculateSubjectProgress(from: subjects)
        let insight = generateInsight(from: subjectProgress)

        return ProgressSummary(
            weeklyStudyTime: weeklyStudyTime,
            weeklyAccuracy: weeklyAccuracy,
            weeklyMasteredCards: weeklyMasteredCards,
            monthlyStreak: monthlyStreak,
            subjectProgress: subjectProgress,
            studyInsight: insight
        )
    }
}

// MARK: - CALCULATIONS
extension ProgressDataModel {
    // WEEKLY STUDY TIME
    func calculateWeeklyStudyTime(from subjects: [Subject]) -> TimeInterval {
        var totalTime: TimeInterval = 0
        for subject in subjects {
            for chapterID in subject.chapterIDs {
                guard let chapter = ChapterManager.shared.get(chapterID) else { continue }

                let flashcardCount = chapter.flashcardIDs.count
                let quizQuestionCount = chapter.quizID.flatMap { QuizManager.shared.get($0)?.mcqIDs.count ?? 0 } ?? 0

                // Approximation: 3 min per MCQ, 1 min per flashcard
                let time = (Double(flashcardCount) * 60) + (Double(quizQuestionCount) * 3 * 60)
                totalTime += time
            }
        }
        return totalTime
    }

    // WEEKLY MASTERED CARDS
    func calculateWeeklyMasteredCards(from subjects: [Subject]) -> Int {
        var mastered = 0
        for subject in subjects {
            for chapterID in subject.chapterIDs {
                guard let chapter = ChapterManager.shared.get(chapterID) else { continue }
                let flashcards = chapter.flashcardIDs.compactMap { FlashcardManager.shared.get($0) }
                mastered += flashcards.filter { $0.isFlipped }.count
            }
        }
        return mastered
    }

    // WEEKLY ACCURACY (QUIZ PERFORMANCE)
    func calculateWeeklyAccuracy(from subjects: [Subject]) -> Double {
        var totalCorrect = 0
        var totalQuestions = 0

        for subject in subjects {
            for chapterID in subject.chapterIDs {
                guard let chapter = ChapterManager.shared.get(chapterID),
                      let resultID = chapter.lastQuizResultID,
                      let result = QuizResultManager.shared.get(resultID) else { continue }

                totalCorrect += result.correctMCQs + result.correctTF
                totalQuestions += result.totalMCQs + result.totalTF
            }
        }

        return totalQuestions > 0 ? (Double(totalCorrect) / Double(totalQuestions)) * 100 : 0
    }

    // MONTHLY STREAK (UNIQUE STUDY DAYS)
    func calculateMonthlyStreak(from dates: [Date]) -> Int {
        guard !dates.isEmpty else { return 0 }

        let calendar = Calendar.current
        let uniqueDays = Array(Set(dates.map { calendar.startOfDay(for: $0) })).sorted()

        var streak = 1
        for i in 1..<uniqueDays.count {
            let diff = calendar.dateComponents([.day], from: uniqueDays[i - 1], to: uniqueDays[i]).day ?? 0
            if diff == 1 {
                streak += 1
            } else if diff > 1 {
                streak = 1
            }
        }
        return streak
    }

    // SUBJECT PROGRESS (ACCURACY PER SUBJECT)
    func calculateSubjectProgress(from subjects: [Subject]) -> [String: Double] {
        var progress: [String: Double] = [:]

        for subject in subjects {
            var totalCorrect = 0
            var totalQuestions = 0

            for chapterID in subject.chapterIDs {
                guard let chapter = ChapterManager.shared.get(chapterID),
                      let resultID = chapter.lastQuizResultID,
                      let result = QuizResultManager.shared.get(resultID) else { continue }

                totalCorrect += result.correctMCQs + result.correctTF
                totalQuestions += result.totalMCQs + result.totalTF
            }

            let accuracy = totalQuestions > 0 ? (Double(totalCorrect) / Double(totalQuestions)) * 100 : 0
            progress[subject.name] = accuracy
        }

        return progress
    }

    // SMART STUDY INSIGHT
    func generateInsight(from progress: [String: Double]) -> String {
        guard !progress.isEmpty else {
            return "Start your first quiz to see insights!"
        }

        if let weakest = progress.min(by: { $0.value < $1.value }),
           let strongest = progress.max(by: { $0.value < $1.value }),
           weakest.key != strongest.key {
            return "Strong in \(strongest.key), but focus more on \(weakest.key)."
        }

        return "Great balance across all subjects — keep it up!"
    }
}
