import SwiftUI
import SwiftData

@main
struct TaskFlowApp: App {
    let container: ModelContainer

    init() {
        let schema = Schema([
            Area.self, Project.self, Task.self, TimeEntry.self,
            StudyPlan.self, StudySession.self, SchoolEvent.self
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            container = try ModelContainer(for: schema, configurations: config)
        } catch {
            fatalError("ModelContainer 생성 실패: \(error)")
        }

        // 첫 실행 시 "학교" Area 기본 생성
        if !UserDefaults.standard.bool(forKey: "didSeedSchoolArea") {
            let ctx = ModelContext(container)
            let school = Area(name: "학교", order: 0)
            ctx.insert(school)

            // 기본 행사 (날짜는 미정으로 올해 기준)
            let year = Calendar.current.component(.year, from: Date())
            let cal = Calendar.current

            let presets: [(String, String, Int, Int)] = [
                ("1학기 중간고사", "midterm", 4, 15),
                ("1학기 기말고사", "final",   6, 15),
                ("2학기 중간고사", "midterm", 10, 15),
                ("2학기 기말고사", "final",   12, 15),
            ]
            for (title, type, month, day) in presets {
                var comps = DateComponents()
                comps.year = year; comps.month = month; comps.day = day
                let date = cal.date(from: comps) ?? Date()
                let event = SchoolEvent(title: title, date: date, type: type, area: school)
                ctx.insert(event)
            }

            try? ctx.save()
            UserDefaults.standard.set(true, forKey: "didSeedSchoolArea")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }
}
